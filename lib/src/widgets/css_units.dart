/// Typed CSS length / value units for the druid style system.
///
/// ```dart
/// CssStyle(
///   width: Px(200),
///   maxWidth: Percent(100),
///   fontSize: Rem(1.2),
///   height: Auto(),
/// )
/// ```
library druid.widgets.css_units;

// ---------------------------------------------------------------------------
// Base type
// ---------------------------------------------------------------------------

/// A typed CSS value that can be converted to a CSS string.
sealed class CssValue {
  const CssValue();

  /// Returns the CSS string representation, e.g. `'10px'`, `'50%'`, `'auto'`.
  String toCss();

  @override
  String toString() => toCss();
}

// ---------------------------------------------------------------------------
// Concrete units
// ---------------------------------------------------------------------------

/// Pixels: `10` → `'10px'`.
class Px extends CssValue {
  final num value;
  const Px(this.value);

  @override
  String toCss() => '${value}px';

  @override
  bool operator ==(Object other) => other is Px && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Percentage: `50` → `'50%'`.
class Percent extends CssValue {
  final num value;
  const Percent(this.value);

  @override
  String toCss() => '${value}%';

  @override
  bool operator ==(Object other) => other is Percent && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Root em: `1.5` → `'1.5rem'`.
class Rem extends CssValue {
  final num value;
  const Rem(this.value);

  @override
  String toCss() => '${value}rem';

  @override
  bool operator ==(Object other) => other is Rem && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Em (relative to parent font-size): `2` → `'2em'`.
///
/// Named `CssEm` to avoid conflict with the `Em` HTML widget.
class CssEm extends CssValue {
  final num value;
  const CssEm(this.value);

  @override
  String toCss() => '${value}em';

  @override
  bool operator ==(Object other) => other is CssEm && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Viewport width: `100` → `'100vw'`.
class Vw extends CssValue {
  final num value;
  const Vw(this.value);

  @override
  String toCss() => '${value}vw';

  @override
  bool operator ==(Object other) => other is Vw && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Viewport height: `100` → `'100vh'`.
class Vh extends CssValue {
  final num value;
  const Vh(this.value);

  @override
  String toCss() => '${value}vh';

  @override
  bool operator ==(Object other) => other is Vh && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// `auto` keyword.
class Auto extends CssValue {
  const Auto();

  @override
  String toCss() => 'auto';

  @override
  bool operator ==(Object other) => other is Auto;

  @override
  int get hashCode => 0x617574; // 'aut'
}

/// Raw CSS string escape hatch: `CssRaw('calc(100% - 20px)')`.
class CssRaw extends CssValue {
  final String value;
  const CssRaw(this.value);

  @override
  String toCss() => value;

  @override
  bool operator ==(Object other) => other is CssRaw && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
