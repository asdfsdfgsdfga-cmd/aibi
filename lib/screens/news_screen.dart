import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../l10n/app_strings.dart';
import '../models/news.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/news_card.dart';
import '../widgets/ui_kit.dart';
import 'news_detail_screen.dart';
import 'search_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<NewsItem>> _future;
  NewsCategory _category = NewsCategory.all;

  @override
  void initState() {
    super.initState();
    _future = Repository.news();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  Text(s.newsTitle, style: AppTheme.headline),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                    child: Tooltip(
                      message: s.searchHint,
                      child: const Icon(
                        Icons.search_rounded,
                        color: AppColors.subtext,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: NewsCategory.values.map((c) {
                  final active = _category == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _category = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: active
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          s.newsCategoryLabel(c),
                          style: TextStyle(
                            color: active ? Colors.white : AppColors.subtext,
                            fontSize: 12,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<NewsItem>>(
                future: _future,
                builder: (context, snap) {
                  if (!snap.hasData) return const LoadingView();
                  final all = snap.data!;
                  final list = _category == NewsCategory.all
                      ? all
                      : all.where((n) => n.category == _category).toList();
                  if (list.isEmpty) {
                    return EmptyView(
                      message: s.emptyCategory,
                      icon: Icons.article_outlined,
                    );
                  }
                  final featured = list.first;
                  final rest = list.skip(1).toList();
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      _featured(s, featured),
                      const SizedBox(height: 12),
                      ...rest.map(
                        (n) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: NewsCard(
                            news: n,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NewsDetailScreen(newsId: n.id),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const DisclaimerBanner(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featured(AppStrings s, NewsItem n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NewsDetailScreen(newsId: n.id)),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: n.category.color.withValues(alpha: 0.32)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                n.category.color.withValues(alpha: 0.16),
                AppColors.surface,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Tag(
                    label: s.newsCategoryLabel(n.category),
                    color: n.category.color,
                    filled: true,
                  ),
                  const SizedBox(width: 6),
                  if (n.hot)
                    Tag(
                      label: s.featured,
                      color: AppColors.danger,
                      filled: true,
                    ),
                  const Spacer(),
                  Text(
                    timeAgo(n.publishedAt, isZh: s.isZh),
                    style: AppTheme.caption,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                n.title.of(context),
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                n.summary.of(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.subtext,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      n.source.of(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '· ${s.readMinutes(n.readMinutes)}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10.5,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: AppColors.subtext,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
