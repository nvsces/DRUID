/// AnimatedBuilder — rebuilds its subtree on every animation frame.
library druid.animation.animated_builder;

import '../widgets/widget.dart';
import '../widgets/context.dart';
import 'animation_controller.dart';

// ---------------------------------------------------------------------------
// AnimatedBuilder
// ---------------------------------------------------------------------------

/// A [StatelessWidget] that rebuilds whenever [animation] ticks.
///
/// Because [build] reads `animation.signal.value`, the reactive Effect in
/// [app.dart] tracks that [Signal] and triggers a re-render on every RAF tick.
///
/// ```dart
/// AnimatedBuilder(
///   animation: _ctrl,
///   builder: (ctx) => Div(
///     style: {'transform': 'translateY(${_y.value.toStringAsFixed(1)}px)'},
///   ),
/// )
/// ```
class AnimatedBuilder extends StatelessWidget {
  const AnimatedBuilder({
    required this.animation,
    required this.builder,
    this.child,
    super.key,
  });

  final AnimationController animation;
  final Widget Function(BuildContext context) builder;

  /// Optional pre-built subtree that doesn't depend on the animation value.
  /// Passed as context to [builder] for convenience (not used by the framework
  /// automatically — the [builder] may choose to incorporate it).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // Reading the signal value here registers this widget's render Effect as a
    // downstream of the AnimationController's Signal<double>. On each RAF tick
    // the signal changes → Effect re-runs → builder is called again.
    // ignore: unused_local_variable
    final _ = animation.signal.value;
    return builder(context);
  }
}
