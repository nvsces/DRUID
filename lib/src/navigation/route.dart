/// Route definitions and URL matching algorithm.
///
/// This file has zero browser dependencies — all logic is pure Dart
/// and can be tested on the VM with `dart test`.
library druid.navigation.route;

import '../widgets/widget.dart';
import '../widgets/context.dart';

// ---------------------------------------------------------------------------
// RouteDefinition
// ---------------------------------------------------------------------------

/// Typedef for route builder functions.
typedef RouteBuilder = Widget Function(BuildContext context, RouteMatch match);

/// A declarative route entry. Supports path parameters and nested children.
///
/// ```dart
/// RouteDefinition(
///   path: '/users/:id',
///   builder: (context, match) => UserPage(id: match.params['id']!),
///   children: [
///     RouteDefinition(
///       path: 'posts',
///       builder: (context, match) => UserPostsList(),
///     ),
///   ],
/// )
/// ```
class RouteDefinition {
  const RouteDefinition({
    required this.path,
    this.builder,
    this.redirect,
    this.children = const [],
    this.guards = const [],
  });

  /// Path pattern relative to parent. Use `:param` for dynamic segments.
  ///
  /// Leading slash for top-level routes: `/`, `/users`, `/users/:id`.
  /// Child routes are relative (no leading slash): `posts`, `:postId`.
  final String path;

  /// Builds the widget for this route when matched.
  final RouteBuilder? builder;

  /// If non-null, redirect to this path instead of building.
  /// Takes precedence over [builder].
  final String Function(RouteMatch match)? redirect;

  /// Nested child routes. Their paths are appended to this route's resolved path.
  final List<RouteDefinition> children;

  /// Optional guards. Each returns `true` to allow, `false` to block.
  final List<RouteGuard> guards;
}

// ---------------------------------------------------------------------------
// RouteMatch
// ---------------------------------------------------------------------------

/// The result of matching a URL path against a RouteDefinition tree.
class RouteMatch {
  const RouteMatch({
    required this.route,
    required this.fullPath,
    required this.params,
    this.queryParams = const {},
    this.child,
  });

  /// The matched route definition.
  final RouteDefinition route;

  /// The fully resolved path (e.g., `/users/42`).
  final String fullPath;

  /// Path parameters extracted from the URL (e.g., `{'id': '42'}`).
  final Map<String, String> params;

  /// Query parameters from the URL (e.g., `?tab=posts` -> `{'tab': 'posts'}`).
  final Map<String, String> queryParams;

  /// If this route has matched children, the child match.
  /// Used for nested routing.
  final RouteMatch? child;
}

// ---------------------------------------------------------------------------
// RouteGuard
// ---------------------------------------------------------------------------

/// A function that inspects a [RouteMatch] and returns `true` to allow
/// navigation or `false` to block it.
typedef RouteGuard = bool Function(RouteMatch match);

// ---------------------------------------------------------------------------
// Path Matching
// ---------------------------------------------------------------------------

/// Matches [urlPath] against a list of [routes], returning a [RouteMatch]
/// or `null` (404).
///
/// Algorithm:
///   1. Split URL into segments: `/users/42/posts` → `['users', '42', 'posts']`
///   2. For each route, try to match segments against the route's path pattern.
///   3. `:param` segments capture the value.
///   4. If a route has children, match remaining segments recursively.
///   5. First full match wins. `null` if no route matches all segments.
RouteMatch? matchRoute(
  String urlPath,
  List<RouteDefinition> routes, {
  Map<String, String> queryParams = const {},
}) {
  final segments = _splitPath(urlPath);
  return _matchSegments(segments, 0, routes, '', {}, queryParams);
}

/// Parse query parameters from a URL string.
///
/// `/users/42?tab=posts&sort=asc` → `{'tab': 'posts', 'sort': 'asc'}`
Map<String, String> parseQueryParams(String url) {
  final qIndex = url.indexOf('?');
  if (qIndex < 0 || qIndex >= url.length - 1) return {};
  final queryString = url.substring(qIndex + 1);
  final result = <String, String>{};
  for (final pair in queryString.split('&')) {
    final eqIndex = pair.indexOf('=');
    if (eqIndex > 0) {
      result[Uri.decodeComponent(pair.substring(0, eqIndex))] =
          Uri.decodeComponent(pair.substring(eqIndex + 1));
    } else if (pair.isNotEmpty) {
      result[Uri.decodeComponent(pair)] = '';
    }
  }
  return result;
}

/// Extract the path portion of a URL (before the `?`).
String extractPath(String url) {
  final qIndex = url.indexOf('?');
  return qIndex < 0 ? url : url.substring(0, qIndex);
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

List<String> _splitPath(String path) =>
    path.split('/').where((s) => s.isNotEmpty).toList();

List<String> _splitPattern(String pattern) =>
    pattern.split('/').where((s) => s.isNotEmpty).toList();

RouteMatch? _matchSegments(
  List<String> urlSegments,
  int startIndex,
  List<RouteDefinition> routes,
  String parentPath,
  Map<String, String> accumulatedParams,
  Map<String, String> queryParams,
) {
  for (final route in routes) {
    final patternSegments = _splitPattern(route.path);
    final params = Map<String, String>.from(accumulatedParams);

    final matchLength = _tryMatchPattern(
      urlSegments,
      startIndex,
      patternSegments,
      params,
    );

    if (matchLength < 0) continue;

    final consumedEnd = startIndex + matchLength;
    final resolvedPath = _buildResolvedPath(parentPath, patternSegments, params);

    // All URL segments consumed — full match.
    if (consumedEnd >= urlSegments.length) {
      return RouteMatch(
        route: route,
        fullPath: resolvedPath.isEmpty ? '/' : resolvedPath,
        params: params,
        queryParams: queryParams,
      );
    }

    // Try to match remaining segments against children.
    if (route.children.isNotEmpty) {
      final childMatch = _matchSegments(
        urlSegments,
        consumedEnd,
        route.children,
        resolvedPath,
        params,
        queryParams,
      );
      if (childMatch != null) {
        return RouteMatch(
          route: route,
          fullPath: resolvedPath.isEmpty ? '/' : resolvedPath,
          params: params,
          queryParams: queryParams,
          child: childMatch,
        );
      }
    }
  }

  return null;
}

String _buildResolvedPath(
  String parentPath,
  List<String> patternSegments,
  Map<String, String> params,
) {
  if (patternSegments.isEmpty) return parentPath;
  final resolved = patternSegments.map((seg) {
    if (seg.startsWith(':')) return params[seg.substring(1)] ?? seg;
    return seg;
  }).join('/');
  return '$parentPath/$resolved';
}

/// Try to match [patternSegments] against [urlSegments] starting at
/// [startIndex]. Returns the number of consumed segments, or -1 on failure.
int _tryMatchPattern(
  List<String> urlSegments,
  int startIndex,
  List<String> patternSegments,
  Map<String, String> params,
) {
  // Empty pattern (root route '/') — matches zero segments.
  if (patternSegments.isEmpty) return 0;

  if (startIndex + patternSegments.length > urlSegments.length) return -1;

  for (var i = 0; i < patternSegments.length; i++) {
    final pattern = patternSegments[i];
    final segment = urlSegments[startIndex + i];

    if (pattern.startsWith(':')) {
      // Dynamic parameter — capture.
      params[pattern.substring(1)] = Uri.decodeComponent(segment);
    } else if (pattern == '*') {
      // Wildcard — matches any single segment, no capture.
    } else if (pattern != segment) {
      return -1;
    }
  }

  return patternSegments.length;
}
