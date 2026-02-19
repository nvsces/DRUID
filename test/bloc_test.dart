import 'dart:async';
import 'package:test/test.dart';
// Direct imports — avoids package:web (browser-only).
import 'package:druid/src/bloc/bloc.dart';
import 'package:druid/src/core/signal.dart';

// ── Fixtures ────────────────────────────────────────────────────────────────

sealed class CounterEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

class Reset extends CounterEvent {
  final int to;
  Reset(this.to);
}

class CounterState {
  final int count;
  const CounterState(this.count);
  // No == override intentionally — tests cover identity-based signal guard.
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(0)) {
    on<Increment>((e, emit) => emit(CounterState(state.count + 1)));
    on<Decrement>((e, emit) => emit(CounterState(state.count - 1)));
    on<Reset>((e, emit) => emit(CounterState(e.to)));
  }
}

class _IncrementOnlyBloc extends Bloc<CounterEvent, CounterState> {
  _IncrementOnlyBloc() : super(const CounterState(0)) {
    on<Increment>((e, emit) => emit(CounterState(state.count + 1)));
    // No handler for Decrement or Reset.
  }
}

class _OverwriteBloc extends Bloc<CounterEvent, CounterState> {
  _OverwriteBloc() : super(const CounterState(0)) {
    on<Increment>((e, emit) => emit(CounterState(state.count + 1)));
    on<Increment>((e, emit) => emit(CounterState(state.count + 10))); // overwrites
  }
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('Bloc — state management', () {
    test('initial state is correct', () {
      final bloc = CounterBloc();
      expect(bloc.state.count, equals(0));
    });

    test('add(Increment) increases count by 1', () {
      final bloc = CounterBloc();
      bloc.add(Increment());
      expect(bloc.state.count, equals(1));
    });

    test('add(Decrement) decreases count by 1', () {
      final bloc = CounterBloc();
      bloc.add(Decrement());
      expect(bloc.state.count, equals(-1));
    });

    test('add(Reset) sets count to given value', () {
      final bloc = CounterBloc();
      bloc.add(Increment());
      bloc.add(Increment());
      bloc.add(Reset(42));
      expect(bloc.state.count, equals(42));
    });

    test('multiple events accumulate correctly', () {
      final bloc = CounterBloc();
      bloc.add(Increment());
      bloc.add(Increment());
      bloc.add(Increment());
      bloc.add(Decrement());
      expect(bloc.state.count, equals(2));
    });

    test('unregistered event type is a no-op', () {
      final bloc = _IncrementOnlyBloc();
      expect(() => bloc.add(Decrement()), returnsNormally);
      expect(bloc.state.count, equals(0));
    });

    test('on<E> handler overwrites previous handler for same type', () {
      final bloc = _OverwriteBloc();
      bloc.add(Increment());
      expect(bloc.state.count, equals(10));
    });

    test('close() is callable without error', () {
      final bloc = CounterBloc();
      expect(() => bloc.close(), returnsNormally);
    });
  });

  group('Bloc — stateSignal integration', () {
    test('stateSignal.value reflects current state', () {
      final bloc = CounterBloc();
      expect(bloc.stateSignal.value.count, equals(0));
      bloc.add(Increment());
      expect(bloc.stateSignal.value.count, equals(1));
    });

    test('stateSignal and state getter stay in sync', () {
      final bloc = CounterBloc();
      bloc.add(Increment());
      expect(bloc.state.count, equals(bloc.stateSignal.value.count));
    });

    test('stateSignal triggers Effect when state changes', () async {
      final bloc = CounterBloc();
      var callCount = 0;
      int? lastCount;

      final e = effect(() {
        lastCount = bloc.stateSignal.value.count;
        callCount++;
      });

      // Effect runs synchronously on creation.
      expect(callCount, equals(1));
      expect(lastCount, equals(0));

      bloc.add(Increment());

      // Effect re-runs asynchronously (microtask).
      await Future.microtask(() {});

      expect(callCount, equals(2));
      expect(lastCount, equals(1));

      e.dispose();
    });

    test('Effect does not re-run after dispose', () async {
      final bloc = CounterBloc();
      var callCount = 0;

      final e = effect(() {
        // ignore: unnecessary_statements — captures dependency
        bloc.stateSignal.value;
        callCount++;
      });

      expect(callCount, equals(1));
      e.dispose();

      bloc.add(Increment());
      await Future.microtask(() {});

      expect(callCount, equals(1)); // no extra call after dispose
    });

    test('multiple Effects each receive state updates', () async {
      final bloc = CounterBloc();
      int? seen1;
      int? seen2;

      final e1 = effect(() => seen1 = bloc.stateSignal.value.count);
      final e2 = effect(() => seen2 = bloc.stateSignal.value.count);

      bloc.add(Increment());
      await Future.microtask(() {});

      expect(seen1, equals(1));
      expect(seen2, equals(1));

      e1.dispose();
      e2.dispose();
    });
  });
}
