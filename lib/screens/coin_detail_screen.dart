import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/market_data.dart';
import '../data/repository.dart';
import '../l10n/app_strings.dart';
import '../models/candle.dart';
import '../models/coin.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/candlestick_chart.dart';
import '../widgets/coin_row.dart';
import '../widgets/ui_kit.dart';

class CoinDetailScreen extends StatefulWidget {
  final Coin coin;
  const CoinDetailScreen({super.key, required this.coin});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  String _timeframe = '1h';

  /// 已加载的远端 K 线；未加载完成时先用内置模拟数据占位。
  final Map<String, List<Candle>> _candles = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _fetchCandles(_timeframe);
  }

  Future<void> _loadCandles(String timeframe, {bool refresh = false}) async {
    setState(() => _loading = true);
    await _fetchCandles(timeframe, refresh: refresh);
  }

  Future<void> _fetchCandles(String timeframe, {bool refresh = false}) async {
    final candles = await Repository.candles(
      widget.coin,
      timeframe,
      refresh: refresh,
    );
    if (!mounted) return;
    setState(() {
      _candles[timeframe] = candles;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final coin = widget.coin;
    final state = context.watch<AppState>();
    final fav = state.isFavorite('coin:${coin.symbol}');
    final candles =
        _candles[_timeframe] ?? MarketData.candles(coin, _timeframe);
    final color = coin.isUp ? AppColors.up : AppColors.down;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CoinBadge(coin: coin, size: 26),
            const SizedBox(width: 8),
            Text('${coin.symbol}/USDT'),
          ],
        ),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            IconButton(
              tooltip: s.refresh,
              onPressed: () => _loadCandles(_timeframe, refresh: true),
              icon: const Icon(Icons.refresh_rounded, color: AppColors.subtext),
            ),
          IconButton(
            onPressed: () => state.toggleFavorite('coin:${coin.symbol}'),
            icon: Icon(
              fav ? Icons.star_rounded : Icons.star_border_rounded,
              color: fav ? AppColors.gold : AppColors.subtext,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 价格区
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${formatPrice(coin.price)}',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          ChangeText(
                            coin.change24h,
                            fontSize: 13,
                            withBackground: true,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '24h',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        coin.name,
                        style: const TextStyle(
                          color: AppColors.subtext,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s.marketCapWithValue(formatCompact(coin.marketCap)),
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
            const SizedBox(height: 14),

            // 周期切换
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: MarketData.timeframes.map((tf) {
                  final active = _timeframe == tf;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (_timeframe == tf) return;
                        setState(() => _timeframe = tf);
                        _loadCandles(tf);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: active
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          tf.toUpperCase(),
                          style: TextStyle(
                            color: active ? Colors.white : AppColors.subtext,
                            fontSize: 11.5,
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
            const SizedBox(height: 10),

            // 均线图例
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const _Legend(color: AppColors.gold, label: 'MA5'),
                  const SizedBox(width: 12),
                  const _Legend(color: AppColors.cyan, label: 'MA10'),
                  const SizedBox(width: 12),
                  const _Legend(color: Color(0xFFB07CFF), label: 'MA20'),
                  const Spacer(),
                  Text(
                    s.longPressHint,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // K 线图
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CandlestickChart(
                candles: candles,
                timeframe: _timeframe,
                height: 330,
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),

            // 市场数据
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _stat(s.high24, '\$${formatPrice(coin.high24h)}'),
                  _stat(s.low24, '\$${formatPrice(coin.low24h)}'),
                  _stat(s.volume24h, formatCompact(coin.volume24h)),
                  _stat(s.marketCapLabel, formatCompact(coin.marketCap)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 风险提示
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.show_chart_rounded,
                        size: 18,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${s.coinSummary(coin.symbol, formatPercent(coin.change24h))} '
                        '${s.klineDisclaimer}',
                        style: const TextStyle(
                          color: AppColors.subtext,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const DisclaimerBanner(),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
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
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 2, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
