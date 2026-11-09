import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/market_data.dart';
import '../data/repository.dart';
import '../l10n/app_strings.dart';
import '../models/coin.dart';
import '../models/exchange.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_row.dart';
import '../widgets/exchange_card.dart';
import '../widgets/ui_kit.dart';
import 'coin_detail_screen.dart';
import 'exchange_detail_screen.dart';

/// 收藏中心：集中查看已收藏的交易所与自选币种。
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Exchange> _exchanges = [];
  List<Coin> _coins = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Repository.exchanges().then((value) {
      if (!mounted) return;
      setState(() {
        _exchanges = value;
        _loaded = _coins.isNotEmpty || value.isNotEmpty;
      });
    });
    Repository.coins().then((value) {
      if (!mounted) return;
      setState(() {
        _coins = value;
        _loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final state = context.watch<AppState>();
    final favExchanges = _exchanges
        .where((e) => state.isFavorite(e.id))
        .toList();
    final favCoins = _coins
        .where((c) => state.isFavorite('coin:${c.symbol}'))
        .toList();
    final total = favExchanges.length + favCoins.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.favoritesTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                s.itemsCount(total),
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: !_loaded && total == 0
          ? LoadingView(message: s.loadingFavorites)
          : total == 0
          ? _EmptyFavorites(onBack: () => Navigator.of(context).pop())
          : ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 28),
              children: [
                _summary(s, favExchanges.length, favCoins.length),
                if (favExchanges.isNotEmpty) ...[
                  SectionHeader(title: s.savedExchanges),
                  ...favExchanges.map(
                    (e) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: ExchangeCard(
                        exchange: e,
                        isFavorite: true,
                        onFavorite: () => state.toggleFavorite(e.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ExchangeDetailScreen(exchangeId: e.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (favCoins.isNotEmpty) ...[
                  SectionHeader(title: s.savedCoins),
                  ...favCoins.map(
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
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: DisclaimerBanner(text: s.favoritesNote),
                ),
              ],
            ),
    );
  }

  Widget _summary(AppStrings s, int exchangeCount, int coinCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 20,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.favoritesSummary(exchangeCount, coinCount),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.favoritesTapHint,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  final VoidCallback onBack;
  const _EmptyFavorites({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.star_border_rounded,
                size: 30,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              s.emptyFavoritesTitle,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.emptyFavoritesBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onBack, child: Text(s.backToBrowse)),
          ],
        ),
      ),
    );
  }
}
