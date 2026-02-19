/// Virtual DOM node types.
///
/// The sealed hierarchy:
///   VNode
///   ├── VElement   — represents an HTML element  (<div>, <button>, …)
///   └── VText      — represents a text node
library druid.vdom.vnode;

/// Event handler type.
/// Uses [Object] so vnode.dart stays browser-independent and testable on VM.
/// At runtime the argument will always be a `package:web` Event.
typedef EventHandler = void Function(Object event);

/// Base class for all virtual DOM nodes.
sealed class VNode {
  const VNode({this.key});

  /// Optional stable identity key for list reconciliation.
  final String? key;
}

// ---------------------------------------------------------------------------
// VElement
// ---------------------------------------------------------------------------

/// A virtual element corresponding to an HTML tag.
///
/// [props] can contain:
///   - HTML attributes as `String` values (e.g. `'class': 'btn'`)
///   - Event handlers as [EventHandler] (e.g. `'onClick': (e) { … }`)
///   - Style map as `Map<String, String>` under key `'style'`
///   - Boolean attributes as `bool` (e.g. `'disabled': true`)
class VElement extends VNode {
  const VElement({
    required this.tag,
    this.props = const {},
    this.children = const [],
    super.key,
  });

  final String tag;
  final Map<String, Object> props;
  final List<VNode> children;

  @override
  String toString() =>
      'VElement($tag, props: $props, children: ${children.length})';
}

// ---------------------------------------------------------------------------
// VText
// ---------------------------------------------------------------------------

/// A virtual text node.
class VText extends VNode {
  const VText(this.text, {super.key});

  final String text;

  @override
  String toString() => 'VText("$text")';
}
