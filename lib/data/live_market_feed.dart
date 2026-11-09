import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/candle.dart';
import '../models/coin.dart';

/// 免费公开行情源：同时请求币安（data-api.binance.vision / api.binance.com）
/// 与火币（api.huobi.pro），取最先返回的可用结果。
///
/// 两个接口都无需 API Key。只请求 App 内展示的币种对应的 USDT 交易对，
/// 避免一次拉取上千个交易对；接口不可用时由 `Repository` 回退到内置数据。
class LiveMarketFeed {
  static const _timeout = Duration(seconds: 4);

  /// 测试注入用；为 null 时每次请求创建临时 client。
  static http.Client? clientOverride;

  /// 最近一次成功的数据源名称（`Binance` / `Huobi`）。
  static String? lastSource;

  static const _binanceIntervals = <String, String>{
    '15m': '15m',
    '1h': '1h',
    '4h': '4h',
    '1d': '1d',
  };

  static const _huobiIntervals = <String, String>{
    '15m': '15min',
    '1h': '60min',
    '4h': '4hour',
    '1d': '1day',
  };

  static const _binanceHosts = ['data-api.binance.vision', 'api.binance.com'];

  /// 拉取 [bases] 中币种的最新 24h 行情，保留内置的名称、颜色与市值。
  static Future<List<Coin>> fetchCoins(List<Coin> bases) async {
    _CoinsResult result;
    try {
      // 先并发尝试币安的两个域名；成功时避免再下载火币的全量 tickers。
      result = await _firstValid(<Future<_CoinsResult>>[
        for (final host in _binanceHosts)
          _binanceCoins(
            host,
            bases,
          ).then((tickers) => _coinsResult('Binance', bases, tickers)),
      ]);
    } catch (_) {
      result = await _huobiCoins(bases)
          .then((tickers) => _coinsResult('Huobi', bases, tickers));
    }
    lastSource = result.source;
    return result.coins;
  }

  /// 拉取 [coin] 指定周期的 K 线，返回时间正序的数据。
  static Future<List<Candle>> fetchCandles(
    Coin coin,
    String timeframe, {
    int limit = 140,
  }) async {
    _CandlesResult result;
    try {
      result = await _firstValid(<Future<_CandlesResult>>[
        for (final host in _binanceHosts)
          _binanceCandles(
            host,
            coin,
            timeframe,
            limit,
          ).then((candles) => _candlesResult('Binance', candles)),
      ]);
    } catch (_) {
      result = await _huobiCandles(
        coin,
        timeframe,
        limit,
      ).then((candles) => _candlesResult('Huobi', candles));
    }
    lastSource = result.source;
    return result.candles;
  }

  static _CoinsResult _coinsResult(
    String source,
    List<Coin> bases,
    Map<String, _Ticker> tickers,
  ) {
    final coins = _merge(bases, tickers);
    if (coins.isEmpty) {
      throw Exception('$source 未返回可用行情');
    }
    return _CoinsResult(source, coins);
  }

  static _CandlesResult _candlesResult(String source, List<Candle> candles) {
    if (candles.isEmpty) {
      throw Exception('$source 未返回可用 K 线');
    }
    return _CandlesResult(source, candles);
  }

  /// 并发请求中取最先成功的结果；全部失败时抛出最后一个错误。
  static Future<T> _firstValid<T>(List<Future<T>> attempts) {
    final completer = Completer<T>();
    var remaining = attempts.length;
    for (final attempt in attempts) {
      attempt.then(
        (value) {
          if (!completer.isCompleted) completer.complete(value);
        },
        onError: (Object error, StackTrace stackTrace) {
          remaining--;
          if (remaining == 0 && !completer.isCompleted) {
            completer.completeError(Exception('所有行情接口均不可用: $error'));
          }
        },
      );
    }
    return completer.future;
  }

  static List<Coin> _merge(List<Coin> bases, Map<String, _Ticker> tickers) {
    final result = <Coin>[];
    for (final base in bases) {
      final ticker = tickers[base.symbol];
      if (ticker == null) continue;
      // 接口不提供市值，用内置数据反推流通量，再按实时价格换算。
      final supply = base.price > 0 ? base.marketCap / base.price : 0.0;
      result.add(
        Coin(
          symbol: base.symbol,
          name: base.name,
          color: base.color,
          price: ticker.price,
          change24h: ticker.change,
          high24h: ticker.high,
          low24h: ticker.low,
          volume24h: ticker.volume,
          marketCap: supply > 0 ? ticker.price * supply : base.marketCap,
        ),
      );
    }
    return result;
  }

  static Future<Map<String, _Ticker>> _binanceCoins(
    String host,
    List<Coin> bases,
  ) {
    final symbols = bases.map((coin) => '${coin.symbol}USDT').toList();
    return _get(
      host: host,
      path: '/api/v3/ticker/24hr',
      query: {'symbols': jsonEncode(symbols)},
      parse: (json) {
        if (json is! List) {
          throw const FormatException('Unexpected Binance ticker payload');
        }
        final tickers = <String, _Ticker>{};
        for (final item in json) {
          if (item is! Map) continue;
          final symbol = '${item['symbol'] ?? ''}';
          final base = symbol.endsWith('USDT')
              ? symbol.substring(0, symbol.length - 4)
              : symbol;
          final price = _toDouble(item['lastPrice']);
          if (price <= 0) continue;
          tickers[base] = _Ticker(
            price: price,
            change: _toDouble(item['priceChangePercent']),
            high: _toDouble(item['highPrice']),
            low: _toDouble(item['lowPrice']),
            volume: _toDouble(item['quoteVolume']),
          );
        }
        return tickers;
      },
    );
  }

  static Future<Map<String, _Ticker>> _huobiCoins(List<Coin> bases) {
    final wanted = {for (final coin in bases) '${coin.symbol}USDT'};
    return _get(
      host: 'api.huobi.pro',
      path: '/market/tickers',
      parse: (json) {
        if (json is! Map || json['status'] != 'ok') {
          throw const FormatException('Unexpected Huobi ticker payload');
        }
        final data = json['data'];
        if (data is! List) {
          throw const FormatException('Unexpected Huobi ticker data');
        }
        final tickers = <String, _Ticker>{};
        for (final item in data) {
          if (item is! Map) continue;
          final symbol = '${item['symbol'] ?? ''}'.toUpperCase();
          if (!wanted.contains(symbol)) continue;
          final base = symbol.substring(0, symbol.length - 4);
          final open = _toDouble(item['open']);
          final close = _toDouble(item['close']);
          if (close <= 0) continue;
          tickers[base] = _Ticker(
            price: close,
            change: open > 0 ? (close - open) / open * 100 : 0,
            high: _toDouble(item['high']),
            low: _toDouble(item['low']),
            volume: _toDouble(item['vol']),
          );
        }
        return tickers;
      },
    );
  }

  static Future<List<Candle>> _binanceCandles(
    String host,
    Coin coin,
    String timeframe,
    int limit,
  ) {
    return _get(
      host: host,
      path: '/api/v3/klines',
      query: {
        'symbol': '${coin.symbol}USDT',
        'interval': _binanceIntervals[timeframe] ?? '1h',
        'limit': '$limit',
      },
      parse: (json) {
        if (json is! List) {
          throw const FormatException('Unexpected Binance kline payload');
        }
        final candles = <Candle>[];
        for (final item in json) {
          if (item is! List || item.length < 6) continue;
          final time = _toInt(item[0]);
          final volume = item.length > 7
              ? _toDouble(item[7])
              : _toDouble(item[5]);
          candles.add(
            Candle(
              time: DateTime.fromMillisecondsSinceEpoch(time),
              open: _toDouble(item[1]),
              high: _toDouble(item[2]),
              low: _toDouble(item[3]),
              close: _toDouble(item[4]),
              volume: volume,
            ),
          );
        }
        return candles;
      },
    );
  }

  static Future<List<Candle>> _huobiCandles(
    Coin coin,
    String timeframe,
    int limit,
  ) {
    return _get(
      host: 'api.huobi.pro',
      path: '/market/history/kline',
      query: {
        'symbol': '${coin.symbol.toLowerCase()}usdt',
        'period': _huobiIntervals[timeframe] ?? '60min',
        'size': '$limit',
      },
      parse: (json) {
        if (json is! Map || json['status'] != 'ok') {
          throw const FormatException('Unexpected Huobi kline payload');
        }
        final data = json['data'];
        if (data is! List) {
          throw const FormatException('Unexpected Huobi kline data');
        }
        final candles = <Candle>[];
        for (final item in data) {
          if (item is! Map) continue;
          final seconds = _toInt(item['id']);
          if (seconds <= 0) continue;
          candles.add(
            Candle(
              time: DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
              open: _toDouble(item['open']),
              high: _toDouble(item['high']),
              low: _toDouble(item['low']),
              close: _toDouble(item['close']),
              volume: _toDouble(item['vol']),
            ),
          );
        }
        // 火币按时间倒序返回，这里翻转为正序。
        return candles.reversed.toList(growable: false);
      },
    );
  }

  static Future<T> _get<T>({
    required String host,
    required String path,
    Map<String, String>? query,
    required T Function(Object? json) parse,
  }) async {
    final client = clientOverride ?? http.Client();
    try {
      final uri = Uri.https(host, path, query);
      final response = await client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw http.ClientException('HTTP ${response.statusCode}', uri);
      }
      return parse(jsonDecode(response.body));
    } finally {
      if (clientOverride == null) client.close();
    }
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  static int _toInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? 0;
  }
}

class _Ticker {
  final double price;
  final double change;
  final double high;
  final double low;
  final double volume;

  const _Ticker({
    required this.price,
    required this.change,
    required this.high,
    required this.low,
    required this.volume,
  });
}

class _CoinsResult {
  final String source;
  final List<Coin> coins;

  const _CoinsResult(this.source, this.coins);
}

class _CandlesResult {
  final String source;
  final List<Candle> candles;

  const _CandlesResult(this.source, this.candles);
}
