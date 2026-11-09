import 'dart:math' as math;

import '../models/candle.dart';
import '../models/coin.dart';

/// 行情数据服务：生成确定性的 K 线与走势数据。
/// 同一币种 + 周期每次生成一致，便于界面稳定展示。
class MarketData {
  static const timeframes = ['15m', '1h', '4h', '1d'];

  static const _periodMs = <String, int>{
    '15m': 15 * 60 * 1000,
    '1h': 60 * 60 * 1000,
    '4h': 4 * 60 * 60 * 1000,
    '1d': 24 * 60 * 60 * 1000,
  };

  static const _volatility = <String, double>{
    '15m': 0.0035,
    '1h': 0.008,
    '4h': 0.018,
    '1d': 0.042,
  };

  static int _seed(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0x7fffffff;
    }
    return h;
  }

  static double _gauss(math.Random r) {
    final u1 = 1 - r.nextDouble();
    final u2 = r.nextDouble();
    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
  }

  static List<Candle> candles(Coin coin, String timeframe, {int count = 140}) {
    final period = _periodMs[timeframe] ?? _periodMs['1h']!;
    final vol = _volatility[timeframe] ?? 0.008;
    final rnd = math.Random(_seed('${coin.symbol}-$timeframe'));

    // 从当前价向前回溯，再反转成时间正序
    final rev = <double>[coin.price];
    var p = coin.price;
    for (var i = 1; i < count; i++) {
      p = p / (1 + _gauss(rnd) * vol);
      rev.add(p);
    }
    final closes = rev.reversed.toList();

    final endMs = (DateTime.now().millisecondsSinceEpoch ~/ period) * period;
    final candles = <Candle>[];
    for (var i = 0; i < count; i++) {
      final open = i == 0 ? closes[0] : closes[i - 1];
      final close = closes[i];
      final hi = math.max(open, close) * (1 + _gauss(rnd).abs() * vol * 0.55);
      final lo = math.min(open, close) * (1 - _gauss(rnd).abs() * vol * 0.55);
      final dayFraction = period / 86400000;
      final volume =
          coin.volume24h * dayFraction * (0.45 + rnd.nextDouble() * 1.15);
      candles.add(
        Candle(
          time: DateTime.fromMillisecondsSinceEpoch(
            endMs - (count - 1 - i) * period,
          ),
          open: open,
          high: hi,
          low: lo,
          close: close,
          volume: volume,
        ),
      );
    }
    return candles;
  }

  /// 迷你走势图数据（用于列表里的 sparkline）
  static List<double> sparkline(Coin coin, {int count = 32}) {
    final rnd = math.Random(_seed('spark-${coin.symbol}'));
    final out = <double>[];
    var p = coin.price * (1 - coin.change24h / 100);
    for (var i = 0; i < count; i++) {
      p = p * (1 + _gauss(rnd) * 0.012);
      out.add(p);
    }
    // 缩放，使终值贴近当前价
    final scale = coin.price / out.last;
    return out.map((e) => e * scale).toList();
  }

  /// 简单均线
  static List<double?> movingAverage(List<Candle> candles, int period) {
    final out = <double?>[];
    double sum = 0;
    for (var i = 0; i < candles.length; i++) {
      sum += candles[i].close;
      if (i >= period) sum -= candles[i - period].close;
      out.add(i >= period - 1 ? sum / period : null);
    }
    return out;
  }
}
