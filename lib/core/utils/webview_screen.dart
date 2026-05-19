import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  double _progress = 0.0;
  bool _isLoading = true;
  bool _hasError = false;
  String _pageTitle = '';
  String _currentUrl = '';
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _pageTitle = widget.title;
    _currentUrl = widget.url;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _progress = progress / 100.0;
              if (progress >= 100) {
                _isLoading = false;
              }
            });
          },
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _currentUrl = url;
            });
          },
          onPageFinished: (url) async {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
            _updateNavigationState();
            try {
              final title = await _controller.getTitle();
              if (title != null && title.isNotEmpty) {
                setState(() {
                  _pageTitle = title;
                });
              }
            } catch (_) {}
          },
          onWebResourceError: (error) {
            // Ignore minor errors, only trigger for main frame failures
            if (error.isForMainFrame ?? true) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _updateNavigationState() async {
    final canBack = await _controller.canGoBack();
    final canForward = await _controller.canGoForward();
    if (mounted) {
      setState(() {
        _canGoBack = canBack;
        _canGoForward = canForward;
      });
    }
  }

  String _getHostName(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return '';
    }
  }

  void _shareUrl() {
    Share.share(
      'Check out this link: $_currentUrl',
      subject: _pageTitle,
    );
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(_currentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch external browser',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final host = _getHostName(_currentUrl);
    final isSecure = _currentUrl.startsWith('https://');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0.5,
        shadowColor: isDark ? AppColors.borderDark : AppColors.border,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSecure)
                  const Icon(
                    Icons.lock_rounded,
                    color: Colors.green,
                    size: 14,
                  )
                else
                  Icon(
                    Icons.lock_open_rounded,
                    color: AppColors.grey400,
                    size: 14,
                  ),
                const SizedBox(width: 4),
                Expanded(
                  child: AppText(
                    title: _pageTitle,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (host.isNotEmpty)
              AppText(
                title: host,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.grey500,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: isDark ? Colors.white : AppColors.textPrimary,
              size: 20,
            ),
            onPressed: _shareUrl,
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'refresh') {
                _controller.reload();
              } else if (value == 'browser') {
                _openInBrowser();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, size: 20, color: isDark ? Colors.white : AppColors.textPrimary),
                    const SizedBox(width: 12),
                    const Text('Refresh'),
                  ],
                ),
              ),
              // PopupMenuItem(
              //   value: 'browser',
              //   child: Row(
              //     children: [
              //       Icon(Icons.open_in_browser_rounded, size: 20, color: isDark ? Colors.white : AppColors.textPrimary),
              //       const SizedBox(width: 12),
              //       const Text('Open in Browser'),
              //     ],
              //   ),
              // ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: _isLoading && _progress < 1.0
              ? LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: isDark ? AppColors.borderDark : AppColors.grey100,
                  color: AppColors.primary,
                  minHeight: 2.0,
                )
              : const SizedBox(height: 2.0),
        ),
      ),
      body: Stack(
        children: [
          // WebView Widget
          if (!_hasError)
            WebViewWidget(
              controller: _controller,
            ),

          // Custom Loading Screen
          if (_isLoading && !_hasError)
            Container(
              color: theme.scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppText(
                      title: 'Loading secure page...',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey500,
                    ),
                  ],
                ),
              ),
            ),

          // Custom Error State Screen
          if (_hasError)
            Container(
              color: theme.scaffoldBackgroundColor,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardBackgroundDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_off_rounded,
                            color: AppColors.error,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppText(
                          title: "Unable to load page",
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          title: "Please check your internet connection or try again later.",
                          fontSize: 13,
                          color: AppColors.grey500,
                          textAlign: TextAlign.center,
                          height: 1.4,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _hasError = false;
                                _isLoading = true;
                              });
                              _controller.reload();
                            },
                            child: const Text(
                              'Try Again',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
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
      ),
      bottomNavigationBar: Container(
        height: 56 + MediaQuery.of(context).padding.bottom,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: _canGoBack
                    ? (isDark ? Colors.white : AppColors.textPrimary)
                    : AppColors.grey400,
              ),
              onPressed: _canGoBack
                  ? () async {
                      await _controller.goBack();
                      _updateNavigationState();
                    }
                  : null,
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: _canGoForward
                    ? (isDark ? Colors.white : AppColors.textPrimary)
                    : AppColors.grey400,
              ),
              onPressed: _canGoForward
                  ? () async {
                      await _controller.goForward();
                      _updateNavigationState();
                    }
                  : null,
            ),
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                size: 22,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              onPressed: () => _controller.reload(),
            ),
            // IconButton(
            //   icon: Icon(
            //     Icons.open_in_new_rounded,
            //     size: 20,
            //     color: isDark ? Colors.white : AppColors.textPrimary,
            //   ),
            //   onPressed: _openInBrowser,
            // ),
          ],
        ),
      ),
    );
  }
}
