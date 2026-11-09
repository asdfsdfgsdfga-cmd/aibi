import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_strings.dart';
import 'screens/main_shell.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class BiaimxApp extends StatelessWidget {
  /// 可注入已带缓存的 AppState（测试与启动恢复使用）。
  final AppState? state;

  const BiaimxApp({super.key, this.state});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => state ?? AppState()),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, _) => MaterialApp(
          title: 'BIAIMX',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          locale: appState.locale,
          supportedLocales: const [
            AppState.englishLocale,
            AppState.traditionalLocale,
          ],
          localizationsDelegates: const [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          scrollBehavior: const _AppScrollBehavior(),
          // builder 会包裹 Navigator，保证 push 出来的详情页、弹窗同样处于手机宽度内。
          builder: (context, child) => kIsWeb
              ? _WebFrame(child: child ?? const SizedBox.shrink())
              : child!,
          home: const MainShell(),
        ),
      ),
    );
  }
}

/// Web 预览：限制为手机宽度并居中，移动端不受影响。
class _WebFrame extends StatelessWidget {
  final Widget child;
  const _WebFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 430 ? constraints.maxWidth : 430.0;
        // 让子树拿到与窄屏一致的 MediaQuery，避免按桌面尺寸计算的布局。
        final media = MediaQuery.of(context)
            .copyWith(size: Size(width, constraints.maxHeight));
        return ColoredBox(
          color: AppColors.bg,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: MediaQuery(
                data: media,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppColors.border),
                      right: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
