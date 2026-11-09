import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repository.dart';
import '../l10n/app_strings.dart';
import '../models/exchange.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/indicators.dart';
import '../widgets/ui_kit.dart';
import 'web_preview_screen.dart';

class ExchangeDetailScreen extends StatefulWidget {
  final String exchangeId;
  const ExchangeDetailScreen({super.key, required this.exchangeId});

  @override
  State<ExchangeDetailScreen> createState() => _ExchangeDetailScreenState();
}

class _ExchangeDetailScreenState extends State<ExchangeDetailScreen> {
  late Future<Exchange?> _future;

  @override
  void initState() {
    super.initState();
    _future = Repository.exchangeById(widget.exchangeId);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(s.exchangeDetail),
        actions: [
          FutureBuilder<Exchange?>(
            future: _future,
            builder: (context, snap) {
              final e = snap.data;
              if (e == null) return const SizedBox.shrink();
              final fav = appState.isFavorite(e.id);
              return IconButton(
                onPressed: () => appState.toggleFavorite(e.id),
                icon: Icon(
                  fav ? Icons.star_rounded : Icons.star_border_rounded,
                  color: fav ? AppColors.gold : AppColors.subtext,
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: FutureBuilder<Exchange?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return LoadingView(message: s.loadingExchange);
          }
          final e = snap.data;
          if (e == null) return EmptyView(message: s.exchangeNotFound);
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, e),
                _visitButton(context, e),
                _stats(context, e),
                _ratingSection(context, e),
                _myRatingSection(context, e, appState),
                _riskSection(context, e),
                _aboutSection(context, e),
                _feesSection(context, e),
                _disclaimer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, Exchange e) {
    final s = AppStrings.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [e.brandColor.withValues(alpha: 0.18), AppColors.surface],
          ),
        ),
        child: Row(
          children: [
            ExchangeLogo(exchange: e, size: 58),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          e.name,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (e.recommended) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          size: 17,
                          color: AppColors.cyan,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingStars(rating: e.rating, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        e.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        s.reviews(e.reviews),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RiskBadge(level: e.riskLevel),
                      const SizedBox(width: 8),
                      Text(
                        s.established(e.established),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部主操作：在应用内 WebView 预览交易所官网。
  Widget _visitButton(BuildContext context, Exchange e) {
    final s = AppStrings.of(context);
    final host =
        Uri.tryParse(e.website)?.host.replaceFirst('www.', '') ?? e.website;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Semantics(
        button: true,
        label: s.websiteTitle(e.name),
        child: GestureDetector(
          onTap: () => WebPreviewScreen.open(
            context,
            url: e.website,
            title: s.websiteTitle(e.name),
          ),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.visitSite,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.websiteSubtitle(host),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stats(BuildContext context, Exchange e) {
    final s = AppStrings.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _stat(s.volume24h, e.volume24h),
            _divider(),
            _stat(s.supportedCoins, '${e.coinsCount}+'),
            _divider(),
            _stat(s.country, e.country.of(context)),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 30, color: AppColors.border);

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingSection(BuildContext context, Exchange e) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: s.overallRating),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              e.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 40,
                                height: 1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 5,
                                left: 3,
                              ),
                              child: Text(
                                '/ 5.0',
                                style: TextStyle(
                                  color: AppColors.subtext.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        RatingStars(rating: e.rating, size: 15),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            e.score.toStringAsFixed(0),
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            s.overallScore,
                            style: const TextStyle(
                              color: AppColors.subtext,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...e.breakdown.entries.map((entry) {
                  final label = switch (entry.key) {
                    RatingDimension.security => s.breakdownSecurity,
                    RatingDimension.liquidity => s.breakdownLiquidity,
                    RatingDimension.fees => s.breakdownFees,
                    RatingDimension.experience => s.breakdownExperience,
                    RatingDimension.support => s.breakdownSupport,
                  };
                  return _scoreBar(label, entry.value);
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _scoreBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.subtext, fontSize: 11.5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(height: 6, color: AppColors.surfaceHigh),
                  FractionallySizedBox(
                    widthFactor: (value / 5).clamp(0.0, 1.0),
                    child: Container(
                      height: 6,
                      decoration: const BoxDecoration(
                        gradient: AppColors.goldGradient,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 26,
            child: Text(
              value.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 用户评分：点击星星为本平台打分，保存在本机。
  Widget _myRatingSection(BuildContext context, Exchange e, AppState appState) {
    final s = AppStrings.of(context);
    final myRating = appState.ratingOf(e.id);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                Text(
                  s.myRating,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (myRating != null)
                  Text(
                    s.ratingValue(myRating.toStringAsFixed(1)),
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Semantics(
                      button: true,
                      label: '$i',
                      child: GestureDetector(
                        onTap: () =>
                            _rate(context, appState, e.id, i.toDouble()),
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          (myRating ?? 0) >= i
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 30,
                          color: (myRating ?? 0) >= i
                              ? AppColors.gold
                              : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    myRating == null ? s.tapToRate : s.ratingSaved,
                    maxLines: 2,
                    style: const TextStyle(
                      color: AppColors.subtext,
                      fontSize: 10.5,
                      height: 1.35,
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

  void _rate(BuildContext context, AppState appState, String id, double value) {
    final s = AppStrings.of(context);
    final hadRating = appState.ratingOf(id) != null;
    appState.rateExchange(id, value);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceHigh,
          duration: const Duration(seconds: 2),
          content: Text(
            '${hadRating ? s.ratingUpdated : s.ratingThanks} · ${value.toStringAsFixed(1)}',
            style: const TextStyle(color: AppColors.text, fontSize: 12.5),
          ),
        ),
      );
  }

  Widget _riskSection(BuildContext context, Exchange e) {
    final s = AppStrings.of(context);
    final riskDesc = switch (e.riskLevel) {
      RiskLevel.low => s.riskLowDesc,
      RiskLevel.medium => s.riskMediumDesc,
      RiskLevel.high => s.riskHighDesc,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: s.riskTitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: e.riskLevel.color.withValues(alpha: 0.32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RiskBadge(level: e.riskLevel),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        riskDesc,
                        style: const TextStyle(
                          color: AppColors.subtext,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...e.riskTags.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: e.riskLevel.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            t.of(context),
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 12.5,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          s.riskTagsNote,
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontSize: 10.5,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _aboutSection(BuildContext context, Exchange e) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: s.intro),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.description.of(context),
                style: AppTheme.body.copyWith(color: AppColors.subtext),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: e.features
                    .map(
                      (f) => Tag(
                        label: f.of(context),
                        color: AppColors.primary,
                        filled: true,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _feesSection(BuildContext context, Exchange e) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: s.fees),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _feeCard(
                  s.makerFee,
                  e.makerFee,
                  Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _feeCard(
                  s.takerFee,
                  e.takerFee,
                  Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _feeCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _disclaimer() {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: DisclaimerBanner(),
    );
  }
}
