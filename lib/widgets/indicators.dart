import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/exchange.dart';
import '../theme/app_theme.dart';

class ExchangeLogo extends StatelessWidget {
  final Exchange exchange;
  final double size;

  const ExchangeLogo({super.key, required this.exchange, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final fg = exchange.brandColor.computeLuminance() > 0.62
        ? Colors.black
        : Colors.white;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            exchange.brandColor.withValues(alpha: 0.95),
            exchange.brandColor.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: exchange.brandColor.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          exchange.logoText,
          style: TextStyle(
            color: fg,
            fontSize: size * 0.34,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 13,
    this.color = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 5,
      height: size,
      child: Stack(
        children: [
          Row(
            children: List.generate(
              5,
              (_) =>
                  Icon(Icons.star_rounded, size: size, color: AppColors.border),
            ),
          ),
          ClipRect(
            clipper: _FractionClipper((rating / 5).clamp(0.0, 1.0)),
            child: Row(
              children: List.generate(
                5,
                (_) => Icon(Icons.star_rounded, size: size, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FractionClipper extends CustomClipper<Rect> {
  final double fraction;
  _FractionClipper(this.fraction);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(covariant _FractionClipper oldClipper) =>
      oldClipper.fraction != fraction;
}

class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final bool compact;

  const RiskBadge({super.key, required this.level, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = level.color;
    final label = AppStrings.of(context).riskLevelLabel(level);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3.5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(level.icon, size: compact ? 10 : 11.5, color: color),
          const SizedBox(width: 3.5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 9.5 : 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double width;
  final double height;
  final bool fill;

  const Sparkline({
    super.key,
    required this.data,
    required this.color,
    this.width = 68,
    this.height = 28,
    this.fill = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(data: data, color: color, fill: fill),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final bool fill;

  _SparklinePainter({
    required this.data,
    required this.color,
    required this.fill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = (max - min) == 0 ? 1.0 : (max - min);
    final dx = size.width / (data.length - 1);

    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - (data[i] - min) / range * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (fill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      final shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(fillPath, Paint()..shader = shader);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}
