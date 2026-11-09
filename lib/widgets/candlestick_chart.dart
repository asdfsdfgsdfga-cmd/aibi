import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/candle.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// 自绘 K 线图：蜡烛 + 成交量 + 均线 + 触摸十字光标。
class CandlestickChart extends StatefulWidget {
  final List<Candle> candles;
  final String timeframe;
  final double height;

  const CandlestickChart({
    super.key,
    required this.candles,
    required this.timeframe,
    this.height = 300,
  });

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  int? _selected;

  static const _leftPad = 8.0;
  static const _rightPad = 58.0;

  void _updateSelection(double dx, double width) {
    if (widget.candles.isEmpty) return;
    final chartW = width - _leftPad - _rightPad;
    final n = widget.candles.length;
    if (chartW <= 0) return;
    final idx = ((dx - _leftPad) / chartW * n).floor();
    setState(() => _selected = idx.clamp(0, n - 1));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _updateSelection(d.localPosition.dx, width),
          onTapUp: (_) => setState(() => _selected = null),
          onHorizontalDragStart: (d) =>
              _updateSelection(d.localPosition.dx, width),
          onHorizontalDragUpdate: (d) =>
              _updateSelection(d.localPosition.dx, width),
          onHorizontalDragEnd: (_) => setState(() => _selected = null),
          child: CustomPaint(
            size: Size(width, widget.height),
            painter: _CandlePainter(
              candles: widget.candles,
              timeframe: widget.timeframe,
              selected: _selected,
              openLabel: s.candleOpen,
              highLabel: s.candleHigh,
              lowLabel: s.candleLow,
              closeLabel: s.candleClose,
              volumeLabel: s.candleVolume,
            ),
          ),
        );
      },
    );
  }
}

class _CandlePainter extends CustomPainter {
  final List<Candle> candles;
  final String timeframe;
  final int? selected;
  final String openLabel;
  final String highLabel;
  final String lowLabel;
  final String closeLabel;
  final String volumeLabel;

  _CandlePainter({
    required this.candles,
    required this.timeframe,
    this.selected,
    required this.openLabel,
    required this.highLabel,
    required this.lowLabel,
    required this.closeLabel,
    required this.volumeLabel,
  });

  static const _leftPad = 8.0;
  static const _rightPad = 58.0;
  static const _topPad = 10.0;
  static const _timeH = 18.0;
  static const _volRatio = 0.22;
  static const _gap = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final chartW = size.width - _leftPad - _rightPad;
    final priceH = (size.height - _timeH - _topPad - _gap) * (1 - _volRatio);
    final volH = (size.height - _timeH - _topPad - _gap) * _volRatio;
    final priceTop = _topPad;
    final priceBottom = priceTop + priceH;
    final volTop = priceBottom + _gap;
    final volBottom = volTop + volH;

    // 均线
    final ma5 = _ma(5);
    final ma10 = _ma(10);
    final ma20 = _ma(20);

    var min = candles.first.low;
    var max = candles.first.high;
    for (final c in candles) {
      if (c.low < min) min = c.low;
      if (c.high > max) max = c.high;
    }
    for (final list in [ma5, ma10, ma20]) {
      for (final v in list) {
        if (v == null) continue;
        if (v < min) min = v;
        if (v > max) max = v;
      }
    }
    final pad = (max - min) * 0.06;
    min -= pad;
    max += pad;
    final range = max - min == 0 ? 1.0 : max - min;

    double yPrice(double p) => priceBottom - (p - min) / range * priceH;
    double xAt(int i) => _leftPad + (i + 0.5) * chartW / candles.length;

    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.65)
      ..strokeWidth = 0.6;

    // 网格 + 价格标签
    for (var i = 0; i <= 4; i++) {
      final y = priceTop + priceH * i / 4;
      canvas.drawLine(
        Offset(_leftPad, y),
        Offset(_leftPad + chartW, y),
        gridPaint,
      );
      final price = max - range * i / 4;
      _text(
        canvas,
        formatPrice(price),
        Offset(_leftPad + chartW + 6, y - 6),
        color: AppColors.subtext,
        size: 9,
      );
    }

    // 成交量柱
    var maxVol = 0.0;
    for (final c in candles) {
      if (c.volume > maxVol) maxVol = c.volume;
    }
    final bodyW = (chartW / candles.length * 0.62).clamp(1.0, 9.0);
    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final x = xAt(i);
      final h = maxVol == 0 ? 0.0 : c.volume / maxVol * volH;
      final color = (c.isUp ? AppColors.up : AppColors.down).withValues(
        alpha: 0.35,
      );
      canvas.drawRect(
        Rect.fromLTWH(x - bodyW / 2, volBottom - h, bodyW, h),
        Paint()..color = color,
      );
    }

    // 蜡烛
    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final x = xAt(i);
      final color = c.isUp ? AppColors.up : AppColors.down;
      final paint = Paint()..color = color;
      final wickPaint = Paint()
        ..color = color
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(x, yPrice(c.high)),
        Offset(x, yPrice(c.low)),
        wickPaint,
      );
      final top = yPrice(c.isUp ? c.close : c.open);
      final bottom = yPrice(c.isUp ? c.open : c.close);
      final rectH = (bottom - top).abs().clamp(1.0, priceH);
      canvas.drawRect(Rect.fromLTWH(x - bodyW / 2, top, bodyW, rectH), paint);
    }

    // 均线
    _drawLine(canvas, ma5, xAt, yPrice, AppColors.gold);
    _drawLine(canvas, ma10, xAt, yPrice, AppColors.cyan);
    _drawLine(canvas, ma20, xAt, yPrice, const Color(0xFFB07CFF));

    // 最新价虚线
    final last = candles.last;
    final lastColor = last.isUp ? AppColors.up : AppColors.down;
    final lastY = yPrice(last.close);
    _dashedLine(
      canvas,
      Offset(_leftPad, lastY),
      Offset(_leftPad + chartW, lastY),
      Paint()
        ..color = lastColor.withValues(alpha: 0.7)
        ..strokeWidth = 0.8,
    );
    final tagRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(_leftPad + chartW + 2, lastY - 8, _rightPad - 6, 16),
      const Radius.circular(3),
    );
    canvas.drawRRect(tagRect, Paint()..color = lastColor);
    _text(
      canvas,
      formatPrice(last.close),
      Offset(_leftPad + chartW + 6, lastY - 7),
      color: Colors.white,
      size: 9,
    );

    // 时间轴标签
    final labelStep = (candles.length / 4).ceil();
    for (var i = 0; i < candles.length; i += labelStep) {
      _text(
        canvas,
        formatChartTime(candles[i].time, timeframe),
        Offset(xAt(i) - 22, volBottom + 4),
        color: AppColors.muted,
        size: 8.5,
      );
    }

    // 十字光标
    if (selected != null) {
      _paintCrosshair(
        canvas,
        size,
        selected!,
        xAt,
        yPrice,
        chartW,
        priceTop,
        priceBottom,
        volTop,
        volBottom,
      );
    }
  }

  void _paintCrosshair(
    Canvas canvas,
    Size size,
    int index,
    double Function(int) xAt,
    double Function(double) yPrice,
    double chartW,
    double priceTop,
    double priceBottom,
    double volTop,
    double volBottom,
  ) {
    final c = candles[index];
    final x = xAt(index);
    final y = yPrice(c.close);
    final cp = Paint()
      ..color = AppColors.text.withValues(alpha: 0.45)
      ..strokeWidth = 0.7;
    _dashedLine(canvas, Offset(x, priceTop), Offset(x, volBottom), cp);
    _dashedLine(canvas, Offset(_leftPad, y), Offset(_leftPad + chartW, y), cp);

    // 时间标签
    final timeLabel = formatChartTime(c.time, timeframe);
    final tRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - 34, volBottom + 2, 68, 14),
      const Radius.circular(3),
    );
    canvas.drawRRect(tRect, Paint()..color = AppColors.surfaceHigh);
    _text(
      canvas,
      timeLabel,
      Offset(x - 30, volBottom + 3.5),
      color: AppColors.text,
      size: 8.5,
    );

    // 信息浮层
    final lines = <String>[
      '$openLabel ${formatPrice(c.open)}',
      '$highLabel ${formatPrice(c.high)}',
      '$lowLabel ${formatPrice(c.low)}',
      '$closeLabel ${formatPrice(c.close)}',
      '$volumeLabel ${formatCompactNoSymbol(c.volume)}',
    ];
    const boxW = 104.0;
    const lineH = 13.0;
    final boxH = lines.length * lineH + 10;
    final boxX = x > size.width / 2
        ? _leftPad + 4
        : _leftPad + chartW - boxW - 4;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxX, priceTop + 4, boxW, boxH),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = AppColors.surfaceHigh.withValues(alpha: 0.96),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    for (var i = 0; i < lines.length; i++) {
      _text(
        canvas,
        lines[i],
        Offset(boxX + 8, priceTop + 7 + i * lineH),
        color: i == 3
            ? (c.isUp ? AppColors.up : AppColors.down)
            : AppColors.text,
        size: 9.5,
      );
    }
  }

  List<double?> _ma(int period) {
    final out = <double?>[];
    double sum = 0;
    for (var i = 0; i < candles.length; i++) {
      sum += candles[i].close;
      if (i >= period) sum -= candles[i - period].close;
      out.add(i >= period - 1 ? sum / period : null);
    }
    return out;
  }

  void _drawLine(
    Canvas canvas,
    List<double?> values,
    double Function(int) xAt,
    double Function(double) yPrice,
    Color color,
  ) {
    final path = Path();
    var started = false;
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == null) continue;
      final point = Offset(xAt(i), yPrice(v));
      if (!started) {
        path.moveTo(point.dx, point.dy);
        started = true;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    if (!started) return;
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 3.0;
    const gap = 3.0;
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final end = (d + dash).clamp(0.0, total);
      canvas.drawLine(a + dir * d, a + dir * end, paint);
      d += dash + gap;
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset offset, {
    required Color color,
    required double size,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _CandlePainter oldDelegate) =>
      oldDelegate.candles != candles || oldDelegate.selected != selected;
}
