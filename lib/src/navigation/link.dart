/// Link — declarative SPA navigation widget.
library druid.navigation.link;

import 'package:web/web.dart' as web;

import '../widgets/widget.dart';
import '../widgets/context.dart';
import '../vdom/vnode.dart';
import 'router_provider.dart';

// ---------------------------------------------------------------------------
// Link
// ---------------------------------------------------------------------------

/// A declarative navigation link. Renders an `<a>` tag with the correct
/// `href`, but intercepts clicks to use the History API instead of a
/// full page navigation.
///
/// ```dart
/// Link(
///   to: '/users/42',
///   child: Text('View User'),
///   activeClassName: 'active',
/// )
/// ```
class Link extends Widget {
  const Link({
    required this.to,
    required this.child,
    this.replace = false,
    this.className,
    this.style,
    this.activeClassName,
    super.key,
  });

  /// The path to navigate to.
  final String to;

  /// The child widget to render inside the `<a>` tag.
  final Widget child;

  /// If true, use `history.replaceState` instead of `pushState`.
  final bool replace;

  /// CSS class name for the link.
  final String? className;

  /// Inline styles.
  final Map<String, String>? style;

  /// Additional CSS class applied when the current route matches [to].
  final String? activeClassName;

  @override
  VNode toVNode(BuildContext context) {
    final controller = RouterProvider.of(context);

    // Determine if this link is "active".
    final currentPath = controller.currentPath.value;
    final isActive = currentPath == to ||
        (to != '/' && currentPath.startsWith(to));

    final effectiveClassName = [
      if (className != null) className!,
      if (isActive && activeClassName != null) activeClassName!,
    ].join(' ');

    final props = <String, Object>{
      'href': to,
      'onClick': (Object event) {
        (event as web.Event).preventDefault();
        if (replace) {
          controller.replace(to);
        } else {
          controller.go(to);
        }
      },
    };

    if (effectiveClassName.isNotEmpty) {
      props['className'] = effectiveClassName;
    }

    if (style != null) {
      props['style'] = style!;
    }

    return VElement(
      tag: 'a',
      key: key,
      props: props,
      children: [context.build(child)],
    );
  }
}
