/// Ticker — wraps requestAnimationFrame for the animation system.
library druid.animation.ticker;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

import '../widgets/widget.dart';

// ---------------------------------------------------------------------------
// TickCallback
// ---------------------------------------------------------------------------

typedef TickCallback = void Function(Duration elapsed);

// ---------------------------------------------------------------------------
// Ticker
// ---------------------------------------------------------------------------

/// Drives animations by calling [onTick] on every animation frame.
///
/// Create via [SingleTickerProviderMixin.createTicker]; do not instantiate
/// directly unless you manage its lifecycle manually.
class Ticker {
  Ticker(this._onTick);

  final TickCallback _onTick;
  bool _active = false;
  double? _startTime;

  /// Start ticking. No-op if already active.
  void start() {
    if (_active) return;
    _active = true;
    _startTime = null;
    _scheduleFrame();
  }

  /// Stop ticking. No-op if already stopped.
  void stop() {
    _active = false;
  }

  /// Stop ticking and release resources.
  void dispose() {
    stop();
  }

  bool get isActive => _active;

  void _scheduleFrame() {
    web.window.requestAnimationFrame(((double ts) {
      if (!_active) return;
      _startTime ??= ts;
      _onTick(Duration(milliseconds: (ts - _startTime!).round()));
      _scheduleFrame();
    }).toJS);
  }
}

// ---------------------------------------------------------------------------
// TickerProvider
// ---------------------------------------------------------------------------

/// Interface for objects that can vend [Ticker]s.
abstract class TickerProvider {
  Ticker createTicker(TickCallback onTick);
}

// ---------------------------------------------------------------------------
// SingleTickerProviderMixin
// ---------------------------------------------------------------------------

/// Mixin on [State] that provides a single [Ticker].
///
/// ```dart
/// class _MyState extends State<MyWidget> with SingleTickerProviderMixin {
///   late final AnimationController _ctrl;
///
///   @override
///   void initState() {
///     _ctrl = AnimationController(vsync: this, duration: Duration(seconds: 1));
///   }
/// }
/// ```
mixin SingleTickerProviderMixin<W extends StatefulWidget>
    on State<W>
    implements TickerProvider {
  Ticker? _ticker;

  @override
  Ticker createTicker(TickCallback onTick) {
    assert(_ticker == null, 'SingleTickerProviderMixin: ticker already created');
    _ticker = Ticker(onTick);
    return _ticker!;
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _ticker = null;
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// MultiTickerProvider
// ---------------------------------------------------------------------------

/// A standalone [TickerProvider] that can create multiple [Ticker]s.
///
/// Use when a [State] needs more than one [AnimationController].
/// Call [disposeAll] in [State.dispose] to clean up.
///
/// ```dart
/// class _MyState extends State<MyWidget> {
///   late final _tp = MultiTickerProvider();
///   late final _ctrl1 = AnimationController(vsync: _tp, duration: Duration(seconds: 1));
///   late final _ctrl2 = AnimationController(vsync: _tp, duration: Duration(milliseconds: 500));
///
///   @override
///   void dispose() {
///     _tp.disposeAll();
///     super.dispose();
///   }
/// }
/// ```
class MultiTickerProvider implements TickerProvider {
  final List<Ticker> _tickers = [];

  @override
  Ticker createTicker(TickCallback onTick) {
    final ticker = Ticker(onTick);
    _tickers.add(ticker);
    return ticker;
  }

  /// Dispose all created tickers.
  void disposeAll() {
    for (final t in _tickers) {
      t.dispose();
    }
    _tickers.clear();
  }
}
