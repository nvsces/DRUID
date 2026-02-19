/// BlocProvider and BlocBuilder widgets for druid.
library druid.bloc.provider;

import '../widgets/widget.dart';
import '../widgets/context.dart';
import 'bloc.dart';

// ---------------------------------------------------------------------------
// Global registry
// ---------------------------------------------------------------------------

/// Internal type-keyed registry populated by [BlocProvider] during build.
///
/// Key is the concrete Bloc subtype (e.g. `CounterBloc`).
/// Limitation: two [BlocProvider]s of the same type in one tree will collide —
/// the later one wins. In practice, use one provider per Bloc type at the root.
final Map<Type, Bloc> _registry = {};

// ---------------------------------------------------------------------------
// BlocProvider<B>
// ---------------------------------------------------------------------------

/// Provides a [Bloc] of type [B] to the widget subtree.
///
/// The Bloc is created once via [create] and accessible to descendants
/// via [BlocProvider.of<B>(context)].
///
/// ```dart
/// runApp(
///   BlocProvider(
///     create: () => CounterBloc(),
///     child: CounterView(),
///   ),
/// );
/// ```
class BlocProvider<B extends Bloc> extends StatefulWidget {
  const BlocProvider({
    required this.create,
    required this.child,
    super.key,
  });

  /// Factory that creates the [Bloc] instance. Called once during [initState].
  final B Function() create;

  /// The subtree that has access to the provided [Bloc].
  final Widget child;

  /// Retrieve the nearest [B] from the registry.
  ///
  /// Throws [StateError] if no [BlocProvider<B>] ancestor is present.
  static B of<B extends Bloc>(BuildContext context) {
    final bloc = _registry[B];
    if (bloc == null) {
      throw StateError(
        'BlocProvider.of<$B>() called but no BlocProvider<$B> was found.\n'
        'Ensure BlocProvider<$B> is an ancestor of this widget.',
      );
    }
    return bloc as B;
  }

  @override
  State<BlocProvider<B>> createState() => _BlocProviderState<B>();
}

class _BlocProviderState<B extends Bloc> extends State<BlocProvider<B>> {
  late final B _bloc;

  @override
  void initState() {
    _bloc = widget.create();
    _registry[B] = _bloc;
  }

  @override
  Widget build(BuildContext context) {
    // Re-register on every build to handle hot-reload and tree changes.
    _registry[B] = _bloc;
    return widget.child;
  }

  @override
  void dispose() {
    _bloc.close();
    _registry.remove(B);
  }
}

// ---------------------------------------------------------------------------
// BlocBuilder<B, S>
// ---------------------------------------------------------------------------

/// Rebuilds whenever the [bloc]'s state changes.
///
/// Internally reads [bloc.stateSignal.value] during [build], which causes
/// the global render [Effect] to auto-track the signal. When [bloc.add]
/// emits a new state the render loop re-runs and [builder] is called with
/// the updated state.
///
/// ```dart
/// BlocBuilder<CounterBloc, CounterState>(
///   bloc: bloc,
///   builder: (context, state) => H1(child: Text('Count: ${state.count}')),
/// )
/// ```
class BlocBuilder<B extends Bloc<dynamic, S>, S> extends StatelessWidget {
  const BlocBuilder({
    required this.bloc,
    required this.builder,
    super.key,
  });

  final B bloc;
  final Widget Function(BuildContext context, S state) builder;

  @override
  Widget build(BuildContext context) {
    // Reading stateSignal.value here auto-registers this node as a downstream
    // of the signal via the global _trackingStack in signal.dart.
    final state = bloc.stateSignal.value;
    return builder(context, state);
  }
}
