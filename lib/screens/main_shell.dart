import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/repository.dart';
import '../l10n/app_strings.dart';
import '../models/exchange.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';
import 'exchanges_screen.dart';
import 'home_screen.dart';
import 'markets_screen.dart';
import 'news_screen.dart';
import 'profile_screen.dart';
import 'web_preview_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _index = 0;
  bool _prompting = false;
  // 本次启动内是否已经展示过收藏提示，避免切回前台时重复弹窗。
  bool _promptedThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 首帧后检查缓存中的收藏交易所，有则弹出模糊背景的「访问官网」提示。
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybePromptFavorites(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 从后台再次回到 App 且停留在首页时，同样检查一次收藏缓存。
    if (state == AppLifecycleState.resumed && _index == 0) {
      _maybePromptFavorites();
    }
  }

  Future<void> _maybePromptFavorites() async {
    if (!mounted || _prompting) return;
    // 每次启动只提示一次，刷新或从后台返回不会重复弹出。
    if (_promptedThisSession) return;
    // 仅当主页面位于栈顶时提示，避免在详情页或收藏页上重复弹出。
    if (ModalRoute.of(context)?.isCurrent != true) return;
    final appState = context.read<AppState>();
    final favoriteIds = appState.favoriteExchangeIds;
    if (favoriteIds.isEmpty) return;

    _prompting = true;
    // 取第一个收藏的交易所，弹窗按钮直接打开它的官网。
    final exchange = await _firstFavoriteExchange(favoriteIds);
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) {
      _prompting = false;
      return;
    }
    if (exchange == null) {
      _prompting = false;
      return;
    }

    final s = AppStrings.of(context);
    // 标记本次启动已提示，即使随后关闭弹窗也不会在回到前台时再次弹出。
    _promptedThisSession = true;
    final visitSite = await showGeneralDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: s.favoritesPromptLabel,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _FavoritesPrompt(exchangeCount: favoriteIds.length);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
    _prompting = false;

    if (!mounted) return;
    if (visitSite ?? false) {
      WebPreviewScreen.open(
        context,
        url: exchange.website,
        title: s.websiteTitle(exchange.name),
      );
    }
  }

  /// 按收藏顺序找到第一家仍在数据源中的交易所。
  Future<Exchange?> _firstFavoriteExchange(List<String> favoriteIds) async {
    final exchanges = await Repository.exchanges();
    for (final id in favoriteIds) {
      for (final exchange in exchanges) {
        if (exchange.id == id) return exchange;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onNavigateTab: (i) => setState(() => _index = i)),
          const ExchangesScreen(),
          const MarketsScreen(),
          const NewsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildNav(AppStrings.of(context)),
    );
  }

  Widget _buildNav(AppStrings s) {
    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: s.navHome,
      ),
      _NavItem(
        icon: Icons.storefront_outlined,
        activeIcon: Icons.storefront_rounded,
        label: s.navExchanges,
      ),
      _NavItem(
        icon: Icons.show_chart_rounded,
        activeIcon: Icons.candlestick_chart_rounded,
        label: s.navMarkets,
      ),
      _NavItem(
        icon: Icons.article_outlined,
        activeIcon: Icons.article_rounded,
        label: s.navNews,
      ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: s.navProfile,
      ),
    ];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surfaceHigh, AppColors.surface],
            ),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 68,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / items.length;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 顶部高光：让浮动 dock 有玻璃质感。
                    Positioned(
                      top: 0,
                      left: 28,
                      right: 28,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.primary.withValues(alpha: 0.55),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 滑动的发光胶囊，跟随当前 tab 移动。
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      left: tabWidth * _index + 6,
                      top: 8,
                      width: tabWidth - 12,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.24),
                              AppColors.cyan.withValues(alpha: 0.08),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(items.length, (i) {
                        final item = items[i];
                        final active = _index == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_index == i) return;
                              HapticFeedback.selectionClick();
                              setState(() => _index = i);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: active ? 1.16 : 1,
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutBack,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      active ? item.activeIcon : item.icon,
                                      key: ValueKey<bool>(active),
                                      size: 21,
                                      color: active
                                          ? AppColors.text
                                          : AppColors.muted,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                  style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 0.2,
                                    fontWeight: active
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: active
                                        ? AppColors.text
                                        : AppColors.muted,
                                  ),
                                  child: Text(item.label),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    // 顶部指针光点：标记当前 tab，像刻度上的光标。
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      top: -2,
                      left: tabWidth * _index + tabWidth / 2 - 11,
                      child: Container(
                        width: 22,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withValues(alpha: 0.65),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoritesPrompt extends StatelessWidget {
  final int exchangeCount;

  const _FavoritesPrompt({required this.exchangeCount});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Stack(
      children: [
        // 模糊背景：点击空白处关闭，回到首页。
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.18)),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandMark(size: 56, radius: 16),
                    const SizedBox(height: 16),
                    Text(
                      s.welcomeBack,
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.welcomeBackBody(exchangeCount),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.subtext,
                        fontSize: 12.5,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s.visitSite,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        s.backHome,
                        style: TextStyle(
                          color: AppColors.subtext,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
