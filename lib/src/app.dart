/// runApp — framework entry point.
///
/// Mounts [root] widget into the DOM element matched by [selector],
/// sets up a reactive render loop via [Effect], and handles StatefulWidget
/// lifecycle.
library druid.app;

import 'package:web/web.dart' as web;

import 'core/signal.dart';
import 'vdom/vnode.dart';
import 'vdom/differ.dart';
import 'vdom/patcher.dart' as patcher;
import 'widgets/widget.dart';
import 'widgets/context.dart';

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Mount [root] into the DOM node matched by CSS [selector].
///
/// Sets up a reactive render loop: whenever a [Signal] read during [build]
/// changes, the widget tree is re-built, diffed against the previous VNode
/// tree, and minimal patches are applied to the real DOM.
///
/// ```dart
/// void main() => runApp(Counter(), selector: '#app');
/// ```
void runApp(Widget root, {String selector = '#app'}) {
  final container = web.document.querySelector(selector);
  if (container == null) {
    throw StateError('druid: no element found for selector "$selector"');
  }

  _AppRunner(root, container).mount();
}

// ---------------------------------------------------------------------------
// Internal runner
// ---------------------------------------------------------------------------

class _AppRunner {
  _AppRunner(this._root, this._container);

  final Widget _root;
  final web.Element _container;

  VNode? _currentVNode;
  web.Node? _currentDom;

  // Managed State objects keyed by StatefulWidget runtime type.
  final Map<Type, State> _stateByType = {};

  late final Effect _renderEffect;
  late final BuildContext _context;

  void mount() {
    _context = BuildContext(buildWidget: _buildWidget);
    _renderEffect = effect(_render);
  }

  void _render() {
    final newVNode = _buildWidget(_root);

    if (_currentVNode == null || _currentDom == null) {
      // First render — mount from scratch.
      final dom = patcher.mount(newVNode);
      _container.appendChild(dom);
      _currentDom = dom;
    } else {
      // Subsequent renders — diff and patch.
      final patches = diff(_currentVNode, newVNode);
      if (patches.isNotEmpty) {
        _currentDom = patcher.applyPatches(_currentDom!, patches, newVNode);
      }
    }

    _currentVNode = newVNode;
  }

  /// Recursively build a [VNode] tree from [widget].
  VNode _buildWidget(Widget widget) {
    if (widget is StatefulWidget) {
      return _buildStateful(widget);
    }
    if (widget is StatelessWidget) {
      return _buildWidget(widget.build(_context));
    }
    // Leaf widget (Text, html elements) — delegate to toVNode with runner context.
    return widget.toVNode(_context);
  }

  VNode _buildStateful(StatefulWidget widget) {
    final state = _getOrCreateState(widget);
    final childWidget = state.build(state.context);
    return _buildWidget(childWidget);
  }

  State _getOrCreateState(StatefulWidget widget) {
    final type = widget.runtimeType;
    if (_stateByType.containsKey(type)) {
      final existing = _stateByType[type]!;
      existing.updateWidget(widget);
      return existing;
    }

    final state = widget.createState();
    state.mountWith(widget, _context);
    state.initState();
    _stateByType[type] = state;
    return state;
  }

  void dispose() {
    _renderEffect.dispose();
    for (final s in _stateByType.values) {
      s.dispose();
    }
    _stateByType.clear();
  }
}
