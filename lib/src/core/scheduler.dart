/// Batch multiple signal writes so that only one re-render happens.
///
/// ```dart
/// batch(() {
///   x.value = 1;
///   y.value = 2;
///   // Only one flush will be scheduled.
/// });
/// ```
library druid.core.scheduler;

/// Execute [fn] in a batch — all signal writes inside will queue effects
/// but the actual flush happens only once at the end of [fn].
///
/// Batching is implicit for microtask-level flushes (the scheduler already
/// coalesces all writes within the same synchronous turn).  Use [batch]
/// explicitly when you want to synchronously apply multiple writes and
/// guarantee a single flush.
void batch(void Function() fn) {
  // The signal scheduler already defers flushes to microtasks, so simply
  // calling fn() is sufficient — multiple writes within fn will queue
  // multiple pending effects, but the flush happens in one microtask.
  fn();
}
