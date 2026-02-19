/// druid — Dart UI Toolkit
///
/// A lightweight web UI framework with Virtual DOM and Signals reactivity.
///
/// ```dart
/// import 'package:druid/druid.dart';
///
/// class Counter extends StatefulWidget {
///   @override
///   State<Counter> createState() => _CounterState();
/// }
///
/// class _CounterState extends State<Counter> {
///   late final count = signal(0);
///
///   @override
///   Widget build(BuildContext context) => Div(children: [
///     H1(child: Text('Count: ${count.value}')),
///     Button(onClick: (_) => count.value++, child: Text('+')),
///   ]);
/// }
///
/// void main() => runApp(Counter());
/// ```
library druid;

// Core reactivity
export 'src/core/signal.dart' show Signal, Computed, Effect, signal, computed, effect;
export 'src/core/scheduler.dart' show batch;

// Virtual DOM (exposed for advanced use)
export 'src/vdom/vnode.dart' show VNode, VElement, VText, EventHandler;
export 'src/vdom/differ.dart'
    show
        Patch,
        PatchReplace,
        PatchText,
        PatchSetProp,
        PatchRemoveProp,
        PatchInsertChild,
        PatchRemoveChild,
        PatchMoveChild,
        PatchChild,
        diff;
export 'src/vdom/patcher.dart' show mount, applyPatches;

// Widget model
export 'src/widgets/widget.dart' show Widget, StatelessWidget, StatefulWidget, State;
export 'src/widgets/context.dart' show BuildContext;
export 'src/widgets/text.dart' show Text;

// HTML widgets
export 'src/widgets/html.dart'
    show
        // Block
        Div, Span, Section, Article, Header, Footer, Main, Nav,
        // Headings
        H1, H2, H3, H4,
        // Text / inline
        P, Strong, Em, Small, Code, Pre, Hr, Br,
        // Interactive
        Button, Input, Textarea, Select, Option,
        // Form
        Form, Label,
        // Lists
        Ul, Ol, Li,
        // Media / links
        A, Img,
        // Table
        Table, Thead, Tbody, Tr, Th, Td;

// App entry point
export 'src/app.dart' show runApp;

// Utilities
export 'src/utils/stylesheet.dart' show injectStyleSheet;
