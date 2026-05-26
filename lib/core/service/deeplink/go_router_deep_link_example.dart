// THIS IS AN EXAMPLE FILE DEMONSTRATING DEEP LINKING SETUP WITH GO_ROUTER.
// It is not active in the main app (which uses GetX/onGenerateRoute)
// but is provided as a complete reference for your news app or other projects.

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ==========================================
// 1. GoRouter Setup
// ==========================================

final GoRouter exampleRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Home Screen')),
      ),
    ),
    // Define the news details route with the path parameter :id
    GoRoute(
      path: '/news/:id',
      builder: (context, state) {
        final newsId = state.pathParameters['id'] ?? '';
        return Scaffold(
          appBar: AppBar(title: const Text('News Detail')),
          body: Center(child: Text('News ID: $newsId')),
        );
      },
    ),
  ],
);

// ==========================================
// 2. GoRouter Deep Link Service
// ==========================================

class GoRouterDeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  void initialize(GoRouter router) {
    // A. Handle app launch from a terminated state via a link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri, router);
      }
    });

    // B. Handle links when app is running in the background/foreground
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri, router);
      },
      onError: (err) {
        debugPrint('Deep Link listener error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri, GoRouter router) {
    debugPrint('Processing Incoming Deep Link: $uri');
    
    // We expect path formats like: /news/123
    final path = uri.path;

    if (path.startsWith('/news/')) {
      // Direct navigation using GoRouter
      router.go(path);
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
