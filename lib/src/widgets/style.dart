/// Flutter-like style classes for druid widgets.
///
/// Usage:
/// ```dart
/// Div(
///   decoration: BoxDecoration(
///     color: Color(0xFF111118),
///     borderRadius: BorderRadius.circular(12),
///     border: Border.all(color: Color(0xFF1e1e2e)),
///   ),
///   padding: EdgeInsets.all(16),
///   child: StyledText('Hello', style: TextStyle(fontSize: 16, color: Color(0xFFe2e8f0))),
/// )
/// ```
library druid.widgets.style;

import 'widget.dart';
import 'context.dart';
import '../vdom/vnode.dart';
import '../core/color.dart';

// ---------------------------------------------------------------------------
// EdgeInsets
// ---------------------------------------------------------------------------

class EdgeInsets {
  final double top;
  final double right;
  final double bottom;
  final double left;

  const EdgeInsets.fromLTRB(this.left, this.top, this.right, this.bottom);

  const EdgeInsets.all(double value)
      : top = value,
        right = value,
        bottom = value,
        left = value;

  const EdgeInsets.symmetric({double vertical = 0, double horizontal = 0})
      : top = vertical,
        right = horizontal,
        bottom = vertical,
        left = horizontal;

  const EdgeInsets.only({
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.left = 0,
  });

  static const zero = EdgeInsets.all(0);

  String toCss() => '${top}px ${right}px ${bottom}px ${left}px';

  @override
  String toString() => 'EdgeInsets($left, $top, $right, $bottom)';
}

// ---------------------------------------------------------------------------
// BorderRadius
// ---------------------------------------------------------------------------

class BorderRadius {
  final double topLeft;
  final double topRight;
  final double bottomRight;
  final double bottomLeft;

  const BorderRadius.all(double value)
      : topLeft = value,
        topRight = value,
        bottomRight = value,
        bottomLeft = value;

  const BorderRadius.circular(double radius)
      : topLeft = radius,
        topRight = radius,
        bottomRight = radius,
        bottomLeft = radius;

  const BorderRadius.only({
    this.topLeft = 0,
    this.topRight = 0,
    this.bottomRight = 0,
    this.bottomLeft = 0,
  });

  String toCss() =>
      '${topLeft}px ${topRight}px ${bottomRight}px ${bottomLeft}px';
}

// ---------------------------------------------------------------------------
// Border
// ---------------------------------------------------------------------------

class Border {
  final double width;
  final Color color;
  final String style;

  const Border({this.width = 1, this.color = const Color(0xFF000000), this.style = 'solid'});

  const Border.all({double width = 1, Color color = const Color(0xFF000000)})
      : this(width: width, color: color);

  String toCss() => '${width}px $style ${color.toCss()}';
}

// ---------------------------------------------------------------------------
// BoxShadow
// ---------------------------------------------------------------------------

class BoxShadow {
  final Color color;
  final double offsetX;
  final double offsetY;
  final double blurRadius;
  final double spreadRadius;

  const BoxShadow({
    required this.color,
    this.offsetX = 0,
    this.offsetY = 0,
    this.blurRadius = 0,
    this.spreadRadius = 0,
  });

  String toCss() =>
      '${offsetX}px ${offsetY}px ${blurRadius}px ${spreadRadius}px ${color.toCss()}';
}

// ---------------------------------------------------------------------------
// BoxDecoration
// ---------------------------------------------------------------------------

/// Describes how to paint a box — background, border, border-radius, shadow.
/// Convert to a CSS style map via [toStyleMap].
class BoxDecoration {
  final Color? color;
  final String? gradient;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const BoxDecoration({
    this.color,
    this.gradient,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  Map<String, String> toStyleMap() {
    final map = <String, String>{};
    if (gradient != null) {
      map['background'] = gradient!;
    } else if (color != null) {
      map['background'] = color!.toCss();
    }
    if (borderRadius != null) {
      map['border-radius'] = borderRadius!.toCss();
    }
    if (border != null) {
      map['border'] = border!.toCss();
    }
    if (boxShadow != null && boxShadow!.isNotEmpty) {
      map['box-shadow'] = boxShadow!.map((s) => s.toCss()).join(', ');
    }
    return map;
  }
}

// ---------------------------------------------------------------------------
// TextStyle
// ---------------------------------------------------------------------------

enum FontWeight {
  w100,
  w200,
  w300,
  normal,
  w500,
  w600,
  bold,
  w800,
  w900,
}

enum FontStyle { normal, italic }

enum TextAlign { left, right, center, justify, start, end }

enum TextOverflow { clip, ellipsis }

/// Describes how to style text.
class TextStyle {
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? lineHeight;
  final double? letterSpacing;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final String? fontFamily;
  final String? textDecoration;

  const TextStyle({
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
    this.letterSpacing,
    this.textAlign,
    this.overflow,
    this.fontFamily,
    this.textDecoration,
  });

  Map<String, String> toStyleMap() {
    final map = <String, String>{};
    if (color != null) map['color'] = color!.toCss();
    if (fontSize != null) map['font-size'] = '${fontSize}px';
    if (fontWeight != null) map['font-weight'] = _fontWeightCss(fontWeight!);
    if (fontStyle != null) {
      map['font-style'] = fontStyle == FontStyle.italic ? 'italic' : 'normal';
    }
    if (lineHeight != null) map['line-height'] = '$lineHeight';
    if (letterSpacing != null) map['letter-spacing'] = '${letterSpacing}px';
    if (textAlign != null) map['text-align'] = textAlign!.name;
    if (overflow == TextOverflow.ellipsis) {
      map['overflow'] = 'hidden';
      map['text-overflow'] = 'ellipsis';
      map['white-space'] = 'nowrap';
    }
    if (fontFamily != null) map['font-family'] = fontFamily!;
    if (textDecoration != null) map['text-decoration'] = textDecoration!;
    return map;
  }

  static String _fontWeightCss(FontWeight fw) => switch (fw) {
        FontWeight.w100 => '100',
        FontWeight.w200 => '200',
        FontWeight.w300 => '300',
        FontWeight.normal => '400',
        FontWeight.w500 => '500',
        FontWeight.w600 => '600',
        FontWeight.bold => '700',
        FontWeight.w800 => '800',
        FontWeight.w900 => '900',
      };
}

// ---------------------------------------------------------------------------
// StyledText widget helper — merges TextStyle into inline style
// ---------------------------------------------------------------------------

/// A text node wrapped in a `<span>` with a [TextStyle] applied.
class StyledText extends Widget {
  const StyledText(
    this.text, {
    required this.style,
    this.className,
    super.key,
  });

  final String text;
  final TextStyle style;
  final String? className;

  @override
  VNode toVNode(BuildContext context) {
    final props = <String, Object>{...style.toStyleMap()};
    if (className != null) props['className'] = className!;
    return VElement(
      tag: 'span',
      key: key,
      props: props,
      children: [VText(text)],
    );
  }
}
