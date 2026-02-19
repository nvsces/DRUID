/// BuildContext — a handle to the widget's location in the tree.
library druid.widgets.context;

import '../vdom/vnode.dart';
import 'widget.dart';

/// Passed to [Widget.build] to give widgets access to tree-level services.
class BuildContext {
  const BuildContext({this.buildWidget, Map<Type, Object>? providers})
      : _providers = providers ?? const {};

  /// Injected by [_AppRunner] to route composite widgets through the runner.
  /// Html leaf widgets use this to build their children correctly.
  final VNode Function(Widget)? buildWidget;

  /// Inherited provider map — populated by [BlocProvider] and similar widgets.
  final Map<Type, Object> _providers;

  /// Build [widget] using the runner's build pipeline if available,
  /// otherwise fall back to [Widget.toVNode].
  VNode build(Widget widget) {
    if (buildWidget != null) return buildWidget!(widget);
    return widget.toVNode(this);
  }

  /// Look up a provided value of type [T].
  ///
  /// Returns `null` if nothing of type [T] has been registered above this context.
  T? getProvider<T>() => _providers[T] as T?;

  /// Return a new [BuildContext] that inherits current providers plus [extra].
  BuildContext withProviders(Map<Type, Object> extra) => BuildContext(
        buildWidget: buildWidget,
        providers: {..._providers, ...extra},
      );
}

/// A shared root context instance (used outside of [_AppRunner], e.g. tests).
const rootContext = BuildContext();
