import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'localized_text.dart';

enum RiskLevel { low, medium, high }

extension RiskLevelX on RiskLevel {
  Color get color => switch (this) {
    RiskLevel.low => AppColors.up,
    RiskLevel.medium => AppColors.warning,
    RiskLevel.high => AppColors.danger,
  };

  IconData get icon => switch (this) {
    RiskLevel.low => Icons.verified_user_rounded,
    RiskLevel.medium => Icons.shield_outlined,
    RiskLevel.high => Icons.warning_amber_rounded,
  };
}

/// 市场类型：用于筛选与展示，展示文案随语言切换。
enum MarketType {
  spot,
  futures,
  options,
  earn,
  web3,
  custody,
  staking,
  fiat,
  copyTrade,
  margin,
  payment,
  institutional,
  lending,
}

extension MarketTypeX on MarketType {
  L10nText get label => switch (this) {
    MarketType.spot => const L10nText('Spot', '現貨'),
    MarketType.futures => const L10nText('Futures', '合約'),
    MarketType.options => const L10nText('Options', '期權'),
    MarketType.earn => const L10nText('Earn', '理財'),
    MarketType.web3 => const L10nText('Web3', 'Web3'),
    MarketType.custody => const L10nText('Custody', '託管'),
    MarketType.staking => const L10nText('Staking', '質押'),
    MarketType.fiat => const L10nText('Fiat', '法幣'),
    MarketType.copyTrade => const L10nText('Copy trading', '跟單'),
    MarketType.margin => const L10nText('Margin', '槓桿'),
    MarketType.payment => const L10nText('Payments', '支付'),
    MarketType.institutional => const L10nText('Institutional', '機構'),
    MarketType.lending => const L10nText('Lending', '借貸'),
  };
}

/// 评分维度（每项满分 5 分）
enum RatingDimension { security, liquidity, fees, experience, support }

/// 评分拆解（每项满分 5 分）
class RatingBreakdown {
  final double security;
  final double liquidity;
  final double fees;
  final double experience;
  final double support;

  const RatingBreakdown({
    required this.security,
    required this.liquidity,
    required this.fees,
    required this.experience,
    required this.support,
  });

  List<MapEntry<RatingDimension, double>> get entries => [
    MapEntry(RatingDimension.security, security),
    MapEntry(RatingDimension.liquidity, liquidity),
    MapEntry(RatingDimension.fees, fees),
    MapEntry(RatingDimension.experience, experience),
    MapEntry(RatingDimension.support, support),
  ];
}

class Exchange {
  final String id;
  final String name;
  final String logoText;
  final Color brandColor;
  final double rating;
  final int reviews;
  final RiskLevel riskLevel;
  final List<L10nText> riskTags;
  final String volume24h;
  final int coinsCount;
  final String makerFee;
  final String takerFee;
  final L10nText country;
  final String established;
  final L10nText description;
  final List<L10nText> features;
  final List<MarketType> marketTypes;
  final RatingBreakdown breakdown;
  final bool recommended;
  final String website;

  const Exchange({
    required this.id,
    required this.name,
    required this.logoText,
    required this.brandColor,
    required this.rating,
    required this.reviews,
    required this.riskLevel,
    required this.riskTags,
    required this.volume24h,
    required this.coinsCount,
    required this.makerFee,
    required this.takerFee,
    required this.country,
    required this.established,
    required this.description,
    required this.features,
    required this.marketTypes,
    required this.breakdown,
    required this.recommended,
    required this.website,
  });

  double get score => rating * 20;
}
