/// Virtual DOM diffing algorithm.
///
/// Compares two [VNode] trees and produces a list of [Patch] operations
/// that transform the old tree into the new one.
///
/// Complexity: O(n) — single pass, heuristic-based (same algorithm family
/// as React / Preact).
///
/// Heuristics:
///   1. Nodes of different types → replace entirely.
///   2. Text nodes → compare strings.
///   3. Elements with different tags → replace entirely.
///   4. Same-tag elements → diff props, then reconcile children.
///   5. Children with keys → key-based matching; without keys → by position.
library druid.vdom.differ;

import 'vnode.dart';

// ---------------------------------------------------------------------------
// Patch hierarchy
// ---------------------------------------------------------------------------

/// A single atomic change to be applied to the real DOM.
sealed class Patch {
  const Patch();
}

/// Replace the entire node with [next].
class PatchReplace extends Patch {
  const PatchReplace(this.next);
  final VNode next;
}

/// Update a text node's content.
class PatchText extends Patch {
  const PatchText(this.text);
  final String text;
}

/// Set (or update) a single prop/attribute.
class PatchSetProp extends Patch {
  const PatchSetProp(this.key, this.value);
  final String key;
  final Object value;
}

/// Remove a prop/attribute.
class PatchRemoveProp extends Patch {
  const PatchRemoveProp(this.key);
  final String key;
}

/// Insert a new child at [index].
class PatchInsertChild extends Patch {
  const PatchInsertChild(this.index, this.child);
  final int index;
  final VNode child;
}

/// Remove the child at [index].
class PatchRemoveChild extends Patch {
  const PatchRemoveChild(this.index);
  final int index;
}

/// Move the child currently at [fromIndex] to [toIndex].
class PatchMoveChild extends Patch {
  const PatchMoveChild(this.fromIndex, this.toIndex);
  final int fromIndex;
  final int toIndex;
}

/// Apply [patches] to the child at [index].
class PatchChild extends Patch {
  const PatchChild(this.index, this.patches);
  final int index;
  final List<Patch> patches;
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Diff [oldNode] against [newNode].
///
/// Returns `[]` when the trees are identical (no-op), or a list of patches
/// describing the minimal set of mutations required.
///
/// Pass `null` for [oldNode] to produce a full-insert patch for [newNode].
List<Patch> diff(VNode? oldNode, VNode newNode) {
  if (oldNode == null) {
    return [PatchReplace(newNode)];
  }
  return _diffNodes(oldNode, newNode);
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

List<Patch> _diffNodes(VNode oldNode, VNode newNode) {
  // Different runtime types → full replace.
  if (oldNode.runtimeType != newNode.runtimeType) {
    return [PatchReplace(newNode)];
  }

  return switch (newNode) {
    VText() => _diffText(oldNode as VText, newNode),
    VElement() => _diffElement(oldNode as VElement, newNode),
  };
}

List<Patch> _diffText(VText oldNode, VText newNode) {
  if (oldNode.text == newNode.text) return [];
  return [PatchText(newNode.text)];
}

List<Patch> _diffElement(VElement oldEl, VElement newEl) {
  // Different tags → replace.
  if (oldEl.tag != newEl.tag) {
    return [PatchReplace(newEl)];
  }

  final patches = <Patch>[];

  // Diff props.
  patches.addAll(_diffProps(oldEl.props, newEl.props));

  // Diff children.
  patches.addAll(_diffChildren(oldEl.children, newEl.children));

  return patches;
}

// ---------------------------------------------------------------------------
// Props diffing
// ---------------------------------------------------------------------------

List<Patch> _diffProps(
  Map<String, Object> oldProps,
  Map<String, Object> newProps,
) {
  final patches = <Patch>[];

  // Set or update props present in newProps.
  for (final entry in newProps.entries) {
    final oldVal = oldProps[entry.key];
    if (oldVal != entry.value) {
      patches.add(PatchSetProp(entry.key, entry.value));
    }
  }

  // Remove props that no longer exist.
  for (final key in oldProps.keys) {
    if (!newProps.containsKey(key)) {
      patches.add(PatchRemoveProp(key));
    }
  }

  return patches;
}

// ---------------------------------------------------------------------------
// Children reconciliation
// ---------------------------------------------------------------------------

List<Patch> _diffChildren(List<VNode> oldChildren, List<VNode> newChildren) {
  // Choose algorithm based on whether keys are present.
  final hasKeys =
      newChildren.any((n) => n.key != null) ||
      oldChildren.any((n) => n.key != null);

  return hasKeys
      ? _diffKeyedChildren(oldChildren, newChildren)
      : _diffUnkeyedChildren(oldChildren, newChildren);
}

// Position-based (no keys) — simple and fast for static lists.
List<Patch> _diffUnkeyedChildren(
  List<VNode> oldChildren,
  List<VNode> newChildren,
) {
  final patches = <Patch>[];
  final maxLen =
      oldChildren.length > newChildren.length
          ? oldChildren.length
          : newChildren.length;

  for (var i = 0; i < maxLen; i++) {
    if (i >= oldChildren.length) {
      // Insert new child.
      patches.add(PatchInsertChild(i, newChildren[i]));
    } else if (i >= newChildren.length) {
      // Remove excess old child.  We always remove at the same logical index
      // because each removal shifts subsequent indices; we account for this by
      // removing from the end downward — but since PatchRemoveChild carries
      // the index, the patcher must apply removals in reverse order.
      patches.add(PatchRemoveChild(i));
    } else {
      final childPatches = _diffNodes(oldChildren[i], newChildren[i]);
      if (childPatches.isNotEmpty) {
        patches.add(PatchChild(i, childPatches));
      }
    }
  }

  return patches;
}

// Key-based reconciliation — preserves component identity across renders.
List<Patch> _diffKeyedChildren(
  List<VNode> oldChildren,
  List<VNode> newChildren,
) {
  final patches = <Patch>[];

  // Build old key → index map.
  final oldKeyIndex = <String, int>{};
  for (var i = 0; i < oldChildren.length; i++) {
    final key = oldChildren[i].key;
    if (key != null) oldKeyIndex[key] = i;
  }

  // Track which old indices have been matched.
  final matched = <int>{};
  final newMapped = <int, int>{}; // newIndex → oldIndex

  for (var ni = 0; ni < newChildren.length; ni++) {
    final key = newChildren[ni].key;
    if (key != null && oldKeyIndex.containsKey(key)) {
      final oi = oldKeyIndex[key]!;
      matched.add(oi);
      newMapped[ni] = oi;
    }
  }

  // Remove old children that are no longer in the new list.
  // Collect indices to remove in descending order (avoids index shift issues).
  final toRemove = <int>[];
  for (var i = 0; i < oldChildren.length; i++) {
    if (!matched.contains(i)) {
      toRemove.add(i);
    }
  }
  for (final i in toRemove.reversed) {
    patches.add(PatchRemoveChild(i));
  }

  // Insert new children and patch matched ones.
  for (var ni = 0; ni < newChildren.length; ni++) {
    if (newMapped.containsKey(ni)) {
      final oi = newMapped[ni]!;
      final childPatches = _diffNodes(oldChildren[oi], newChildren[ni]);
      if (childPatches.isNotEmpty) {
        patches.add(PatchChild(ni, childPatches));
      }
    } else {
      patches.add(PatchInsertChild(ni, newChildren[ni]));
    }
  }

  return patches;
}
