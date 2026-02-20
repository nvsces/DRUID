/// Built-in HTML element widgets.
///
/// Each class wraps a specific HTML tag and exposes typed props.
/// All widgets are immutable (const-constructible where possible).
library druid.widgets.html;

import 'widget.dart';
import 'context.dart';
import 'style.dart';
import 'css_style.dart';
import '../vdom/vnode.dart'; // exports EventHandler

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/// Resolves a style value to `Map<String, String>?`.
///
/// Accepts [CssStyle], `Map<String, String>`, or `null`.
Map<String, String>? _resolveStyle(Object? style) {
  if (style == null) return null;
  if (style is CssStyle) return style.toMap();
  if (style is Map<String, String>) return style;
  return null;
}

/// Builds a props map from named parameters, omitting null values.
Map<String, Object> _props({
  String? className,
  Object? style,
  bool? disabled,
  Map<String, Object>? extra,
  EventHandler? onClick,
  EventHandler? onInput,
  EventHandler? onChange,
  EventHandler? onSubmit,
  EventHandler? onFocus,
  EventHandler? onBlur,
  EventHandler? onKeyDown,
  EventHandler? onKeyUp,
  EventHandler? onMouseOver,
  EventHandler? onMouseOut,
}) {
  final map = <String, Object>{};
  if (className != null) map['className'] = className;
  final resolvedStyle = _resolveStyle(style);
  if (resolvedStyle != null) map['style'] = resolvedStyle;
  if (disabled != null) map['disabled'] = disabled;
  if (onClick != null) map['onClick'] = onClick;
  if (onInput != null) map['onInput'] = onInput;
  if (onChange != null) map['onChange'] = onChange;
  if (onSubmit != null) map['onSubmit'] = onSubmit;
  if (onFocus != null) map['onFocus'] = onFocus;
  if (onBlur != null) map['onBlur'] = onBlur;
  if (onKeyDown != null) map['onKeyDown'] = onKeyDown;
  if (onKeyUp != null) map['onKeyUp'] = onKeyUp;
  if (onMouseOver != null) map['onMouseOver'] = onMouseOver;
  if (onMouseOut != null) map['onMouseOut'] = onMouseOut;
  if (extra != null) map.addAll(extra);
  return map;
}

List<VNode> _childVNodes(List<Widget> children, BuildContext ctx) =>
    [for (final c in children) ctx.build(c)];

// ---------------------------------------------------------------------------
// Block / container
// ---------------------------------------------------------------------------

/// `<div>` element.
class Div extends Widget {
  const Div({
    this.children = const [],
    this.className,
    this.style,
    this.onClick,
    this.onMouseOver,
    this.onMouseOut,
    super.key,
  });

  final List<Widget> children;
  final String? className;
  final Object? style;
  final EventHandler? onClick;
  final EventHandler? onMouseOver;
  final EventHandler? onMouseOut;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'div',
    key: key,
    props: _props(
      className: className,
      style: style,
      onClick: onClick,
      onMouseOver: onMouseOver,
      onMouseOut: onMouseOut,
    ),
    children: _childVNodes(children, context),
  );
}

/// `<span>` element.
class Span extends Widget {
  const Span({
    this.children = const [],
    this.child,
    this.className,
    this.style,
    this.onClick,
    super.key,
  });

  final List<Widget> children;
  final Widget? child;
  final String? className;
  final Object? style;
  final EventHandler? onClick;

  @override
  VNode toVNode(BuildContext context) {
    final kids = child != null ? [child!] : children;
    return VElement(
      tag: 'span',
      key: key,
      props: _props(className: className, style: style, onClick: onClick),
      children: _childVNodes(kids, context),
    );
  }
}

/// `<section>` element.
class Section extends Widget {
  const Section({
    this.children = const [],
    this.className,
    this.style,
    this.id,
    super.key,
  });

  final List<Widget> children;
  final String? className;
  final Object? style;
  final String? id;

  @override
  VNode toVNode(BuildContext context) {
    final p = _props(className: className, style: style);
    if (id != null) p['id'] = id!;
    return VElement(
      tag: 'section',
      key: key,
      props: p,
      children: _childVNodes(children, context),
    );
  }
}

/// `<article>` element.
class Article extends Widget {
  const Article({
    this.children = const [],
    this.className,
    this.style,
    super.key,
  });

  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'article',
    key: key,
    props: _props(className: className, style: style),
    children: _childVNodes(children, context),
  );
}

/// `<header>` element.
class Header extends Widget {
  const Header({
    this.children = const [],
    this.className,
    this.style,
    super.key,
  });

  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'header',
    key: key,
    props: _props(className: className, style: style),
    children: _childVNodes(children, context),
  );
}

/// `<footer>` element.
class Footer extends Widget {
  const Footer({
    this.children = const [],
    this.className,
    this.style,
    super.key,
  });

  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'footer',
    key: key,
    props: _props(className: className, style: style),
    children: _childVNodes(children, context),
  );
}

/// `<main>` element.
class Main extends Widget {
  const Main({
    this.children = const [],
    this.className,
    this.style,
    super.key,
  });

  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'main',
    key: key,
    props: _props(className: className, style: style),
    children: _childVNodes(children, context),
  );
}

/// `<nav>` element.
class Nav extends Widget {
  const Nav({
    this.children = const [],
    this.className,
    this.style,
    super.key,
  });

  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'nav',
    key: key,
    props: _props(className: className, style: style),
    children: _childVNodes(children, context),
  );
}

// ---------------------------------------------------------------------------
// Headings
// ---------------------------------------------------------------------------

/// `<h1>` element.
class H1 extends Widget {
  const H1({this.child, this.children = const [], this.className, this.style, super.key});
  final Widget? child;
  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) {
    final kids = child != null ? [child!] : children;
    return VElement(
      tag: 'h1',
      key: key,
      props: _props(className: className, style: style),
      children: _childVNodes(kids, context),
    );
  }
}

/// `<h2>` element.
class H2 extends Widget {
  const H2({this.child, this.children = const [], this.className, this.style, super.key});
  final Widget? child;
  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) {
    final kids = child != null ? [child!] : children;
    return VElement(tag: 'h2', key: key, props: _props(className: className, style: style), children: _childVNodes(kids, context));
  }
}

/// `<h3>` element.
class H3 extends Widget {
  const H3({this.child, this.children = const [], this.className, this.style, super.key});
  final Widget? child;
  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) {
    final kids = child != null ? [child!] : children;
    return VElement(tag: 'h3', key: key, props: _props(className: className, style: style), children: _childVNodes(kids, context));
  }
}

/// `<h4>` element.
class H4 extends Widget {
  const H4({this.child, this.children = const [], this.className, this.style, super.key});
  final Widget? child;
  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) {
    final kids = child != null ? [child!] : children;
    return VElement(tag: 'h4', key: key, props: _props(className: className, style: style), children: _childVNodes(kids, context));
  }
}

// ---------------------------------------------------------------------------
// Text / inline
// ---------------------------------------------------------------------------

/// `<p>` paragraph element.
class P extends Widget {
  const P({this.child, this.children = const [], this.className, this.style, super.key});
  final Widget? child;
  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) {
    final kids = child != null ? [child!] : children;
    return VElement(tag: 'p', key: key, props: _props(className: className, style: style), children: _childVNodes(kids, context));
  }
}

/// `<strong>` element.
class Strong extends Widget {
  const Strong({required this.child, this.className, super.key});
  final Widget child;
  final String? className;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'strong',
    key: key,
    props: _props(className: className),
    children: [child.toVNode(context)],
  );
}

/// `<em>` element.
class Em extends Widget {
  const Em({required this.child, this.className, super.key});
  final Widget child;
  final String? className;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'em',
    key: key,
    props: _props(className: className),
    children: [child.toVNode(context)],
  );
}

/// `<small>` element.
class Small extends Widget {
  const Small({required this.child, this.className, super.key});
  final Widget child;
  final String? className;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'small',
    key: key,
    props: _props(className: className),
    children: [child.toVNode(context)],
  );
}

/// `<code>` element.
class Code extends Widget {
  const Code({required this.child, this.className, super.key});
  final Widget child;
  final String? className;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'code',
    key: key,
    props: _props(className: className),
    children: [child.toVNode(context)],
  );
}

/// `<pre>` element.
class Pre extends Widget {
  const Pre({required this.child, this.className, super.key});
  final Widget child;
  final String? className;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'pre',
    key: key,
    props: _props(className: className),
    children: [child.toVNode(context)],
  );
}

/// `<hr>` horizontal rule.
class Hr extends Widget {
  const Hr({this.className, super.key});
  final String? className;

  @override
  VNode toVNode(BuildContext context) =>
      VElement(tag: 'hr', key: key, props: _props(className: className));
}

/// `<br>` line break.
class Br extends Widget {
  const Br({super.key});

  @override
  VNode toVNode(BuildContext context) => const VElement(tag: 'br');
}

// ---------------------------------------------------------------------------
// Interactive
// ---------------------------------------------------------------------------

/// `<button>` element.
class Button extends Widget {
  const Button({
    this.child,
    this.children = const [],
    this.className,
    this.style,
    this.disabled,
    this.type,
    this.onClick,
    this.onFocus,
    this.onBlur,
    super.key,
  });

  final Widget? child;
  final List<Widget> children;
  final String? className;
  final Object? style;
  final bool? disabled;
  final String? type;
  final EventHandler? onClick;
  final EventHandler? onFocus;
  final EventHandler? onBlur;

  @override
  VNode toVNode(BuildContext context) {
    final kids = child != null ? [child!] : children;
    final p = _props(
      className: className,
      style: style,
      disabled: disabled,
      onClick: onClick,
      onFocus: onFocus,
      onBlur: onBlur,
    );
    if (type != null) p['type'] = type!;
    return VElement(
      tag: 'button',
      key: key,
      props: p,
      children: _childVNodes(kids, context),
    );
  }
}

/// `<input>` element.
class Input extends Widget {
  const Input({
    this.type = 'text',
    this.value,
    this.placeholder,
    this.disabled,
    this.checked,
    this.className,
    this.style,
    this.onInput,
    this.onChange,
    this.onFocus,
    this.onBlur,
    this.onKeyDown,
    this.onKeyUp,
    super.key,
  });

  final String type;
  final String? value;
  final String? placeholder;
  final bool? disabled;
  final bool? checked;
  final String? className;
  final Object? style;
  final EventHandler? onInput;
  final EventHandler? onChange;
  final EventHandler? onFocus;
  final EventHandler? onBlur;
  final EventHandler? onKeyDown;
  final EventHandler? onKeyUp;

  @override
  VNode toVNode(BuildContext context) {
    final p = _props(
      className: className,
      style: style,
      disabled: disabled,
      onInput: onInput,
      onChange: onChange,
      onFocus: onFocus,
      onBlur: onBlur,
      onKeyDown: onKeyDown,
      onKeyUp: onKeyUp,
    );
    p['type'] = type;
    if (value != null) p['value'] = value!;
    if (placeholder != null) p['placeholder'] = placeholder!;
    if (checked != null) p['checked'] = checked!;
    return VElement(tag: 'input', key: key, props: p);
  }
}

/// `<textarea>` element.
class Textarea extends Widget {
  const Textarea({
    this.value,
    this.placeholder,
    this.rows,
    this.cols,
    this.disabled,
    this.className,
    this.style,
    this.onInput,
    this.onChange,
    super.key,
  });

  final String? value;
  final String? placeholder;
  final int? rows;
  final int? cols;
  final bool? disabled;
  final String? className;
  final Object? style;
  final EventHandler? onInput;
  final EventHandler? onChange;

  @override
  VNode toVNode(BuildContext context) {
    final p = _props(
      className: className,
      style: style,
      disabled: disabled,
      onInput: onInput,
      onChange: onChange,
    );
    if (placeholder != null) p['placeholder'] = placeholder!;
    if (rows != null) p['rows'] = rows.toString();
    if (cols != null) p['cols'] = cols.toString();
    final children = value != null ? [VText(value!)] : <VNode>[];
    return VElement(tag: 'textarea', key: key, props: p, children: children);
  }
}

/// `<select>` element.
class Select extends Widget {
  const Select({
    this.children = const [],
    this.className,
    this.style,
    this.disabled,
    this.onChange,
    super.key,
  });

  final List<Widget> children;
  final String? className;
  final Object? style;
  final bool? disabled;
  final EventHandler? onChange;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'select',
    key: key,
    props: _props(
      className: className,
      style: style,
      disabled: disabled,
      onChange: onChange,
    ),
    children: _childVNodes(children, context),
  );
}

/// `<option>` element.
class Option extends Widget {
  const Option({
    required this.value,
    required this.child,
    this.selected,
    this.disabled,
    super.key,
  });

  final String value;
  final Widget child;
  final bool? selected;
  final bool? disabled;

  @override
  VNode toVNode(BuildContext context) {
    final p = <String, Object>{'value': value};
    if (selected == true) p['selected'] = true;
    if (disabled == true) p['disabled'] = true;
    return VElement(
      tag: 'option',
      key: key,
      props: p,
      children: [child.toVNode(context)],
    );
  }
}

// ---------------------------------------------------------------------------
// Form
// ---------------------------------------------------------------------------

/// `<form>` element.
class Form extends Widget {
  const Form({
    this.children = const [],
    this.className,
    this.style,
    this.onSubmit,
    super.key,
  });

  final List<Widget> children;
  final String? className;
  final Object? style;
  final EventHandler? onSubmit;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'form',
    key: key,
    props: _props(className: className, style: style, onSubmit: onSubmit),
    children: _childVNodes(children, context),
  );
}

/// `<label>` element.
class Label extends Widget {
  const Label({
    required this.child,
    this.htmlFor,
    this.className,
    this.style,
    super.key,
  });

  final Widget child;
  final String? htmlFor;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) {
    final p = _props(className: className, style: style);
    if (htmlFor != null) p['for'] = htmlFor!;
    return VElement(
      tag: 'label',
      key: key,
      props: p,
      children: [child.toVNode(context)],
    );
  }
}

// ---------------------------------------------------------------------------
// Lists
// ---------------------------------------------------------------------------

/// `<ul>` unordered list.
class Ul extends Widget {
  const Ul({this.children = const [], this.className, this.style, super.key});
  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'ul',
    key: key,
    props: _props(className: className, style: style),
    children: _childVNodes(children, context),
  );
}

/// `<ol>` ordered list.
class Ol extends Widget {
  const Ol({this.children = const [], this.className, this.style, super.key});
  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'ol',
    key: key,
    props: _props(className: className, style: style),
    children: _childVNodes(children, context),
  );
}

/// `<li>` list item.
class Li extends Widget {
  const Li({this.child, this.children = const [], this.className, this.style, this.onClick, super.key});
  final Widget? child;
  final List<Widget> children;
  final String? className;
  final Object? style;
  final EventHandler? onClick;

  @override
  VNode toVNode(BuildContext context) {
    final kids = child != null ? [child!] : children;
    return VElement(
      tag: 'li',
      key: key,
      props: _props(className: className, style: style, onClick: onClick),
      children: _childVNodes(kids, context),
    );
  }
}

// ---------------------------------------------------------------------------
// Media / links
// ---------------------------------------------------------------------------

/// `<a>` anchor element.
class A extends Widget {
  const A({
    required this.child,
    this.href,
    this.target,
    this.className,
    this.style,
    this.onClick,
    super.key,
  });

  final Widget child;
  final String? href;
  final String? target;
  final String? className;
  final Object? style;
  final EventHandler? onClick;

  @override
  VNode toVNode(BuildContext context) {
    final p = _props(className: className, style: style, onClick: onClick);
    if (href != null) p['href'] = href!;
    if (target != null) p['target'] = target!;
    return VElement(
      tag: 'a',
      key: key,
      props: p,
      children: [child.toVNode(context)],
    );
  }
}

/// `<img>` image element.
class Img extends Widget {
  const Img({
    required this.src,
    this.alt = '',
    this.className,
    this.style,
    this.width,
    this.height,
    super.key,
  });

  final String src;
  final String alt;
  final String? className;
  final Object? style;
  final int? width;
  final int? height;

  @override
  VNode toVNode(BuildContext context) {
    final p = _props(className: className, style: style);
    p['src'] = src;
    p['alt'] = alt;
    if (width != null) p['width'] = width.toString();
    if (height != null) p['height'] = height.toString();
    return VElement(tag: 'img', key: key, props: p);
  }
}

// ---------------------------------------------------------------------------
// Table
// ---------------------------------------------------------------------------

/// `<table>` element.
class Table extends Widget {
  const Table({this.children = const [], this.className, this.style, super.key});
  final List<Widget> children;
  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) => VElement(
    tag: 'table',
    key: key,
    props: _props(className: className, style: style),
    children: _childVNodes(children, context),
  );
}

/// `<thead>`, `<tbody>`, `<tfoot>` helpers.
class Thead extends Widget {
  const Thead({this.children = const [], this.className, super.key});
  final List<Widget> children;
  final String? className;
  @override
  VNode toVNode(BuildContext context) => VElement(tag: 'thead', key: key, props: _props(className: className), children: _childVNodes(children, context));
}

class Tbody extends Widget {
  const Tbody({this.children = const [], this.className, super.key});
  final List<Widget> children;
  final String? className;
  @override
  VNode toVNode(BuildContext context) => VElement(tag: 'tbody', key: key, props: _props(className: className), children: _childVNodes(children, context));
}

class Tr extends Widget {
  const Tr({this.children = const [], this.className, super.key});
  final List<Widget> children;
  final String? className;
  @override
  VNode toVNode(BuildContext context) => VElement(tag: 'tr', key: key, props: _props(className: className), children: _childVNodes(children, context));
}

class Th extends Widget {
  const Th({this.child, this.children = const [], this.className, super.key});
  final Widget? child;
  final List<Widget> children;
  final String? className;
  @override
  VNode toVNode(BuildContext context) {
    final kids = child != null ? [child!] : children;
    return VElement(tag: 'th', key: key, props: _props(className: className), children: _childVNodes(kids, context));
  }
}

class Td extends Widget {
  const Td({this.child, this.children = const [], this.className, super.key});
  final Widget? child;
  final List<Widget> children;
  final String? className;
  @override
  VNode toVNode(BuildContext context) {
    final kids = child != null ? [child!] : children;
    return VElement(tag: 'td', key: key, props: _props(className: className), children: _childVNodes(kids, context));
  }
}

// ---------------------------------------------------------------------------
// GestureDetector — декларативный обработчик жестов/событий
// ---------------------------------------------------------------------------

/// Виджет-обёртка, которая перехватывает пользовательские жесты и события
/// мыши/клавиатуры. Рендерит `<div>` с `display:contents`, чтобы не влиять
/// на лейаут дочернего элемента.
///
/// ```dart
/// GestureDetector(
///   onTap: (_) => print('tapped'),
///   onDoubleTap: (_) => print('double-tapped'),
///   child: Img(src: 'photo.jpg'),
/// )
/// ```
class GestureDetector extends Widget {
  const GestureDetector({
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onMouseEnter,
    this.onMouseLeave,
    this.onMouseDown,
    this.onMouseUp,
    this.onMouseMove,
    this.onKeyDown,
    this.onKeyUp,
    this.className,
    this.style,
    super.key,
  });

  final Widget child;

  /// Срабатывает при одиночном клике / тапе (click).
  final EventHandler? onTap;

  /// Срабатывает при двойном клике (dblclick).
  final EventHandler? onDoubleTap;

  /// Срабатывает при долгом нажатии (contextmenu — правая кнопка / долгий тап).
  final EventHandler? onLongPress;

  final EventHandler? onMouseEnter;
  final EventHandler? onMouseLeave;
  final EventHandler? onMouseDown;
  final EventHandler? onMouseUp;
  final EventHandler? onMouseMove;
  final EventHandler? onKeyDown;
  final EventHandler? onKeyUp;

  final String? className;
  final Object? style;

  @override
  VNode toVNode(BuildContext context) {
    final resolved = _resolveStyle(style);
    final styleMap = <String, String>{'display': 'contents', ...?resolved};
    final p = _props(
      className: className,
      style: styleMap,
      onClick: onTap,
      onMouseOver: onMouseEnter,
      onMouseOut: onMouseLeave,
      onKeyDown: onKeyDown,
      onKeyUp: onKeyUp,
    );
    if (onDoubleTap != null) p['onDblClick'] = onDoubleTap!;
    if (onLongPress != null) p['onContextMenu'] = onLongPress!;
    if (onMouseDown != null) p['onMouseDown'] = onMouseDown!;
    if (onMouseUp != null) p['onMouseUp'] = onMouseUp!;
    if (onMouseMove != null) p['onMouseMove'] = onMouseMove!;
    return VElement(
      tag: 'div',
      key: key,
      props: p,
      children: [child.toVNode(context)],
    );
  }
}

// ---------------------------------------------------------------------------
// Container — Flutter-like box with decoration, padding, margin
// ---------------------------------------------------------------------------

/// A convenience widget that combines a `<div>` with [BoxDecoration],
/// [EdgeInsets] padding and margin, and optional sizing — similar to
/// Flutter's `Container`.
///
/// ```dart
/// Container(
///   padding: EdgeInsets.all(16),
///   margin: EdgeInsets.symmetric(vertical: 8),
///   decoration: BoxDecoration(
///     color: '#111118',
///     borderRadius: BorderRadius.circular(12),
///     border: Border.all(color: '#1e1e2e'),
///   ),
///   child: Text('Hello'),
/// )
/// ```
class Container extends Widget {
  const Container({
    this.child,
    this.children = const [],
    this.decoration,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.className,
    this.style,
    this.onClick,
    super.key,
  });

  final Widget? child;
  final List<Widget> children;
  final BoxDecoration? decoration;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final String? className;
  final Object? style;
  final EventHandler? onClick;

  @override
  VNode toVNode(BuildContext context) {
    final styleMap = <String, String>{};
    if (decoration != null) styleMap.addAll(decoration!.toStyleMap());
    if (padding != null) styleMap['padding'] = padding!.toCss();
    if (margin != null) styleMap['margin'] = margin!.toCss();
    if (width != null) styleMap['width'] = '${width}px';
    if (height != null) styleMap['height'] = '${height}px';
    final resolved = _resolveStyle(style);
    if (resolved != null) styleMap.addAll(resolved);

    final props = _props(
      className: className,
      style: styleMap.isEmpty ? null : styleMap,
      onClick: onClick,
    );

    final kids = child != null ? [child!] : children;
    return VElement(
      tag: 'div',
      key: key,
      props: props,
      children: _childVNodes(kids, context),
    );
  }
}
