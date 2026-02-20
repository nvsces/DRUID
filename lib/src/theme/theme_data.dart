/// Flutter-like ThemeData, ColorScheme and TextTheme for druid.
library druid.theme.theme_data;

import '../core/color.dart';
import '../widgets/style.dart';

// ---------------------------------------------------------------------------
// ColorScheme
// ---------------------------------------------------------------------------

/// A set of 12 colors based on the Material Design 3 color scheme.
///
/// Identical structure to Flutter's [ColorScheme]:
/// ```dart
/// ColorScheme.light(primary: Color(0xFF3e5efe))
/// ColorScheme.fromSeed(seedColor: Color(0xFF3e5efe))
/// ```
class ColorScheme {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color surface;
  final Color onSurface;
  final Color surfaceContainerHighest;
  final Color error;
  final Color onError;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;

  const ColorScheme({
    required this.primary,
    required this.onPrimary,
    this.primaryContainer = const Color(0xFFdde1ff),
    this.onPrimaryContainer = const Color(0xFF00105c),
    required this.secondary,
    required this.onSecondary,
    this.secondaryContainer = const Color(0xFFf9d8f7),
    this.onSecondaryContainer = const Color(0xFF370035),
    required this.surface,
    required this.onSurface,
    this.surfaceContainerHighest = const Color(0xFFe4e1ec),
    this.error = const Color(0xFFba1a1a),
    this.onError = const Color(0xFFffffff),
    this.outline = const Color(0xFF79757f),
    this.outlineVariant = const Color(0xFFcac4cf),
    this.shadow = const Color(0xFF000000),
    this.scrim = const Color(0xFF000000),
  });

  /// A light color scheme — white surfaces, blue/pink accents.
  const ColorScheme.light({
    Color primary = const Color(0xFF3e5efe),
    Color onPrimary = const Color(0xFFffffff),
    Color secondary = const Color(0xFFee61e4),
    Color onSecondary = const Color(0xFFffffff),
    Color surface = const Color(0xFFffffff),
    Color onSurface = const Color(0xFF1a1a2e),
  }) : this(
          primary: primary,
          onPrimary: onPrimary,
          secondary: secondary,
          onSecondary: onSecondary,
          surface: surface,
          onSurface: onSurface,
        );

  /// A dark color scheme — dark surfaces, lighter accents.
  const ColorScheme.dark({
    Color primary = const Color(0xFFb8c4ff),
    Color onPrimary = const Color(0xFF002082),
    Color secondary = const Color(0xFFf4b0ef),
    Color onSecondary = const Color(0xFF5b0058),
    Color surface = const Color(0xFF131318),
    Color onSurface = const Color(0xFFe5e0ec),
  }) : this(
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: const Color(0xFF0038a4),
          onPrimaryContainer: const Color(0xFFdde1ff),
          secondary: secondary,
          onSecondary: onSecondary,
          secondaryContainer: const Color(0xFF7e007b),
          onSecondaryContainer: const Color(0xFFf9d8f7),
          surface: surface,
          onSurface: onSurface,
          surfaceContainerHighest: const Color(0xFF46434d),
          outline: const Color(0xFF938f99),
          outlineVariant: const Color(0xFF46434d),
        );

  /// Generates a color scheme from a single [seedColor].
  ///
  /// This is a simplified derivation (not the full Material 3 tonal palette).
  factory ColorScheme.fromSeed({
    required Color seedColor,
    bool dark = false,
  }) {
    if (dark) {
      return ColorScheme.dark(primary: seedColor);
    }
    return ColorScheme.light(primary: seedColor);
  }
}

// ---------------------------------------------------------------------------
// TextTheme
// ---------------------------------------------------------------------------

/// A set of text styles matching the Material Design 3 type scale.
///
/// Identical structure to Flutter's [TextTheme]:
/// ```dart
/// TextTheme(
///   displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w800),
///   bodyMedium: TextStyle(fontSize: 14),
/// )
/// ```
class TextTheme {
  // Display
  final TextStyle? displayLarge;
  final TextStyle? displayMedium;
  final TextStyle? displaySmall;
  // Headline
  final TextStyle? headlineLarge;
  final TextStyle? headlineMedium;
  final TextStyle? headlineSmall;
  // Title
  final TextStyle? titleLarge;
  final TextStyle? titleMedium;
  final TextStyle? titleSmall;
  // Body
  final TextStyle? bodyLarge;
  final TextStyle? bodyMedium;
  final TextStyle? bodySmall;
  // Label
  final TextStyle? labelLarge;
  final TextStyle? labelMedium;
  final TextStyle? labelSmall;

  const TextTheme({
    this.displayLarge,
    this.displayMedium,
    this.displaySmall,
    this.headlineLarge,
    this.headlineMedium,
    this.headlineSmall,
    this.titleLarge,
    this.titleMedium,
    this.titleSmall,
    this.bodyLarge,
    this.bodyMedium,
    this.bodySmall,
    this.labelLarge,
    this.labelMedium,
    this.labelSmall,
  });

  /// Default Material 3 type scale with no explicit colors set.
  static const TextTheme defaults = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.normal),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.normal),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.normal),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.normal),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.normal),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  );

  /// Returns a new [TextTheme] with overridden fields merged on top of [defaults].
  TextTheme merge(TextTheme? other) {
    if (other == null) return this;
    return TextTheme(
      displayLarge: other.displayLarge ?? displayLarge,
      displayMedium: other.displayMedium ?? displayMedium,
      displaySmall: other.displaySmall ?? displaySmall,
      headlineLarge: other.headlineLarge ?? headlineLarge,
      headlineMedium: other.headlineMedium ?? headlineMedium,
      headlineSmall: other.headlineSmall ?? headlineSmall,
      titleLarge: other.titleLarge ?? titleLarge,
      titleMedium: other.titleMedium ?? titleMedium,
      titleSmall: other.titleSmall ?? titleSmall,
      bodyLarge: other.bodyLarge ?? bodyLarge,
      bodyMedium: other.bodyMedium ?? bodyMedium,
      bodySmall: other.bodySmall ?? bodySmall,
      labelLarge: other.labelLarge ?? labelLarge,
      labelMedium: other.labelMedium ?? labelMedium,
      labelSmall: other.labelSmall ?? labelSmall,
    );
  }
}

// ---------------------------------------------------------------------------
// ThemeData
// ---------------------------------------------------------------------------

/// Holds the complete configuration for the app's visual theme.
///
/// Pass to [runApp] to apply globally:
/// ```dart
/// runApp(
///   MyApp(),
///   theme: ThemeData(
///     colorScheme: ColorScheme.light(primary: Color(0xFF3e5efe)),
///     fontFamily: 'Jost',
///   ),
/// );
/// ```
///
/// Access anywhere via [Theme.of]:
/// ```dart
/// final theme = Theme.of(context);
/// final primary = theme.colorScheme.primary.toCss(); // '#3e5efe'
/// ```
class ThemeData {
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  /// Default font family applied to the app root.
  final String? fontFamily;

  /// Background color of the scaffold / app root container.
  final Color? scaffoldBackgroundColor;

  ThemeData({
    ColorScheme? colorScheme,
    TextTheme? textTheme,
    this.fontFamily,
    this.scaffoldBackgroundColor,
  })  : colorScheme = colorScheme ?? const ColorScheme.light(),
        textTheme = TextTheme.defaults.merge(textTheme);

  /// Convenient light theme factory — identical to Flutter's [ThemeData.light].
  factory ThemeData.light() => ThemeData(colorScheme: const ColorScheme.light());

  /// Convenient dark theme factory — identical to Flutter's [ThemeData.dark].
  factory ThemeData.dark() => ThemeData(colorScheme: const ColorScheme.dark());
}
