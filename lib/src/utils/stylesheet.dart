/// CSS injection utility with Flutter-like StyleSheet API.
library druid.utils.stylesheet;

import 'package:web/web.dart' as web;

// ---------------------------------------------------------------------------
// CssRule — abstract base
// ---------------------------------------------------------------------------

/// Base class for any CSS rule that can emit a CSS string.
abstract class CssRule {
  const CssRule();

  /// Compiles this rule to a CSS string.
  String toCss();
}

// ---------------------------------------------------------------------------
// StyleRule
// ---------------------------------------------------------------------------

/// A single CSS selector block, with optional pseudo-class overrides.
///
/// ```dart
/// StyleRule(
///   '.btn-primary',
///   {'transition': 'transform 0.2s', 'font-weight': '600'},
///   hover: {'transform': 'translateY(-2px)'},
///   after: {'content': "''", 'display': 'block'},
/// )
/// ```
class StyleRule extends CssRule {
  const StyleRule(
    this.selector,
    this.props, {
    this.hover,
    this.focus,
    this.active,
    this.before,
    this.after,
  });

  final String selector;
  final Map<String, String> props;
  final Map<String, String>? hover;
  final Map<String, String>? focus;
  final Map<String, String>? active;
  final Map<String, String>? before;
  final Map<String, String>? after;

  @override
  String toCss() {
    final buf = StringBuffer();
    if (props.isNotEmpty) buf.write(_block(selector, props));
    if (hover != null) buf.write(_block('$selector:hover', hover!));
    if (focus != null) buf.write(_block('$selector:focus', focus!));
    if (active != null) buf.write(_block('$selector:active', active!));
    if (before != null) buf.write(_block('$selector::before', before!));
    if (after != null) buf.write(_block('$selector::after', after!));
    return buf.toString();
  }

  static String _block(String selector, Map<String, String> props) {
    final decls = props.entries.map((e) => '  ${e.key}: ${e.value};').join('\n');
    return '$selector {\n$decls\n}\n';
  }
}

// ---------------------------------------------------------------------------
// Keyframes
// ---------------------------------------------------------------------------

/// A CSS `@keyframes` animation definition.
///
/// ```dart
/// Keyframes('shimmer', {
///   '0%':   {'background-position': '-200% center'},
///   '100%': {'background-position':  '200% center'},
/// })
/// ```
class Keyframes extends CssRule {
  const Keyframes(this.name, this.stops);

  /// The animation name referenced in `animation:` properties.
  final String name;

  /// Map of stop identifiers (e.g. `'0%'`, `'50%'`, `'from'`, `'to'`)
  /// to their property maps.
  final Map<String, Map<String, String>> stops;

  @override
  String toCss() {
    final buf = StringBuffer('@keyframes $name {\n');
    for (final entry in stops.entries) {
      final decls =
          entry.value.entries.map((e) => '    ${e.key}: ${e.value};').join('\n');
      buf.writeln('  ${entry.key} {\n$decls\n  }');
    }
    buf.write('}\n');
    return buf.toString();
  }
}

// ---------------------------------------------------------------------------
// MediaQuery
// ---------------------------------------------------------------------------

/// A CSS `@media` block containing nested [CssRule]s.
///
/// ```dart
/// MediaQuery('max-width: 900px', [
///   StyleRule('.grid', {'grid-template-columns': '1fr !important'}),
/// ])
/// ```
///
/// Pass the condition **without** outer parentheses — they are added automatically.
class MediaQuery extends CssRule {
  const MediaQuery(this.condition, this.rules);

  /// The media condition, e.g. `'max-width: 900px'` or `'prefers-color-scheme: dark'`.
  final String condition;

  /// Nested rules rendered inside the `@media` block.
  final List<CssRule> rules;

  @override
  String toCss() {
    final inner = rules.map((r) {
      return r
          .toCss()
          .split('\n')
          .map((line) => line.isEmpty ? '' : '  $line')
          .join('\n');
    }).join('\n');
    final cond = condition.startsWith('(') ? condition : '($condition)';
    return '@media $cond {\n$inner}\n';
  }
}

// ---------------------------------------------------------------------------
// StyleSheet
// ---------------------------------------------------------------------------

/// A collection of [CssRule]s that compiles to a complete CSS string.
///
/// ```dart
/// injectStyleSheet(StyleSheet(rules: [
///   StyleRule('*, *::before, *::after', {
///     'box-sizing': 'border-box',
///     'margin': '0',
///     'padding': '0',
///   }),
///   Keyframes('fadeIn', {
///     'from': {'opacity': '0'},
///     'to':   {'opacity': '1'},
///   }),
///   MediaQuery('max-width: 600px', [
///     StyleRule('body', {'font-size': '14px'}),
///   ]),
/// ]));
/// ```
class StyleSheet {
  const StyleSheet({required this.rules});

  final List<CssRule> rules;

  /// Compiles all rules to a single CSS string.
  String toCss() => rules.map((r) => r.toCss()).join('\n');
}

// ---------------------------------------------------------------------------
// injectStyleSheet
// ---------------------------------------------------------------------------

/// Injects CSS into a `<style>` element appended to `document.head`.
///
/// Accepts either a raw [String] (backward compatible) or a [StyleSheet] object:
/// ```dart
/// // Raw string — still works:
/// injectStyleSheet('body { margin: 0; }');
///
/// // Typed StyleSheet — Flutter-like API:
/// injectStyleSheet(StyleSheet(rules: [
///   StyleRule('body', {'margin': '0'}),
/// ]));
/// ```
void injectStyleSheet(Object cssOrSheet) {
  final String css;
  if (cssOrSheet is StyleSheet) {
    css = cssOrSheet.toCss();
  } else if (cssOrSheet is String) {
    css = cssOrSheet;
  } else {
    throw ArgumentError(
      'injectStyleSheet expects a String or StyleSheet, '
      'got ${cssOrSheet.runtimeType}',
    );
  }
  final style = web.document.createElement('style') as web.HTMLStyleElement;
  style.textContent = css;
  web.document.head!.appendChild(style);
}
