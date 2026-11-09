import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repository.dart';
import '../l10n/app_strings.dart';
import '../models/exchange.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/exchange_card.dart';
import '../widgets/ui_kit.dart';
import 'exchange_detail_screen.dart';
import 'search_screen.dart';

enum _Filter { all, topRated, lowRisk, spot, futures, favorite }

class ExchangesScreen extends StatefulWidget {
  const ExchangesScreen({super.key});

  @override
  State<ExchangesScreen> createState() => _ExchangesScreenState();
}

class _ExchangesScreenState extends State<ExchangesScreen> {
  late Future<List<Exchange>> _future;
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _future = Repository.exchanges();
  }

  /// 下拉刷新：跳过缓存重新拉取远端交易所数据，刷新期间保留当前列表。
  Future<void> _reload() async {
    try {
      final list = await Repository.exchanges(refresh: true);
      if (!mounted) return;
      setState(() => _future = Future.value(list));
    } catch (_) {
      // Repository 内部已做兜底，这里保持旧列表即可。
    }
  }

  String _filterLabel(AppStrings s, _Filter filter) => switch (filter) {
    _Filter.all => s.filterAll,
    _Filter.topRated => s.filterTopRated,
    _Filter.lowRisk => s.filterLowRisk,
    _Filter.spot => s.filterSpot,
    _Filter.futures => s.filterFutures,
    _Filter.favorite => s.filterFavorite,
  };

  List<Exchange> _apply(List<Exchange> list, Set<String> favorites) {
    switch (_filter) {
      case _Filter.all:
        return list;
      case _Filter.topRated:
        return list.where((e) => e.rating >= 4.5).toList();
      case _Filter.lowRisk:
        return list.where((e) => e.riskLevel == RiskLevel.low).toList();
      case _Filter.spot:
        return list
            .where((e) => e.marketTypes.contains(MarketType.spot))
            .toList();
      case _Filter.futures:
        return list
            .where((e) => e.marketTypes.contains(MarketType.futures))
            .toList();
      case _Filter.favorite:
        return list.where((e) => favorites.contains(e.id)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final appState = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  Text(s.exchangesTitle, style: AppTheme.headline),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      s.ratingBadge,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _Filter.values.map((f) {
                  final active = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : Colors.transparent,
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
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Exchange>>(
                future: _future,
                builder: (context, snap) {
                  if (!snap.hasData) return const LoadingView();
                  final list = _apply(snap.data!, appState.favorites);
                  if (list.isEmpty) {
                    return EmptyView(
                      message: s.emptyExchanges,
                      icon: Icons.filter_alt_off_outlined,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _reload,
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: list.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        if (i == list.length) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: DisclaimerBanner(),
                          );
                        }
                        final e = list[i];
                        return ExchangeCard(
                          exchange: e,
                          isFavorite: appState.isFavorite(e.id),
                          onFavorite: () => appState.toggleFavorite(e.id),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExchangeDetailScreen(exchangeId: e.id),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
