import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repository.dart';
import '../l10n/app_strings.dart';
import '../models/coin.dart';
import '../models/exchange.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';
import '../widgets/coin_row.dart';
import '../widgets/indicators.dart';
import '../widgets/ui_kit.dart';
import 'coin_detail_screen.dart';
import 'exchange_detail_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final state = context.watch<AppState>();
    final favExchanges = _exchanges
        .where((e) => state.isFavorite(e.id))
        .toList();
    final favCoins = _coins
        .where((c) => state.isFavorite('coin:${c.symbol}'))
        .toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const BrandMark(size: 56, radius: 16),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.appName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          s.savedLocally,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _countCard(
                      s.statExchanges,
                      favExchanges.length.toString(),
                      Icons.storefront_rounded,
                      AppColors.primary,
                      () => _openFavorites(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _countCard(
                      s.statCoins,
                      favCoins.length.toString(),
                      Icons.star_rounded,
                      AppColors.gold,
                      () => _openFavorites(context),
                    ),
                  ),
                ],
              ),
            ),
            SectionHeader(title: s.myExchanges),
            if (favExchanges.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _EmptyHint(text: s.emptyMyExchanges),
              )
            else
              ...favExchanges.map(
                (e) => GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ExchangeDetailScreen(exchangeId: e.id),
                    ),
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 9,
                    ),
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
                        GestureDetector(
                          onTap: () => state.toggleFavorite(e.id),
                          child: const Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SectionHeader(title: s.myCoins),
            if (favCoins.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _EmptyHint(text: s.emptyMyCoins),
              )
            else
              ...favCoins.map(
                (c) => CoinRow(
                  coin: c,
                  spark: _spark(c),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CoinDetailScreen(coin: c),
                    ),
                  ),
                ),
              ),
            SectionHeader(title: s.more),
            _menuTile(
              Icons.gpp_maybe_rounded,
              s.riskDisclaimerTitle,
              AppColors.warning,
              () => _showSheet(
                context,
                s.riskDisclaimerTitle,
                s.riskDisclaimerBody,
              ),
            ),
            _menuTile(
              Icons.info_outline_rounded,
              s.about,
              AppColors.primary,
              () => _showSheet(context, s.about, s.aboutBody),
            ),
            _menuTile(
              Icons.privacy_tip_outlined,
              s.privacyTitle,
              AppColors.cyan,
              () => _showSheet(context, s.privacyTitle, s.privacyBody),
            ),
            _menuTile(
              Icons.language_rounded,
              s.language,
              AppColors.primary,
              () => state.toggleLanguage(),
              trailing: state.isTraditional
                  ? s.languageTraditional
                  : s.languageEnglish,
            ),
            _menuTile(
              Icons.code_rounded,
              s.version,
              AppColors.subtext,
              () {},
              trailing: 'v1.4.0',
            ),
            const DisclaimerBanner(),
          ],
        ),
      ),
    );
  }

  List<double> _spark(Coin c) {
    return List<double>.generate(24, (i) {
      final t = i / 23;
      return c.price * (1 + (c.change24h / 100) * t + ((i % 5) - 2) * 0.0008);
    });
  }

  Widget _countCard(
    String label,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openFavorites(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const FavoritesScreen()));
  }

  Widget _menuTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap, {
    String? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(color: AppColors.text, fontSize: 13),
            ),
            const Spacer(),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
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
              const SizedBox(height: 14),
              Text(
                content,
                style: const TextStyle(
                  color: AppColors.subtext,
                  fontSize: 13,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star_border_rounded,
            size: 18,
            color: AppColors.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.muted, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}
