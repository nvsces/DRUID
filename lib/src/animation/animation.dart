/// Shared animation interface.
library druid.animation.animation;

/// Interface for anything that exposes a raw `double value` in [0, 1].
/// Implemented by [AnimationController] and [CurvedAnimation].
abstract class HasAnimationValue {
  double get value;
}
