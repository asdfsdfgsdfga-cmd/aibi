import 'package:flutter/material.dart';

import '../data/market_data.dart';
import '../data/repository.dart';
import '../l10n/app_strings.dart';
import '../models/coin.dart';
import '../models/exchange.dart';
import '../models/news.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/coin_row.dart';
import '../widgets/brand_mark.dart';
import '../widgets/indicators.dart';
import '../widgets/news_card.dart';
import '../widgets/ui_kit.dart';
import 'coin_detail_screen.dart';
import 'exchange_detail_screen.dart';
import 'news_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int tabIndex) onNavigateTab;
  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load({bool refresh = false}) async {
    final results = await Future.wait([
      Repository.exchanges(refresh: refresh),
      Repository.coins(refresh: refresh),
      Repository.news(),
    ]);
    return _HomeData(
      exchanges: results[0] as List<Exchange>,
      coins: results[1] as List<Coin>,
      news: results[2] as List<NewsItem>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<_HomeData>(
          future: _future,
          builder: (context, snap) {
            if (!snap.hasData) {
              return LoadingView(message: s.aggregating);
            }
            final data = snap.data!;
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                setState(() => _future = _load(refresh: true));
                await _future;
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 28),
                children: [
                  _header(context, s),
                  _marketHero(context, s, data.coins),
                  _riskAlert(context, s),
                  SectionHeader(
                    title: s.featuredExchanges,
                    action: s.viewAll,
                    onAction: () => widget.onNavigateTab(1),
                  ),
                  _featuredExchanges(data.exchanges),
                  SectionHeader(
                    title: s.topCoins,
                    action: s.allMarkets,
                    onAction: () => widget.onNavigateTab(2),
                  ),
                  ...data.coins
                      .take(4)
                      .map(
                        (c) => CoinRow(
                          coin: c,
                          spark: MarketData.sparkline(c),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CoinDetailScreen(coin: c),
                            ),
                          ),
                        ),
                      ),
                  SectionHeader(
                    title: s.industryNews,
                    action: s.moreNews,
                    onAction: () => widget.onNavigateTab(3),
                  ),
                  ...data.news
                      .take(3)
                      .map(
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppStrings s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          const BrandMark(size: 38),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'BIAIMX',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                s.tagline,
                style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SearchScreen())),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.border),
              ),
              child: Tooltip(
                message: s.searchHint,
                child: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.subtext,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketHero(BuildContext context, AppStrings s, List<Coin> coins) {
    final btc = coins.firstWhere(
      (c) => c.symbol == 'BTC',
      orElse: () => coins.first,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F6BFF), Color(0xFF1C9FE0), Color(0xFF14B8A6)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFFB8FFD9),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        s.marketOverview,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${btc.symbol}/USDT',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${formatPrice(btc.price)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            formatPercent(btc.change24h),
                            style: const TextStyle(
                              color: Color(0xFFCFFFE4),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '24h',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Sparkline(
                  data: MarketData.sparkline(btc),
                  color: Colors.white,
                  width: 96,
                  height: 44,
                  fill: false,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.16)),
            const SizedBox(height: 12),
            Row(
              children: [
                _heroStat(s.high24, formatPrice(btc.high24h)),
                _heroStat(s.low24, formatPrice(btc.low24h)),
                _heroStat(s.vol24Short, formatCompact(btc.volume24h)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskAlert(BuildContext context, AppStrings s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => _showRiskSheet(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.gpp_maybe_rounded,
                  size: 19,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.riskTitle,
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.riskBannerBody,
                      style: const TextStyle(
                        color: AppColors.subtext,
                        fontSize: 10.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.warning,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featuredExchanges(List<Exchange> exchanges) {
    final list = exchanges.where((e) => e.recommended).toList();
    final shown = list.isEmpty ? exchanges.take(4).toList() : list;
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: shown.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _FeaturedExchangeCard(exchange: shown[i]),
      ),
    );
  }
}

class _FeaturedExchangeCard extends StatelessWidget {
  final Exchange exchange;
  const _FeaturedExchangeCard({required this.exchange});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExchangeDetailScreen(exchangeId: exchange.id),
        ),
      ),
      child: Container(
        width: 156,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExchangeLogo(exchange: exchange, size: 38),
                const Spacer(),
                if (exchange.recommended)
                  const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: AppColors.cyan,
                  ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              exchange.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                RatingStars(rating: exchange.rating, size: 10.5),
                const SizedBox(width: 4),
                Text(
                  exchange.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: RiskBadge(level: exchange.riskLevel, compact: true),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    exchange.volume24h,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.subtext,
                      fontSize: 9.5,
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

class _HomeData {
  final List<Exchange> exchanges;
  final List<Coin> coins;
  final List<NewsItem> news;
  _HomeData({required this.exchanges, required this.coins, required this.news});
}

void _showRiskSheet(BuildContext context) {
  final s = AppStrings.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gpp_maybe_rounded, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.riskDisclaimerTitle,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              s.riskDisclaimerBody,
              style: const TextStyle(
                color: AppColors.subtext,
                fontSize: 13,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
