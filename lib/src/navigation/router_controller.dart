/// Signal-based router controller with History API integration.
library druid.navigation.router_controller;

import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../core/signal.dart';
import '../widgets/widget.dart';
import '../widgets/context.dart';
import 'route.dart';

// ---------------------------------------------------------------------------
// RouterController
// ---------------------------------------------------------------------------

/// Manages the current route state as a [Signal] and syncs with the browser
/// History API.
///
/// Core reactive primitive: [currentMatch] is a `Signal<RouteMatch?>`.
/// Widgets that read `currentMatch.value` during `build()` will auto-track
/// and rebuild when the route changes.
///
/// ```dart
/// final router = RouterController(
///   routes: [
///     RouteDefinition(path: '/', builder: (ctx, m) => HomePage()),
///     RouteDefinition(path: '/about', builder: (ctx, m) => AboutPage()),
///   ],
/// );
/// router.go('/about'); // navigates, updates Signal
/// ```
class RouterController {
  RouterController({
    required this.routes,
    this.notFoundBuilder,
    this.onBeforeNavigate,
  }) {
    _syncFromBrowser();
    _listenPopState();
  }

  /// Top-level route definitions.
  final List<RouteDefinition> routes;

  /// Widget to show when no route matches (404).
  final Widget Function(BuildContext context, String path)? notFoundBuilder;

  /// Optional callback before every navigation. Return `false` to cancel.
  final bool Function(String path)? onBeforeNavigate;

  /// The current matched route. `null` if no route matches (404 state).
  final Signal<RouteMatch?> _currentMatch = Signal<RouteMatch?>(null);
  Signal<RouteMatch?> get currentMatch => _currentMatch;

  /// The current URL path (without query string).
  final Signal<String> _currentPath = Signal<String>('/');
  Signal<String> get currentPath => _currentPath;

  // -- Navigation methods ---------------------------------------------------

  /// Navigate to [path] using `history.pushState`.
  void go(String path) {
    if (onBeforeNavigate != null && !onBeforeNavigate!(path)) return;
    web.window.history.pushState(null, '', path);
    _updateRoute(path);
  }

  /// Replace current history entry with [path].
  void replace(String path) {
    if (onBeforeNavigate != null && !onBeforeNavigate!(path)) return;
    web.window.history.replaceState(null, '', path);
    _updateRoute(path);
  }

  /// Go back one entry in browser history.
  void back() {
    web.window.history.back();
  }

  /// Go forward one entry in browser history.
  void forward() {
    web.window.history.forward();
  }

  /// Build a path string with parameters substituted.
  ///
  /// ```dart
  /// router.pathFor('/users/:id', {'id': '42'}); // '/users/42'
  /// ```
  String pathFor(String pattern, [Map<String, String> params = const {}]) {
    var result = pattern;
    for (final entry in params.entries) {
      result = result.replaceAll(':${entry.key}', entry.value);
    }
    return result;
  }

  // -- Internal -------------------------------------------------------------

  void _syncFromBrowser() {
    final fullUrl =
        web.window.location.pathname + web.window.location.search;
    _updateRoute(fullUrl);
  }

  void _listenPopState() {
    web.window.addEventListener(
      'popstate',
      ((web.Event e) {
        _syncFromBrowser();
      }).toJS,
    );
  }

  void _updateRoute(String fullUrl) {
    final path = extractPath(fullUrl);
    final queryParams = parseQueryParams(fullUrl);
    final match = matchRoute(path, routes, queryParams: queryParams);

    // Handle redirects.
    if (match != null) {
      final deepest = _deepestMatch(match);
      if (deepest.route.redirect != null) {
        final redirectPath = deepest.route.redirect!(deepest);
        replace(redirectPath);
        return;
      }

      // Check guards on the deepest match.
      for (final guard in deepest.route.guards) {
        if (!guard(deepest)) return;
      }
    }

    _currentPath.value = path;
    _currentMatch.value = match;
  }

  RouteMatch _deepestMatch(RouteMatch match) {
    var current = match;
    while (current.child != null) {
      current = current.child!;
    }
    return current;
  }

  /// Dispose listeners. Call when the app is destroyed.
  void dispose() {
    // popstate listener lives for app lifetime; no-op for now.
  }
}
