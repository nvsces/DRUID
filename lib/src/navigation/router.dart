/// RouterOutlet and NestedRouterOutlet widgets.
library druid.navigation.router;

import '../widgets/widget.dart';
import '../widgets/context.dart';
import '../widgets/text.dart';
import 'router_provider.dart';
import 'route.dart';

// ---------------------------------------------------------------------------
// RouterOutlet
// ---------------------------------------------------------------------------

/// Renders the widget for the currently matched route.
///
/// Place this where you want route content to appear:
/// ```dart
/// Div(children: [
///   NavBar(),
///   RouterOutlet(), // route content renders here
///   Footer(),
/// ])
/// ```
class RouterOutlet extends StatelessWidget {
  const RouterOutlet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = RouterProvider.of(context);

    // Reading .value here auto-tracks this Signal in the render Effect.
    final match = controller.currentMatch.value;

    if (match == null) {
      final path = controller.currentPath.value;
      if (controller.notFoundBuilder != null) {
        return controller.notFoundBuilder!(context, path);
      }
      return Text('404: Page not found ($path)');
    }

    return _buildMatchChain(context, match);
  }

  Widget _buildMatchChain(BuildContext context, RouteMatch match) {
    if (match.route.builder == null) {
      // Layout route without builder — skip to child.
      if (match.child != null) {
        return _buildMatchChain(context, match.child!);
      }
      return const Text('');
    }

    return match.route.builder!(context, match);
  }
}

// ---------------------------------------------------------------------------
// NestedRouterOutlet
// ---------------------------------------------------------------------------

/// Renders the child route within a parent route's builder.
///
/// Use inside a parent route's builder to place nested child content:
/// ```dart
/// RouteDefinition(
///   path: '/dashboard',
///   builder: (ctx, match) => Div(children: [
///     SideNav(),
///     NestedRouterOutlet(match: match),
///   ]),
///   children: [
///     RouteDefinition(path: 'overview', builder: ...),
///     RouteDefinition(path: 'settings', builder: ...),
///   ],
/// )
/// ```
class NestedRouterOutlet extends StatelessWidget {
  const NestedRouterOutlet({required this.match, super.key});

  final RouteMatch match;

  @override
  Widget build(BuildContext context) {
    if (match.child == null) {
      return const Text('');
    }

    final childMatch = match.child!;
    if (childMatch.route.builder == null) {
      return const Text('');
    }

    return childMatch.route.builder!(context, childMatch);
  }
}
