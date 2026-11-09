import 'package:flutter/material.dart';

import '../models/coin.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'indicators.dart';
import 'ui_kit.dart';

class CoinBadge extends StatelessWidget {
  final Coin coin;
  final double size;
  const CoinBadge({super.key, required this.coin, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            coin.color.withValues(alpha: 0.9),
            coin.color.withValues(alpha: 0.45),
          ],
        ),
      ),
      child: Center(
        child: Text(
          coin.symbol.substring(0, coin.symbol.length > 1 ? 2 : 1),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.3,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class CoinRow extends StatelessWidget {
  final Coin coin;
  final List<double> spark;
  final VoidCallback onTap;

  const CoinRow({
    super.key,
    required this.coin,
    required this.spark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = coin.isUp ? AppColors.up : AppColors.down;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            CoinBadge(coin: coin),
            const SizedBox(width: 11),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.symbol,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coin.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: Sparkline(
                  data: spark,
                  color: color,
                  width: 62,
                  height: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatPrice(coin.price),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 3),
                  ChangeText(
                    coin.change24h,
                    fontSize: 11.5,
                    withBackground: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
