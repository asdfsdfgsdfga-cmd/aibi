import 'package:flutter/material.dart';

/// BIAIMX 品牌标识：官方 3D 立体「B + 上升箭头」徽标。
///
/// 与应用启动图标使用同一张图，保证品牌一致性。
class BrandMark extends StatelessWidget {
  final double size;
  final double radius;

  const BrandMark({super.key, this.size = 38, this.radius = 11});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        'assets/branding/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'BIAIMX',
      ),
    );
  }
}
