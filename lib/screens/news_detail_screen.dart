import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../l10n/app_strings.dart';
import '../models/news.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/brand_mark.dart';
import '../widgets/ui_kit.dart';

class NewsDetailScreen extends StatefulWidget {
  final String newsId;
  const NewsDetailScreen({super.key, required this.newsId});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late Future<NewsItem?> _future;

  @override
  void initState() {
    super.initState();
    _future = Repository.newsById(widget.newsId);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.newsDetail),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.share_outlined,
              size: 20,
              color: AppColors.subtext,
            ),
          ),
        ],
      ),
      body: FutureBuilder<NewsItem?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          final n = snap.data;
          if (n == null) return EmptyView(message: s.newsNotFound);
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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
                          if (n.hot) ...[
                            const SizedBox(width: 6),
                            Tag(
                              label: s.featured,
                              color: AppColors.danger,
                              filled: true,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        n.title.of(context),
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          height: 1.45,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const BrandMark(size: 28, radius: 8),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              n.source.of(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${timeAgo(n.publishedAt, isZh: s.isZh)} · ${s.readMinutes(n.readMinutes)}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(height: 1, color: AppColors.border),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),

                // 正文
                ...n.content.map(
                  (p) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      p.of(context),
                      style: const TextStyle(
                        color: Color(0xFFCBD3DF),
                        fontSize: 14.5,
                        height: 1.85,
                      ),
                    ),
                  ),
                ),

                // 标签
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: n.tags
                        .map(
                          (t) => Tag(
                            label: '# ${t.of(context)}',
                            color: AppColors.primary,
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 18),
                DisclaimerBanner(text: s.newsDisclaimer),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 18,
                          color: AppColors.subtext,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.readMoreNews,
                            style: const TextStyle(
                              color: AppColors.subtext,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            s.backToList,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
