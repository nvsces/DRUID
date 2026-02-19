// Core reactivity primitives: Signal, Computed, Effect.
//
// Dependency graph — two directions:
//   _EffectNode._upstreams   : sources (Signal/Computed) this node reads from
//   _Source._downstreams     : subscribers (_EffectNode) to notify on change
//
// Tracking:
//   _trackingStack holds the currently-executing Effect or Computed.
//   Reading .value while tracked automatically registers the link.

library druid.core.signal;

import 'dart:async' show scheduleMicrotask;

// ---------------------------------------------------------------------------
// Scheduler
// ---------------------------------------------------------------------------

final _trackingStack = <_EffectNode>[];

bool _flushScheduled = false;
final _pendingEffects = <Effect>{};

void _scheduleFlush() {
  if (_flushScheduled) return;
  _flushScheduled = true;
  scheduleMicrotask(_flush);
}

void _flush() {
  _flushScheduled = false;
  final batch = List<Effect>.from(_pendingEffects);
  _pendingEffects.clear();
  for (final e in batch) {
    e._execute();
  }
}

// ---------------------------------------------------------------------------
// _Source — anything that can be depended on (Signal, Computed)
// ---------------------------------------------------------------------------

abstract class _Source {
  final Set<_EffectNode> _downstreams = {};
  void _addDownstream(_EffectNode n) => _downstreams.add(n);
  void _removeDownstream(_EffectNode n) => _downstreams.remove(n);
}

// ---------------------------------------------------------------------------
// _EffectNode — anything that tracks dependencies (Effect, Computed)
// ---------------------------------------------------------------------------

abstract class _EffectNode {
  final Set<_Source> _upstreams = {};

  void _run(); // called when an upstream changes

  void _clearUpstreams() {
    for (final src in _upstreams) {
      src._removeDownstream(this);
    }
    _upstreams.clear();
  }

  void _track(_Source src) {
    if (_upstreams.add(src)) {
      src._addDownstream(this);
    }
  }
}

// ---------------------------------------------------------------------------
// Signal<T>
// ---------------------------------------------------------------------------

class Signal<T> extends _Source {
  Signal(T initial) : _value = initial;

  T _value;

  T get value {
    if (_trackingStack.isNotEmpty) {
      _trackingStack.last._track(this);
    }
    return _value;
  }

  set value(T v) {
    if (_value == v) return;
    _value = v;
    for (final node in List<_EffectNode>.from(_downstreams)) {
      node._run();
    }
  }

  @override
  String toString() => 'Signal($_value)';
}

// ---------------------------------------------------------------------------
// Computed<T>  — subscriber AND source
// ---------------------------------------------------------------------------

class Computed<T> extends _Source implements _EffectNode {
  Computed._(this._fn) {
    _recompute();
  }

  final T Function() _fn;
  late T _cachedValue;
  bool _dirty = false;

  // _EffectNode
  @override
  final Set<_Source> _upstreams = {};

  @override
  void _clearUpstreams() {
    for (final src in _upstreams) {
      src._removeDownstream(this);
    }
    _upstreams.clear();
  }

  @override
  void _track(_Source src) {
    if (_upstreams.add(src)) {
      src._addDownstream(this);
    }
  }

  T get value {
    if (_trackingStack.isNotEmpty) {
      _trackingStack.last._track(this);
    }
    if (_dirty) _recompute();
    return _cachedValue;
  }

  @override
  void _run() {
    if (_dirty) return; // already dirty, downstreams already notified
    _dirty = true;
    for (final node in List<_EffectNode>.from(_downstreams)) {
      node._run();
    }
  }

  void _recompute() {
    _clearUpstreams();
    _trackingStack.add(this);
    try {
      _cachedValue = _fn();
    } finally {
      _trackingStack.removeLast();
    }
    _dirty = false;
  }
}

// ---------------------------------------------------------------------------
// Effect
// ---------------------------------------------------------------------------

class Effect extends _EffectNode {
  Effect._(this._fn) {
    _execute(); // synchronous first run to capture dependencies
  }

  final void Function() _fn;
  bool _disposed = false;

  @override
  void _run() {
    // Called by an upstream — schedule async re-execution.
    if (_disposed) return;
    _pendingEffects.add(this);
    _scheduleFlush();
  }

  void _execute() {
    if (_disposed) return;
    _clearUpstreams();
    _trackingStack.add(this);
    try {
      _fn();
    } finally {
      _trackingStack.removeLast();
    }
  }

  void dispose() {
    _disposed = true;
    _clearUpstreams();
    _pendingEffects.remove(this);
  }
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

Signal<T> signal<T>(T initial) => Signal<T>(initial);

Computed<T> computed<T>(T Function() fn) => Computed<T>._(fn);

Effect effect(void Function() fn) => Effect._(fn);
