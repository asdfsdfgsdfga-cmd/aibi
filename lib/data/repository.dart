import 'package:flutter/foundation.dart';

import '../models/candle.dart';
import '../models/coin.dart';
import '../models/exchange.dart';
import '../models/news.dart';
import 'exchange_feed.dart';
import 'live_market_feed.dart';
import 'market_data.dart';
import 'mock_coins.dart';
import 'mock_exchanges.dart';
import 'mock_news.dart';

/// 数据仓库：交易所与币种行情优先从远端数据源拉取，失败时使用内置数据兜底；
/// 新闻仍使用内置数据。首次加载后缓存，切换页面无需重复等待。
class Repository {
  static const _latency = Duration(milliseconds: 300);

  static List<Exchange>? _exchangeCache;
  static List<Coin>? _coinCache;
  static List<NewsItem>? _newsCache;
  static final Map<String, List<Candle>> _candleCache = {};

  /// 当前交易所数据是否来自远端数据源。
  static bool exchangesFromRemote = false;

  /// 当前币种行情是否来自币安 / 火币等公开行情接口。
  static bool coinsFromRemote = false;

  /// 最近一次币种行情成功时使用的数据源（'Binance' / 'Huobi'）。
  static String? coinSource;

  /// 最近一次交易所数据加载失败的说明（成功时为 null）。
  static String? lastExchangeError;

  /// 最近一次币种行情加载失败的说明（成功时为 null）。
  static String? lastCoinError;

  /// 交易所列表。传入 [refresh] 可跳过缓存重新拉取远端数据。
  static Future<List<Exchange>> exchanges({bool refresh = false}) async {
    if (!refresh && _exchangeCache != null) return _exchangeCache!;

    List<Exchange> data;
    try {
      // 优先远端 JSON，失败后自动回退 CSV。
      data = await ExchangeFeed.fetch();
      exchangesFromRemote = true;
      lastExchangeError = null;
    } catch (error) {
      lastExchangeError = error.toString();
      // 已有缓存时保留旧数据，避免刷新失败把列表清空。
      if (_exchangeCache != null) return _exchangeCache!;
      await Future.delayed(_latency);
      data = mockExchanges;
      exchangesFromRemote = false;
    }

    // 按评分从高到低展示，评分相同则评价数多者优先。
    final sorted = [...data]
      ..sort((a, b) {
        final byRating = b.rating.compareTo(a.rating);
        return byRating != 0 ? byRating : b.reviews.compareTo(a.reviews);
      });
    return _exchangeCache = List.unmodifiable(sorted);
  }

  static Future<Exchange?> exchangeById(String id) async {
    final list = await exchanges();
    for (final e in list) {
      if (e.id == id) return e;
    }
    return null;
  }

  static Future<List<Coin>> coins({bool refresh = false}) async {
    if (!refresh && _coinCache != null) return _coinCache!;

    try {
      final live = await LiveMarketFeed.fetchCoins(mockCoins);
      if (live.isEmpty) throw Exception('没有可用的币种行情');
      coinsFromRemote = true;
      coinSource = LiveMarketFeed.lastSource;
      lastCoinError = null;
      _coinCache = List.unmodifiable(live);
    } catch (error) {
      lastCoinError = error.toString();
      debugPrint('币种行情获取失败，使用本地数据: $error');
      // 已有缓存时保留旧数据，避免刷新失败把列表清空。
      if (_coinCache != null) return _coinCache!;
      await Future.delayed(_latency);
      coinsFromRemote = false;
      coinSource = null;
      _coinCache = List.unmodifiable(mockCoins);
    }
    return _coinCache!;
  }

  /// 币种 K 线：优先币安 / 火币公开接口，失败时回退到内置的确定性模拟数据。
  static Future<List<Candle>> candles(
    Coin coin,
    String timeframe, {
    bool refresh = false,
    int count = 140,
  }) async {
    final key = '${coin.symbol}:$timeframe';
    if (!refresh && _candleCache[key] != null) return _candleCache[key]!;

    try {
      final live = await LiveMarketFeed.fetchCandles(
        coin,
        timeframe,
        limit: count,
      );
      if (live.isEmpty) throw Exception('没有可用的 K 线数据');
      _candleCache[key] = List.unmodifiable(live);
      return _candleCache[key]!;
    } catch (_) {
      // 不使用模拟数据覆盖远端缓存；下次切换周期或刷新时可以再次尝试。
      return MarketData.candles(coin, timeframe, count: count);
    }
  }

  static Future<Coin?> coinBySymbol(String symbol) async {
    final list = await coins();
    for (final c in list) {
      if (c.symbol == symbol) return c;
    }
    return null;
  }

  static Future<List<NewsItem>> news() async {
    if (_newsCache != null) return _newsCache!;
    await Future.delayed(_latency);
    return _newsCache = List.unmodifiable(buildMockNews());
  }

  static Future<NewsItem?> newsById(String id) async {
    final list = await news();
    for (final n in list) {
      if (n.id == id) return n;
    }
    return null;
  }
}
