import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/exchange.dart';
import '../theme/app_theme.dart';
import 'indicators.dart';
import 'ui_kit.dart';

class ExchangeCard extends StatelessWidget {
  final Exchange exchange;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  const ExchangeCard({
    super.key,
    required this.exchange,
    required this.onTap,
    this.isFavorite = false,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExchangeLogo(exchange: exchange, size: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              exchange.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (exchange.recommended) ...[
                            const SizedBox(width: 6),
                            Tag(label: s.recommended, color: AppColors.cyan),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          RatingStars(rating: exchange.rating, size: 12),
                          const SizedBox(width: 5),
                          Text(
                            exchange.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              s.reviews(exchange.reviews),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: [
                          for (final t in exchange.marketTypes.take(3))
                            Tag(
                              label: t.label.of(context),
                              color: AppColors.subtext,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (onFavorite != null)
                      GestureDetector(
                        onTap: onFavorite,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Icon(
                            isFavorite
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 20,
                            color: isFavorite
                                ? AppColors.gold
                                : AppColors.muted,
                          ),
                        ),
                      ),
                    Text(
                      exchange.volume24h,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.volume24h,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                RiskBadge(level: exchange.riskLevel),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exchange.riskTags.first.of(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
