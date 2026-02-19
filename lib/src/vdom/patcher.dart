/// DOM patcher — applies [Patch] operations produced by the differ to the
/// real DOM tree via `package:web`.
library druid.vdom.patcher;

import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'vnode.dart';
import 'differ.dart';

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Apply [patches] to [domNode], using [newVNode] as the updated VNode.
/// Returns the (possibly replaced) DOM node.
web.Node applyPatches(
  web.Node domNode,
  List<Patch> patches,
  VNode newVNode,
) {
  for (final patch in patches) {
    domNode = _applyPatch(domNode, patch, newVNode);
  }
  return domNode;
}

/// Mount [vnode] as a fresh DOM subtree and return the root [web.Node].
web.Node mount(VNode vnode) {
  return switch (vnode) {
    VText() => web.document.createTextNode(vnode.text),
    VElement() => _mountElement(vnode),
  };
}

// ---------------------------------------------------------------------------
// Internal
// ---------------------------------------------------------------------------

web.Node _applyPatch(web.Node node, Patch patch, VNode newVNode) {
  return switch (patch) {
    PatchReplace(:final next) => _replace(node, next),
    PatchText(:final text) => _updateText(node, text),
    PatchSetProp(:final key, :final value) =>
      _setProp(node as web.Element, key, value),
    PatchRemoveProp(:final key) => _removeProp(node as web.Element, key),
    PatchInsertChild(:final index, :final child) =>
      _insertChild(node as web.Element, index, child),
    PatchRemoveChild(:final index) =>
      _removeChild(node as web.Element, index),
    PatchMoveChild(:final fromIndex, :final toIndex) =>
      _moveChild(node as web.Element, fromIndex, toIndex),
    PatchChild(:final index, :final patches) =>
      _patchChild(node as web.Element, index, patches, newVNode),
  };
}

web.Node _replace(web.Node old, VNode next) {
  final newDom = mount(next);
  old.parentNode?.replaceChild(newDom, old);
  return newDom;
}

web.Node _updateText(web.Node node, String text) {
  node.textContent = text;
  return node;
}

web.Node _setProp(web.Element el, String key, Object value) {
  _applyPropToElement(el, key, value);
  return el;
}

web.Node _removeProp(web.Element el, String key) {
  if (key.startsWith('on')) {
    _eventCache[el]?.remove(key);
  } else if (key == 'style') {
    el.removeAttribute('style');
  } else if (key == 'className') {
    el.removeAttribute('class');
  } else {
    el.removeAttribute(key);
  }
  return el;
}

web.Node _insertChild(web.Element parent, int index, VNode child) {
  final newDom = mount(child);
  final children = parent.childNodes;
  if (index >= children.length) {
    parent.appendChild(newDom);
  } else {
    parent.insertBefore(newDom, children.item(index));
  }
  return parent;
}

web.Node _removeChild(web.Element parent, int index) {
  final children = parent.childNodes;
  if (index < children.length) {
    final child = children.item(index);
    if (child != null) parent.removeChild(child);
  }
  return parent;
}

web.Node _moveChild(web.Element parent, int fromIndex, int toIndex) {
  final children = parent.childNodes;
  if (fromIndex >= children.length) return parent;
  final child = children.item(fromIndex);
  if (child == null) return parent;
  parent.removeChild(child);
  final newChildren = parent.childNodes;
  if (toIndex >= newChildren.length) {
    parent.appendChild(child);
  } else {
    parent.insertBefore(child, newChildren.item(toIndex));
  }
  return parent;
}

web.Node _patchChild(
  web.Element parent,
  int index,
  List<Patch> patches,
  VNode parentVNode,
) {
  final children = parent.childNodes;
  if (index >= children.length) return parent;

  final newVNode =
      parentVNode is VElement ? parentVNode.children[index] : null;
  if (newVNode == null) return parent;

  final child = children.item(index);
  if (child == null) return parent;

  applyPatches(child, patches, newVNode);
  return parent;
}

// ---------------------------------------------------------------------------
// Element mounting
// ---------------------------------------------------------------------------

web.Element _mountElement(VElement vnode) {
  final el = web.document.createElement(vnode.tag);

  for (final entry in vnode.props.entries) {
    _applyPropToElement(el, entry.key, entry.value);
  }

  for (final child in vnode.children) {
    el.appendChild(mount(child));
  }

  return el;
}

// ---------------------------------------------------------------------------
// Prop application
// ---------------------------------------------------------------------------

/// Cache for event listener functions stored per element.
/// Key: element → map of prop-key (e.g. 'onClick') → current JS handler.
final _eventCache = Expando<Map<String, JSFunction>>('druid_event_cache');

void _applyPropToElement(web.Element el, String key, Object value) {
  switch (key) {
    case 'className':
      el.className = value as String;

    case 'style':
      if (value is Map<String, String>) {
        el.removeAttribute('style');
        if (el is web.HTMLElement) {
          value.forEach((k, v) => el.style.setProperty(k, v));
        }
      }

    case 'value':
      if (el is web.HTMLInputElement) {
        el.value = value as String;
      } else if (el is web.HTMLTextAreaElement) {
        el.value = value as String;
      }

    case 'checked':
      if (el is web.HTMLInputElement) {
        el.checked = value as bool;
      }

    case 'disabled':
      if (value == true) {
        el.setAttribute('disabled', '');
      } else {
        el.removeAttribute('disabled');
      }

    case 'href':
      if (el is web.HTMLAnchorElement) {
        el.href = value as String;
      }

    case 'src':
      if (el is web.HTMLImageElement) {
        el.src = value as String;
      }

    case 'alt':
      if (el is web.HTMLImageElement) {
        el.alt = value as String;
      }

    case 'type':
      if (el is web.HTMLInputElement) {
        el.type = value as String;
      }

    case 'placeholder':
      if (el is web.HTMLInputElement) {
        el.placeholder = value as String;
      } else if (el is web.HTMLTextAreaElement) {
        el.placeholder = value as String;
      }

    case 'selected':
      if (el is web.HTMLOptionElement && value is bool) {
        el.selected = value;
      }

    case 'for':
      if (el is web.HTMLLabelElement) {
        el.htmlFor = value as String;
      }

    case 'target':
      if (el is web.HTMLAnchorElement) {
        el.target = value as String;
      }

    default:
      if (key.startsWith('on') && value is Function) {
        _setEventListener(el, key, value as EventHandler);
      } else if (value is String) {
        el.setAttribute(key, value);
      } else if (value is bool) {
        if (value) {
          el.setAttribute(key, '');
        } else {
          el.removeAttribute(key);
        }
      }
  }
}

/// Registers [handler] as the sole listener for event [propKey] on [el].
/// Replaces any previously registered listener for the same event.
void _setEventListener(
    web.Element el, String propKey, EventHandler handler) {
  final cache = _eventCache[el] ??= {};
  final eventName = _propKeyToEventName(propKey);

  // Remove old listener.
  final oldFn = cache[propKey];
  if (oldFn != null) {
    el.removeEventListener(eventName, oldFn);
  }

  // Wrap the Dart handler in a JSFunction.
  final jsFn = ((web.Event e) => handler(e)).toJS;
  cache[propKey] = jsFn;
  el.addEventListener(eventName, jsFn);
}

String _propKeyToEventName(String propKey) {
  // 'onClick' → 'click', 'onMouseOver' → 'mouseover'
  final raw = propKey.substring(2);
  return raw[0].toLowerCase() + raw.substring(1);
}
