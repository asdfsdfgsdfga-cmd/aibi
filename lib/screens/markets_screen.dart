import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/market_data.dart';
import '../data/repository.dart';
import '../l10n/app_strings.dart';
import '../models/coin.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/coin_row.dart';
import '../widgets/ui_kit.dart';
import 'coin_detail_screen.dart';
import 'search_screen.dart';

enum _MarketFilter { all, gainers, losers, favorite }

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  late Future<List<Coin>> _future;
  _MarketFilter _filter = _MarketFilter.all;

  @override
  void initState() {
    super.initState();
    _future = Repository.coins();
  }

  /// 下拉刷新：跳过缓存重新拉取币安 / 火币实时行情。
  Future<void> _reload() async {
    try {
      final list = await Repository.coins(refresh: true);
      if (!mounted) return;
      setState(() => _future = Future.value(list));
    } catch (_) {
      // Repository 内部已做兜底，这里保持旧列表即可。
    }
  }

  String _filterLabel(AppStrings s, _MarketFilter filter) => switch (filter) {
    _MarketFilter.all => s.filterAll,
    _MarketFilter.gainers => s.filterGainers,
    _MarketFilter.losers => s.filterLosers,
    _MarketFilter.favorite => s.filterWatchlist,
  };

  List<Coin> _apply(List<Coin> list, AppState state) {
    final result = [...list];
    switch (_filter) {
      case _MarketFilter.all:
        return result;
      case _MarketFilter.gainers:
        result.sort((a, b) => b.change24h.compareTo(a.change24h));
        return result;
      case _MarketFilter.losers:
        result.sort((a, b) => a.change24h.compareTo(b.change24h));
        return result;
      case _MarketFilter.favorite:
        return result
            .where((c) => state.isFavorite('coin:${c.symbol}'))
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final state = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Coin>>(
          future: _future,
          builder: (context, snap) {
            final coins = snap.data ?? const <Coin>[];
            final totalCap = coins.fold<double>(
              0,
              (sum, c) => sum + c.marketCap,
            );
            final totalVol = coins.fold<double>(
              0,
              (sum, c) => sum + c.volume24h,
            );
            final upCount = coins.where((c) => c.isUp).length;
            final downCount = coins.length - upCount;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Row(
                    children: [
                      Text(s.marketsTitle, style: AppTheme.headline),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _summary(
                          s.totalMarketCap,
                          formatCompact(totalCap),
                          AppColors.text,
                        ),
                        _vline(),
                        _summary(
                          s.volume24h,
                          formatCompact(totalVol),
                          AppColors.text,
                        ),
                        _vline(),
                        _summary(
                          s.upDown,
                          '$upCount / $downCount',
                          upCount >= downCount ? AppColors.up : AppColors.down,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: _MarketFilter.values.map((f) {
                      final active = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: active
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              _filterLabel(s, f),
                              style: TextStyle(
                                color: active
                                    ? Colors.white
                                    : AppColors.subtext,
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
                const SizedBox(height: 8),
                Expanded(
                  child: !snap.hasData
                      ? const LoadingView()
                      : _list(s, _apply(coins, state)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summary(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vline() => Container(
    width: 1,
    height: 26,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: AppColors.border,
  );

  Widget _list(AppStrings s, List<Coin> coins) {
    if (coins.isEmpty) {
      return EmptyView(
        message: s.emptyWatchlist,
        icon: Icons.star_border_rounded,
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: _reload,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: coins.length + 1,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          indent: 20,
          endIndent: 20,
          color: AppColors.border,
        ),
        itemBuilder: (context, i) {
          if (i == coins.length) {
            return const Padding(
              padding: EdgeInsets.only(top: 10),
              child: DisclaimerBanner(),
            );
          }
          final c = coins[i];
          return CoinRow(
            coin: c,
            spark: MarketData.sparkline(c),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CoinDetailScreen(coin: c)),
            ),
          );
        },
      ),
    );
  }
}
