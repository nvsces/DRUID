/// CSS injection utility.
library druid.utils.stylesheet;

import 'package:web/web.dart' as web;

/// Injects [css] as a `<style>` element into `document.head`.
///
/// Call this before [runApp] to apply global styles:
/// ```dart
/// void main() {
///   injectStyleSheet('''
///     body { margin: 0; font-family: sans-serif; }
///     .btn:hover { opacity: 0.9; }
///   ''');
///   runApp(MyApp());
/// }
/// ```
void injectStyleSheet(String css) {
  final style = web.document.createElement('style') as web.HTMLStyleElement;
  style.textContent = css;
  web.document.head!.appendChild(style);
}
