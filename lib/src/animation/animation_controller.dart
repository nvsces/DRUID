/// AnimationController — drives animations via a Signal<double>.
library druid.animation.animation_controller;

import '../core/signal.dart';
import 'animation.dart';
import 'ticker.dart';

// ---------------------------------------------------------------------------
// AnimationStatus
// ---------------------------------------------------------------------------

enum AnimationStatus { dismissed, forward, reverse, completed }

// ---------------------------------------------------------------------------
// AnimationController
// ---------------------------------------------------------------------------

/// Controls an animation, exposing its progress as a [Signal<double>] in [0, 1].
///
/// ```dart
/// final ctrl = AnimationController(
///   vsync: this,
///   duration: const Duration(milliseconds: 500),
/// );
/// ctrl.forward();
/// ```
///
/// The [signal] is the single source of truth. Anything that reads
/// `ctrl.signal.value` inside a reactive context (Effect, AnimatedBuilder)
/// will automatically re-run on every animation frame.
class AnimationController implements HasAnimationValue {
  AnimationController({
    required TickerProvider vsync,
    required Duration duration,
    double initialValue = 0.0,
  }) : _duration = duration,
       _signal = Signal<double>(initialValue.clamp(0.0, 1.0)) {
    _ticker = vsync.createTicker(_onTick);
  }

  final Duration _duration;
  final Signal<double> _signal;
  late final Ticker _ticker;

  AnimationStatus _status = AnimationStatus.dismissed;
  bool _reversing = false;
  bool _repeating = false;
  bool _repeatReverse = false;
  Duration? _prevElapsed;

  /// The underlying reactive signal — read inside Effects/AnimatedBuilder.
  Signal<double> get signal => _signal;

  /// Current animation value in [0, 1].
  @override
  double get value => _signal.value;

  AnimationStatus get status => _status;

  bool get isAnimating => _ticker.isActive;

  // ---------------------------------------------------------------------------
  // Control methods
  // ---------------------------------------------------------------------------

  /// Animate from [from] (or current value) to 1.0.
  void forward({double? from}) {
    _reversing = false;
    _repeating = false;
    _prevElapsed = null;
    if (from != null) _signal.value = from.clamp(0.0, 1.0);
    _status = AnimationStatus.forward;
    _ticker.start();
  }

  /// Animate from [from] (or current value) to 0.0.
  void reverse({double? from}) {
    _reversing = true;
    _repeating = false;
    _prevElapsed = null;
    if (from != null) _signal.value = from.clamp(0.0, 1.0);
    _status = AnimationStatus.reverse;
    _ticker.start();
  }

  /// Repeat indefinitely. If [reverse] is true, ping-pongs between 0 and 1.
  void repeat({bool reverse = false}) {
    _repeating = true;
    _repeatReverse = reverse;
    _reversing = false;
    _prevElapsed = null;
    _status = AnimationStatus.forward;
    _ticker.start();
  }

  /// Stop the animation at the current value.
  void stop() {
    _ticker.stop();
    _repeating = false;
    _prevElapsed = null;
  }

  /// Dispose the controller and its ticker.
  void dispose() {
    _ticker.dispose();
  }

  // ---------------------------------------------------------------------------
  // Internal tick handler
  // ---------------------------------------------------------------------------

  void _onTick(Duration elapsed) {
    final dt = _prevElapsed == null
        ? Duration.zero
        : elapsed - _prevElapsed!;
    _prevElapsed = elapsed;

    final durationMs = _duration.inMicroseconds / 1000.0;
    if (durationMs <= 0) return;

    final step = dt.inMicroseconds / 1000.0 / durationMs;

    if (_repeating) {
      _advanceRepeating(step);
    } else if (_reversing) {
      _advanceReverse(step);
    } else {
      _advanceForward(step);
    }
  }

  void _advanceForward(double step) {
    final next = (_signal.value + step).clamp(0.0, 1.0);
    _signal.value = next;
    if (next >= 1.0) {
      _ticker.stop();
      _prevElapsed = null;
      _status = AnimationStatus.completed;
    }
  }

  void _advanceReverse(double step) {
    final next = (_signal.value - step).clamp(0.0, 1.0);
    _signal.value = next;
    if (next <= 0.0) {
      _ticker.stop();
      _prevElapsed = null;
      _status = AnimationStatus.dismissed;
    }
  }

  void _advanceRepeating(double step) {
    if (!_repeatReverse) {
      // Simple loop: always forward, wrap at 1.
      var next = _signal.value + step;
      if (next >= 1.0) next -= 1.0;
      _signal.value = next;
    } else {
      // Ping-pong.
      if (!_reversing) {
        final next = _signal.value + step;
        if (next >= 1.0) {
          _signal.value = 1.0;
          _reversing = true;
        } else {
          _signal.value = next;
        }
      } else {
        final next = _signal.value - step;
        if (next <= 0.0) {
          _signal.value = 0.0;
          _reversing = false;
        } else {
          _signal.value = next;
        }
      }
    }
  }
}
