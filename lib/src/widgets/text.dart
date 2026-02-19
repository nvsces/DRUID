/// Text widget — renders a DOM text node.
library druid.widgets.text;

import 'widget.dart';
import 'context.dart';
import '../vdom/vnode.dart';

/// Renders plain text as a DOM text node.
///
/// ```dart
/// Text('Hello, world!')
/// ```
class Text extends Widget {
  const Text(this.data, {super.key});

  final String data;

  @override
  VNode toVNode(BuildContext context) => VText(data, key: key);
}
