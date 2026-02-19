/// BuildContext — a handle to the widget's location in the tree.
library druid.widgets.context;

import '../vdom/vnode.dart';
import 'widget.dart';

/// Passed to [Widget.build] to give widgets access to tree-level services.
class BuildContext {
  const BuildContext({this.buildWidget});

  /// Injected by [_AppRunner] to route composite widgets through the runner.
  /// Html leaf widgets use this to build their children correctly.
  final VNode Function(Widget)? buildWidget;

  /// Build [widget] using the runner's build pipeline if available,
  /// otherwise fall back to [Widget.toVNode].
  VNode build(Widget widget) {
    if (buildWidget != null) return buildWidget!(widget);
    return widget.toVNode(this);
  }
}

/// A shared root context instance (used outside of [_AppRunner], e.g. tests).
const rootContext = BuildContext();
