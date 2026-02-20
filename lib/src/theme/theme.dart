/// Theme widget — provides ThemeData to the widget tree.
library druid.theme.theme;

import '../vdom/vnode.dart';
import '../widgets/widget.dart';
import '../widgets/context.dart';
import 'theme_data.dart';

/// Provides a [ThemeData] to all descendant widgets.
///
/// Access the theme anywhere in the tree with [Theme.of]:
/// ```dart
/// final theme = Theme.of(context);
/// final primary = theme.colorScheme.primary.toCss();
/// ```
///
/// Typically you don't create this directly — pass `theme` to [runApp] instead:
/// ```dart
/// runApp(MyApp(), theme: ThemeData(fontFamily: 'Jost'));
/// ```
class Theme extends StatelessWidget {
  final ThemeData data;
  final Widget child;

  const Theme({required this.data, required this.child, super.key});

  /// Returns the nearest [ThemeData] in the widget tree.
  ///
  /// Falls back to [ThemeData.light] if no [Theme] ancestor is found.
  static ThemeData of(BuildContext context) =>
      context.theme ?? ThemeData.light();

  @override
  Widget build(BuildContext context) {
    final themedContext = context.withTheme(data);
    return _ContextWidget(child: child, context: themedContext);
  }
}

/// Internal widget that re-builds a child with a specific [BuildContext].
class _ContextWidget extends Widget {
  final Widget child;
  final BuildContext context;

  const _ContextWidget({required this.child, required this.context});

  @override
  VNode toVNode(BuildContext _) => context.build(child);
}
