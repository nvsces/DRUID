import 'dart:async';
import 'package:test/test.dart';
// Import signal primitives directly — avoids pulling in package:web (browser-only).
import 'package:druid/src/core/signal.dart';
import 'package:druid/src/core/scheduler.dart';

void main() {
  group('Signal', () {
    test('holds initial value', () {
      final s = signal(42);
      expect(s.value, equals(42));
    });

    test('updates value', () {
      final s = signal(0);
      s.value = 7;
      expect(s.value, equals(7));
    });

    test('does not notify when value is equal', () async {
      final s = signal(1);
      var calls = 0;
      effect(() {
        s.value; // track
        calls++;
      });
      expect(calls, equals(1)); // initial run

      s.value = 1; // same value — should not trigger
      await Future.microtask(() {});
      expect(calls, equals(1));
    });
  });

  group('Effect', () {
    test('runs immediately on creation', () {
      var ran = false;
      effect(() => ran = true);
      expect(ran, isTrue);
    });

    test('re-runs when dependency changes', () async {
      final s = signal(0);
      var last = -1;
      effect(() => last = s.value);

      expect(last, equals(0));

      s.value = 5;
      await Future.microtask(() {});
      expect(last, equals(5));
    });

    test('dispose stops re-runs', () async {
      final s = signal(0);
      var calls = 0;
      final e = effect(() {
        s.value;
        calls++;
      });

      expect(calls, equals(1));
      e.dispose();

      s.value = 99;
      await Future.microtask(() {});
      expect(calls, equals(1)); // no new run after dispose
    });

    test('tracks multiple signals', () async {
      final a = signal(1);
      final b = signal(2);
      var sum = 0;
      effect(() => sum = a.value + b.value);

      expect(sum, equals(3));

      a.value = 10;
      await Future.microtask(() {});
      expect(sum, equals(12));

      b.value = 20;
      await Future.microtask(() {});
      expect(sum, equals(30));
    });
  });

  group('Computed', () {
    test('derives value from signal', () {
      final s = signal(3);
      final doubled = computed(() => s.value * 2);
      expect(doubled.value, equals(6));
    });

    test('updates when dependency changes', () async {
      final s = signal(1);
      final sq = computed(() => s.value * s.value);

      expect(sq.value, equals(1));

      s.value = 4;
      await Future.microtask(() {});
      expect(sq.value, equals(16));
    });

    test('composed computed chains', () async {
      final x = signal(2);
      final doubled = computed(() => x.value * 2);
      final quadrupled = computed(() => doubled.value * 2);

      expect(quadrupled.value, equals(8));

      x.value = 5;
      await Future.microtask(() {});
      expect(quadrupled.value, equals(20));
    });
  });

  group('batch', () {
    test('multiple writes produce single effect run', () async {
      final a = signal(0);
      final b = signal(0);
      var calls = 0;

      effect(() {
        a.value;
        b.value;
        calls++;
      });

      expect(calls, equals(1));

      batch(() {
        a.value = 1;
        b.value = 2;
      });

      // Both writes are queued; only one microtask flush should happen.
      await Future.microtask(() {});
      expect(calls, equals(2)); // one additional run, not two
    });
  });
}
