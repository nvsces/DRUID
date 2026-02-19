/// Bloc — event-driven state management for druid.
///
/// Inspired by flutter_bloc. State is held in a [Signal] so that
/// [BlocBuilder] widgets auto-track changes via the render Effect.
library druid.bloc;

// No package:web import — fully VM-compatible.
import '../core/signal.dart';

/// Signature for event handlers registered via [Bloc.on].
///
/// [event] is the concrete event instance.
/// [emit] replaces the current Bloc state.
typedef EventHandler<E, S> = void Function(E event, void Function(S) emit);

/// Base class for all Blocs.
///
/// [E] — base event type (typically a sealed class).
/// [S] — state type.
///
/// ```dart
/// sealed class CounterEvent {}
/// class Increment extends CounterEvent {}
/// class Decrement extends CounterEvent {}
///
/// class CounterState {
///   final int count;
///   const CounterState(this.count);
/// }
///
/// class CounterBloc extends Bloc<CounterEvent, CounterState> {
///   CounterBloc() : super(const CounterState(0)) {
///     on<Increment>((e, emit) => emit(CounterState(state.count + 1)));
///     on<Decrement>((e, emit) => emit(CounterState(state.count - 1)));
///   }
/// }
/// ```
abstract class Bloc<E, S> {
  Bloc(S initialState) : _stateSignal = signal<S>(initialState);

  final Signal<S> _stateSignal;
  final Map<Type, Function> _handlers = {};

  /// The current state.
  S get state => _stateSignal.value;

  /// The state exposed as a [Signal] — read by [BlocBuilder] for auto-tracking.
  Signal<S> get stateSignal => _stateSignal;

  /// Register a handler for events of exact type [Ev].
  ///
  /// Registering twice for the same [Ev] overwrites the previous handler.
  void on<Ev extends E>(EventHandler<Ev, S> handler) {
    // Wrap in a closure typed as Function(E, void Function(S)) so that
    // Bloc.add can call it without a covariant cast failure at runtime.
    _handlers[Ev] = (E event, void Function(S) emit) => handler(event as Ev, emit);
  }

  /// Dispatch [event] to the registered handler.
  ///
  /// If no handler is registered for [event.runtimeType], this is a no-op.
  void add(E event) {
    final handler = _handlers[event.runtimeType];
    if (handler == null) return;
    (handler as void Function(E, void Function(S)))(event, _emit);
  }

  void _emit(S newState) {
    // Signal.value setter already guards against same-value updates via ==.
    // If S does not override ==, every new instance triggers a re-render.
    _stateSignal.value = newState;
  }

  /// Called when this Bloc is permanently removed from the tree.
  ///
  /// Override to cancel timers, close subscriptions, etc.
  void close() {}
}
