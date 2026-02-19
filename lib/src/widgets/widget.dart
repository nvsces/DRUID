/// Core widget abstractions: Widget, StatelessWidget, StatefulWidget, State.
library druid.widgets.widget;

import 'context.dart';
import '../vdom/vnode.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

/// Base class for all UI nodes in the druid widget tree.
///
/// Widgets are immutable descriptions of the UI.  druid uses them to build a
/// [VNode] virtual tree which is then diffed and applied to the real DOM.
abstract class Widget {
  const Widget({this.key});

  /// Optional stable key used for list reconciliation.
  final String? key;

  /// Called by the framework to obtain the [VNode] representation of this
  /// widget.  Stateful and composite widgets override this via their [State]
  /// or [build] method; leaf HTML widgets return themselves directly.
  VNode toVNode(BuildContext context);
}

// ---------------------------------------------------------------------------
// StatelessWidget
// ---------------------------------------------------------------------------

/// A widget with no mutable state.
///
/// Override [build] to describe the UI as a function of the widget's
/// `const` fields.
///
/// ```dart
/// class Greeting extends StatelessWidget {
///   const Greeting({required this.name});
///   final String name;
///
///   @override
///   Widget build(BuildContext context) => H1(child: Text('Hello, $name!'));
/// }
/// ```
abstract class StatelessWidget extends Widget {
  const StatelessWidget({super.key});

  /// Describes the subtree for this widget.
  Widget build(BuildContext context);

  @override
  VNode toVNode(BuildContext context) => build(context).toVNode(context);
}

// ---------------------------------------------------------------------------
// StatefulWidget
// ---------------------------------------------------------------------------

/// A widget that creates a [State] object holding mutable state.
///
/// ```dart
/// class Counter extends StatefulWidget {
///   @override
///   State<Counter> createState() => _CounterState();
/// }
/// ```
abstract class StatefulWidget extends Widget {
  const StatefulWidget({super.key});

  /// Create the mutable state for this widget.
  State<StatefulWidget> createState();

  @override
  VNode toVNode(BuildContext context) {
    // The framework (app.dart) manages the State lifecycle; this path is only
    // taken during an initial synchronous render before the StateNode is set up.
    final state = createState()
      .._widget = this
      .._context = context;
    state.initState();
    return state.build(context).toVNode(context);
  }
}

// ---------------------------------------------------------------------------
// State<W>
// ---------------------------------------------------------------------------

/// Mutable state for a [StatefulWidget].
///
/// Override [initState] for one-time setup (create signals here), [build] to
/// describe the UI, and [dispose] for cleanup.
///
/// ```dart
/// class _CounterState extends State<Counter> {
///   late final count = signal(0);
///
///   @override
///   void initState() {}   // optional
///
///   @override
///   Widget build(BuildContext context) {
///     return Div(children: [
///       Text('Count: ${count.value}'),
///     ]);
///   }
/// }
/// ```
abstract class State<W extends StatefulWidget> {
  late W _widget;
  late BuildContext _context;

  /// The widget that created this State.
  W get widget => _widget;

  /// The context in the widget tree.
  BuildContext get context => _context;

  /// Called by the framework to initialise widget and context references.
  // ignore: library_private_types_in_public_api
  void mountWith(StatefulWidget widget, BuildContext context) {
    _widget = widget as W;
    _context = context;
  }

  /// Called by the framework to update the widget reference on rebuild.
  void updateWidget(StatefulWidget widget) {
    _widget = widget as W;
  }

  /// Called once when the [State] is first created.
  ///
  /// Initialise signals and subscriptions here.
  void initState() {}

  /// Describe the UI for the current state.
  Widget build(BuildContext context);

  /// Called when this State is permanently removed from the tree.
  void dispose() {}
}
