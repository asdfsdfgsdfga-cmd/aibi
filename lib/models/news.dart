import 'package:flutter/material.dart';

import 'localized_text.dart';

enum NewsCategory { all, industry, policy, exchange, project }

extension NewsCategoryX on NewsCategory {
  Color get color => switch (this) {
    NewsCategory.all => Colors.grey,
    NewsCategory.industry => const Color(0xFF4F8CFF),
    NewsCategory.policy => const Color(0xFFF5B544),
    NewsCategory.exchange => const Color(0xFF22D3EE),
    NewsCategory.project => const Color(0xFFB07CFF),
  };
}

class NewsItem {
  final String id;
  final L10nText title;
  final L10nText summary;
  final List<L10nText> content;
  final NewsCategory category;
  final L10nText source;
  final DateTime publishedAt;
  final int readMinutes;
  final List<L10nText> tags;
  final bool hot;

  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.source,
    required this.publishedAt,
    required this.readMinutes,
    required this.tags,
    this.hot = false,
  });
}
