/// RouterProvider — provides [RouterController] to the widget subtree.
library druid.navigation.router_provider;

import '../widgets/widget.dart';
import '../widgets/context.dart';
import 'router_controller.dart';
import 'route.dart';

// ---------------------------------------------------------------------------
// Global registry (same pattern as BlocProvider)
// ---------------------------------------------------------------------------

RouterController? _globalRouter;

// ---------------------------------------------------------------------------
// RouterProvider
// ---------------------------------------------------------------------------

/// Provides a [RouterController] to the widget subtree.
///
/// Typically placed at the root of the app:
/// ```dart
/// void main() => runApp(
///   RouterProvider(
///     routes: [
///       RouteDefinition(path: '/', builder: (ctx, m) => HomePage()),
///       RouteDefinition(path: '/about', builder: (ctx, m) => AboutPage()),
///     ],
///     notFound: (ctx, path) => Text('404: $path not found'),
///     child: Div(children: [
///       NavBar(),
///       RouterOutlet(),
///     ]),
///   ),
/// );
/// ```
class RouterProvider extends StatefulWidget {
  const RouterProvider({
    required this.routes,
    required this.child,
    this.notFound,
    this.onBeforeNavigate,
    super.key,
  });

  final List<RouteDefinition> routes;
  final Widget child;
  final Widget Function(BuildContext context, String path)? notFound;
  final bool Function(String path)? onBeforeNavigate;

  /// Retrieve the [RouterController] from the global registry.
  static RouterController of(BuildContext context) {
    if (_globalRouter == null) {
      throw StateError(
        'RouterProvider.of() called but no RouterProvider was found.\n'
        'Ensure a RouterProvider is an ancestor of this widget.',
      );
    }
    return _globalRouter!;
  }

  @override
  State<RouterProvider> createState() => _RouterProviderState();
}

class _RouterProviderState extends State<RouterProvider> {
  late final RouterController _controller;

  @override
  void initState() {
    _controller = RouterController(
      routes: widget.routes,
      notFoundBuilder: widget.notFound,
      onBeforeNavigate: widget.onBeforeNavigate,
    );
    _globalRouter = _controller;
  }

  @override
  Widget build(BuildContext context) {
    // Re-register on every build (same pattern as BlocProvider).
    _globalRouter = _controller;
    return widget.child;
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_globalRouter == _controller) {
      _globalRouter = null;
    }
  }
}
