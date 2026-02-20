/// Easing curves for animations.
library druid.animation.curves;

import 'dart:math' as math;
import 'animation.dart';

// ---------------------------------------------------------------------------
// Curve
// ---------------------------------------------------------------------------

abstract class Curve {
  const Curve();

  /// Maps [t] in [0, 1] to an eased value in [0, 1].
  double transform(double t);
}

// ---------------------------------------------------------------------------
// Built-in curve implementations
// ---------------------------------------------------------------------------

class _Linear extends Curve {
  const _Linear();

  @override
  double transform(double t) => t;
}

/// Cubic Bézier approximation using Newton–Raphson solver.
class _Cubic extends Curve {
  const _Cubic(this.x1, this.y1, this.x2, this.y2);

  final double x1, y1, x2, y2;

  double _sampleX(double t) =>
      ((1 - 3 * x2 + 3 * x1) * t + (3 * x2 - 6 * x1)) * t * t + 3 * x1 * t;

  double _sampleY(double t) =>
      ((1 - 3 * y2 + 3 * y1) * t + (3 * y2 - 6 * y1)) * t * t + 3 * y1 * t;

  double _sampleDerivativeX(double t) =>
      (3 * (1 - 3 * x2 + 3 * x1) * t + 2 * (3 * x2 - 6 * x1)) * t + 3 * x1;

  double _tForX(double x) {
    var t = x;
    for (var i = 0; i < 8; i++) {
      final slope = _sampleDerivativeX(t);
      if (slope == 0) break;
      t -= (_sampleX(t) - x) / slope;
    }
    return t;
  }

  @override
  double transform(double t) {
    if (t == 0.0 || t == 1.0) return t;
    return _sampleY(_tForX(t)).clamp(0.0, 1.0);
  }
}

class _BounceOut extends Curve {
  const _BounceOut();

  @override
  double transform(double t) {
    if (t < 1 / 2.75) {
      return 7.5625 * t * t;
    } else if (t < 2 / 2.75) {
      final t2 = t - 1.5 / 2.75;
      return 7.5625 * t2 * t2 + 0.75;
    } else if (t < 2.5 / 2.75) {
      final t2 = t - 2.25 / 2.75;
      return 7.5625 * t2 * t2 + 0.9375;
    } else {
      final t2 = t - 2.625 / 2.75;
      return 7.5625 * t2 * t2 + 0.984375;
    }
  }
}

class _BounceIn extends Curve {
  const _BounceIn();

  @override
  double transform(double t) => 1.0 - const _BounceOut().transform(1.0 - t);
}

class _ElasticOut extends Curve {
  const _ElasticOut();

  @override
  double transform(double t) {
    if (t == 0.0 || t == 1.0) return t;
    const p = 0.3;
    return math.pow(2.0, -10.0 * t).toDouble() *
            math.sin((t - p / 4) * (2 * math.pi / p)) +
        1.0;
  }
}

// ---------------------------------------------------------------------------
// CurvedAnimation
// ---------------------------------------------------------------------------

/// Wraps a [HasAnimationValue] (typically [AnimationController]) and applies a [Curve].
///
/// ```dart
/// final curved = CurvedAnimation(_ctrl, Curves.easeInOut);
/// final y = Tween(-14.0, 0.0).animate(curved);
/// ```
class CurvedAnimation implements HasAnimationValue {
  CurvedAnimation(this.parent, this.curve);

  final HasAnimationValue parent;
  final Curve curve;

  @override
  double get value => curve.transform(parent.value.clamp(0.0, 1.0));
}

// ---------------------------------------------------------------------------
// Curves namespace
// ---------------------------------------------------------------------------

class Curves {
  Curves._();

  static const Curve linear = _Linear();
  static const Curve easeIn = _Cubic(0.42, 0, 1, 1);
  static const Curve easeOut = _Cubic(0, 0, 0.58, 1);
  static const Curve easeInOut = _Cubic(0.42, 0, 0.58, 1);
  static const Curve bounceOut = _BounceOut();
  static const Curve bounceIn = _BounceIn();
  static const Curve elasticOut = _ElasticOut();

  /// Create a custom cubic bézier curve.
  /// Equivalent to CSS `cubic-bezier(x1, y1, x2, y2)`.
  static Curve cubic(double x1, double y1, double x2, double y2) =>
      _Cubic(x1, y1, x2, y2);
}
