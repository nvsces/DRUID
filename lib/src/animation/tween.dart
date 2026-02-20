/// Tween — interpolates between two values driven by an animation.
library druid.animation.tween;

import 'animation.dart';
import 'curves.dart';

// ---------------------------------------------------------------------------
// Tween<T>
// ---------------------------------------------------------------------------

/// Interpolates between [begin] and [end].
///
/// ```dart
/// final tween = Tween(0.0, 100.0);
/// final anim  = tween.animate(_ctrl);
/// final anim2 = tween.animate(CurvedAnimation(_ctrl, Curves.easeInOut));
/// ```
class Tween<T> {
  const Tween(this.begin, this.end);

  final T begin;
  final T end;

  /// Linear interpolation at progress [t] ∈ [0, 1].
  T lerp(double t) {
    if (T == double) {
      final b = begin as double;
      final e = end as double;
      return (b + (e - b) * t) as T;
    }
    if (T == int) {
      final b = (begin as int).toDouble();
      final e = (end as int).toDouble();
      return (b + (e - b) * t).round() as T;
    }
    // Fallback: snap at t == 1.
    return t < 1.0 ? begin : end;
  }

  /// Creates a [TweenAnimation<T>] driven by [parent].
  ///
  /// [parent] can be an [AnimationController] or a [CurvedAnimation].
  TweenAnimation<T> animate(HasAnimationValue parent) =>
      TweenAnimation<T>._(parent, this);
}

// ---------------------------------------------------------------------------
// TweenAnimation<T>
// ---------------------------------------------------------------------------

/// Returned by [Tween.animate]. Reads the interpolated value reactively.
///
/// Reading [value] inside an [Effect] or [AnimatedBuilder] registers a
/// dependency on the underlying signal so UI rebuilds automatically.
class TweenAnimation<T> {
  TweenAnimation._(this._source, this._tween);

  final HasAnimationValue _source;
  final Tween<T> _tween;

  /// The current interpolated value.
  T get value => _tween.lerp(_source.value.clamp(0.0, 1.0));
}

// ---------------------------------------------------------------------------
// Convenience specialised tweens
// ---------------------------------------------------------------------------

/// Tween for [int] values.
class IntTween extends Tween<int> {
  const IntTween(super.begin, super.end);
}

/// Tween for [double] values.
class DoubleTween extends Tween<double> {
  const DoubleTween(super.begin, super.end);
}
