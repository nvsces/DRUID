/// Flutter-compatible Color class for druid.
library druid.core.color;

/// An immutable 32-bit color value in ARGB format.
///
/// Identical API to Flutter's [Color]:
/// ```dart
/// const blue = Color(0xFF3e5efe);
/// const semiRed = Color.fromARGB(128, 255, 0, 0);
/// const green = Color.fromRGBO(0, 200, 0, 0.8);
/// ```
class Color {
  /// The raw ARGB value (0xAARRGGBB).
  final int value;

  /// Creates a color from a 32-bit ARGB integer.
  ///
  /// The most significant byte is alpha, then red, green, blue:
  /// `Color(0xFFRRGGBB)` — fully opaque.
  const Color(this.value);

  /// Creates a color from individual 8-bit ARGB channels (0–255 each).
  const Color.fromARGB(int a, int r, int g, int b)
      : value = ((a & 0xFF) << 24) |
            ((r & 0xFF) << 16) |
            ((g & 0xFF) << 8) |
            (b & 0xFF);

  /// Creates a color from RGB channels (0–255) and an opacity fraction (0.0–1.0).
  Color.fromRGBO(int r, int g, int b, double opacity)
      : value = ((opacity.clamp(0.0, 1.0) * 255).round() << 24) |
            ((r & 0xFF) << 16) |
            ((g & 0xFF) << 8) |
            (b & 0xFF);

  /// Alpha channel (0–255). 0 = fully transparent, 255 = fully opaque.
  int get alpha => (value >> 24) & 0xFF;

  /// Red channel (0–255).
  int get red => (value >> 16) & 0xFF;

  /// Green channel (0–255).
  int get green => (value >> 8) & 0xFF;

  /// Blue channel (0–255).
  int get blue => value & 0xFF;

  /// Opacity as a fraction (0.0–1.0).
  double get opacity => alpha / 255.0;

  /// Returns a copy of this color with the given [opacity] (0.0–1.0).
  Color withOpacity(double opacity) =>
      Color.fromARGB((opacity.clamp(0.0, 1.0) * 255).round(), red, green, blue);

  /// Returns a copy of this color with the given [alpha] (0–255).
  Color withAlpha(int alpha) => Color.fromARGB(alpha & 0xFF, red, green, blue);

  /// Returns a copy of this color with the given [red] channel.
  Color withRed(int red) => Color.fromARGB(alpha, red & 0xFF, green, blue);

  /// Returns a copy of this color with the given [green] channel.
  Color withGreen(int green) => Color.fromARGB(alpha, red, green & 0xFF, blue);

  /// Returns a copy of this color with the given [blue] channel.
  Color withBlue(int blue) => Color.fromARGB(alpha, red, green, blue & 0xFF);

  /// Compiles this color to a CSS string.
  ///
  /// - Fully opaque colors → `'#rrggbb'`
  /// - Transparent colors → `'rgba(r, g, b, opacity)'`
  String toCss() {
    if (alpha == 255) {
      final r = red.toRadixString(16).padLeft(2, '0');
      final g = green.toRadixString(16).padLeft(2, '0');
      final b = blue.toRadixString(16).padLeft(2, '0');
      return '#$r$g$b';
    }
    final op = (opacity * 1000).round() / 1000;
    return 'rgba($red, $green, $blue, $op)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Color && value == other.value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Color(0x${value.toRadixString(16).padLeft(8, '0').toUpperCase()})';
}
