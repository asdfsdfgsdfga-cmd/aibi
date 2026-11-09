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
import '../widgets/indicators.dart';
import 'coin_detail_screen.dart';
import 'exchange_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  List<Exchange> _exchanges = [];
  List<Coin> _coins = [];

  @override
  void initState() {
    super.initState();
    Repository.exchanges().then((v) {
      if (mounted) setState(() => _exchanges = v);
    });
    Repository.coins().then((v) {
      if (mounted) setState(() => _coins = v);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Exchange> get _matchedExchanges {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return _exchanges.where((e) => e.name.toLowerCase().contains(q)).toList();
  }

  List<Coin> get _matchedCoins {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return _coins
        .where(
          (c) =>
              c.symbol.toLowerCase().contains(q) ||
              c.name.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final exchanges = _matchedExchanges;
    final coins = _matchedCoins;
    final empty = _query.isNotEmpty && exchanges.isEmpty && coins.isEmpty;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: AppColors.text, fontSize: 13.5),
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: InputDecoration(
              hintText: s.searchHintLong,
              hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 19,
                color: AppColors.muted,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        ),
      ),
      body: _query.isEmpty
          ? _suggestions(s)
          : empty
          ? Center(
              child: Text(
                s.noResults,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (exchanges.isNotEmpty) ...[
                  _GroupTitle(s.exchangesLabel),
                  ...exchanges.map((e) => _exchangeTile(e)),
                ],
                if (coins.isNotEmpty) ...[
                  _GroupTitle(s.coinsLabel),
                  ...coins.map(
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
              ],
            ),
    );
  }

  Widget _suggestions(AppStrings s) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      children: [
        Text(s.hotSearches, style: AppTheme.sectionTitle),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Binance', 'OKX', 'BTC', 'ETH', 'SOL', 'Coinbase']
              .map(
                (term) => GestureDetector(
                  onTap: () {
                    _controller.text = term;
                    setState(() => _query = term);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      term,
                      style: const TextStyle(
                        color: AppColors.subtext,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        if (_exchanges.isNotEmpty) ...[
          Text(s.allExchanges, style: AppTheme.sectionTitle),
          const SizedBox(height: 8),
          ..._exchanges.take(5).map((e) => _exchangeTile(e)),
        ],
      ],
    );
  }

  Widget _exchangeTile(Exchange e) {
    final state = context.watch<AppState>();
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExchangeDetailScreen(exchangeId: e.id),
        ),
      ),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            ExchangeLogo(exchange: e, size: 40),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      RatingStars(rating: e.rating, size: 10),
                      const SizedBox(width: 4),
                      Text(
                        e.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      RiskBadge(level: e.riskLevel, compact: true),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              state.isFavorite(e.id)
                  ? Icons.star_rounded
                  : Icons.chevron_right_rounded,
              size: 18,
              color: state.isFavorite(e.id) ? AppColors.gold : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  final String text;
  const _GroupTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.muted, fontSize: 11),
      ),
    );
  }
}
