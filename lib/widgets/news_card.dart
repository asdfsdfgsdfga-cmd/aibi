import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/news.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'ui_kit.dart';

class NewsCard extends StatelessWidget {
  final NewsItem news;
  final VoidCallback onTap;
  final bool compact;

  const NewsCard({
    super.key,
    required this.news,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Tag(
                  label: s.newsCategoryLabel(news.category),
                  color: news.category.color,
                  filled: true,
                ),
                if (news.hot) ...[
                  const SizedBox(width: 6),
                  const Tag(
                    label: 'HOT',
                    color: AppColors.danger,
                    filled: true,
                  ),
                ],
                const Spacer(),
                Text(
                  timeAgo(news.publishedAt, isZh: s.isZh),
                  style: AppTheme.caption,
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              news.title.of(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text,
                fontSize: compact ? 14 : 15,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 6),
              Text(
                news.summary.of(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.subtext,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: Text(
                    news.source.of(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 2,
                  height: 2,
                  decoration: const BoxDecoration(
                    color: AppColors.muted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  s.readMinutes(news.readMinutes),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10.5,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
