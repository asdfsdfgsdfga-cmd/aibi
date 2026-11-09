import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// 应用内 WebView 外链预览页。
///
/// - Android / iOS / macOS：使用系统 WebView 打开；
/// - Web 预览与不支持的桌面平台：浏览器禁止内嵌第三方站点，改为提供跳转按钮。
class WebPreviewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebPreviewScreen({super.key, required this.url, required this.title});

  /// 当前平台是否有可用的内嵌 WebView。
  static bool get supportsEmbeddedWebView =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static void open(
    BuildContext context, {
    required String url,
    required String title,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebPreviewScreen(url: url, title: title),
      ),
    );
  }

  @override
  State<WebPreviewScreen> createState() => _WebPreviewScreenState();
}

class _WebPreviewScreenState extends State<WebPreviewScreen> {
  WebViewController? _controller;
  int _progress = 0;
  bool _loading = true;
  bool _canGoBack = false;
  String? _error;

  Uri get _uri => Uri.parse(widget.url);

  String get _host {
    final host = _uri.host.replaceFirst('www.', '');
    return host.isEmpty ? widget.url : host;
  }

  @override
  void initState() {
    super.initState();
    if (!WebPreviewScreen.supportsEmbeddedWebView) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.bg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (!mounted) return;
            setState(() => _progress = value);
          },
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _error = null;
            });
          },
          onPageFinished: (url) async {
            final canGoBack = await _controller?.canGoBack() ?? false;
            if (!mounted) return;
            setState(() {
              _loading = false;
              _progress = 100;
              _canGoBack = canGoBack;
            });
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            if (error.isForMainFrame == false) return;
            setState(() {
              _loading = false;
              _error = error.description.isEmpty
                  ? AppStrings.of(context).loadFailed
                  : error.description;
            });
          },
        ),
      )
      ..loadRequest(_uri);
  }

  Future<void> _openInBrowser() async {
    final ok = await launchUrl(_uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).cannotOpenBrowser)),
      );
    }
  }

  Future<void> _reload() async {
    if (_controller == null) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    await _controller!.reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final embedded = _controller != null;
    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _controller == null) return;
        final navigator = Navigator.of(context);
        if (await _controller!.canGoBack()) {
          await _controller!.goBack();
        } else {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 10,
                    color: AppColors.up,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _host,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (embedded)
              IconButton(
                tooltip: s.refresh,
                onPressed: _reload,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: AppColors.subtext,
                ),
              ),
            IconButton(
              tooltip: s.openInBrowser,
              onPressed: _openInBrowser,
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: 19,
                color: AppColors.subtext,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: embedded
            ? _buildEmbedded()
            : _UnsupportedView(uri: _uri, onOpen: _openInBrowser),
      ),
    );
  }

  Widget _buildEmbedded() {
    return Column(
      children: [
        if (_loading)
          LinearProgressIndicator(
            value: _progress <= 0 || _progress >= 100 ? null : _progress / 100,
            minHeight: 2,
            backgroundColor: AppColors.surface,
            color: AppColors.primary,
          )
        else
          const SizedBox(height: 2),
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller!),
              if (_error != null)
                _ErrorView(
                  message: _error!,
                  onRetry: _reload,
                  onOpenBrowser: _openInBrowser,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnsupportedView extends StatelessWidget {
  final Uri uri;
  final VoidCallback onOpen;

  const _UnsupportedView({required this.uri, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.public_rounded,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              s.previewTitle,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              uri.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.subtext,
                fontSize: 12.5,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              s.unsupportedBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11.5,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(s.openInBrowserCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenBrowser;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onOpenBrowser,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return ColoredBox(
      color: AppColors.bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: AppColors.muted,
              ),
              const SizedBox(height: 14),
              Text(
                s.loadFailed,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11.5,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.regionHint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: Text(s.reload),
              ),
              TextButton.icon(
                onPressed: onOpenBrowser,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(s.openInBrowser),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
