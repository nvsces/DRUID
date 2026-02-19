import 'package:test/test.dart';
// Import vdom directly — no package:web dependency.
import 'package:druid/src/vdom/vnode.dart';
import 'package:druid/src/vdom/differ.dart';

void main() {
  group('diff — null old', () {
    test('returns PatchReplace when old is null', () {
      final patches = diff(null, const VText('hi'));
      expect(patches, hasLength(1));
      expect(patches.first, isA<PatchReplace>());
    });
  });

  group('diff — VText', () {
    test('no patches when text is equal', () {
      final patches = diff(const VText('a'), const VText('a'));
      expect(patches, isEmpty);
    });

    test('PatchText when text differs', () {
      final patches = diff(const VText('old'), const VText('new'));
      expect(patches, hasLength(1));
      final p = patches.first as PatchText;
      expect(p.text, equals('new'));
    });
  });

  group('diff — VElement type change', () {
    test('replaces when runtime types differ', () {
      final patches = diff(
        const VText('x'),
        const VElement(tag: 'div'),
      );
      expect(patches, hasLength(1));
      expect(patches.first, isA<PatchReplace>());
    });

    test('replaces when tags differ', () {
      final patches = diff(
        const VElement(tag: 'div'),
        const VElement(tag: 'span'),
      );
      expect(patches, hasLength(1));
      expect(patches.first, isA<PatchReplace>());
    });
  });

  group('diff — props', () {
    test('no patches when props are identical', () {
      final patches = diff(
        const VElement(tag: 'div', props: {'className': 'a'}),
        const VElement(tag: 'div', props: {'className': 'a'}),
      );
      expect(patches, isEmpty);
    });

    test('PatchSetProp when prop value changes', () {
      final patches = diff(
        const VElement(tag: 'div', props: {'className': 'a'}),
        const VElement(tag: 'div', props: {'className': 'b'}),
      );
      expect(patches, hasLength(1));
      final p = patches.first as PatchSetProp;
      expect(p.key, equals('className'));
      expect(p.value, equals('b'));
    });

    test('PatchSetProp for new prop', () {
      final patches = diff(
        const VElement(tag: 'div', props: {}),
        const VElement(tag: 'div', props: {'id': 'root'}),
      );
      expect(patches, hasLength(1));
      expect((patches.first as PatchSetProp).key, equals('id'));
    });

    test('PatchRemoveProp for removed prop', () {
      final patches = diff(
        const VElement(tag: 'div', props: {'id': 'x'}),
        const VElement(tag: 'div', props: {}),
      );
      expect(patches, hasLength(1));
      expect(patches.first, isA<PatchRemoveProp>());
    });
  });

  group('diff — children (unkeyed)', () {
    test('no patches for identical children', () {
      final patches = diff(
        const VElement(tag: 'ul', children: [VText('a'), VText('b')]),
        const VElement(tag: 'ul', children: [VText('a'), VText('b')]),
      );
      expect(patches, isEmpty);
    });

    test('PatchChild when child text changes', () {
      final patches = diff(
        const VElement(tag: 'ul', children: [VText('old')]),
        const VElement(tag: 'ul', children: [VText('new')]),
      );
      expect(patches, hasLength(1));
      final p = patches.first as PatchChild;
      expect(p.index, equals(0));
      expect(p.patches.first, isA<PatchText>());
    });

    test('PatchInsertChild when new child added', () {
      final patches = diff(
        const VElement(tag: 'ul', children: [VText('a')]),
        const VElement(tag: 'ul', children: [VText('a'), VText('b')]),
      );
      expect(patches.any((p) => p is PatchInsertChild), isTrue);
    });

    test('PatchRemoveChild when child removed', () {
      final patches = diff(
        const VElement(tag: 'ul', children: [VText('a'), VText('b')]),
        const VElement(tag: 'ul', children: [VText('a')]),
      );
      expect(patches.any((p) => p is PatchRemoveChild), isTrue);
    });
  });

  group('diff — children (keyed)', () {
    test('no patches for identical keyed children', () {
      final patches = diff(
        const VElement(tag: 'ul', children: [
          VText('a', key: 'k1'),
          VText('b', key: 'k2'),
        ]),
        const VElement(tag: 'ul', children: [
          VText('a', key: 'k1'),
          VText('b', key: 'k2'),
        ]),
      );
      expect(patches, isEmpty);
    });

    test('removes keyed child no longer present', () {
      final patches = diff(
        const VElement(tag: 'ul', children: [
          VText('a', key: 'k1'),
          VText('b', key: 'k2'),
        ]),
        const VElement(tag: 'ul', children: [
          VText('a', key: 'k1'),
        ]),
      );
      expect(patches.any((p) => p is PatchRemoveChild), isTrue);
    });

    test('inserts new keyed child', () {
      final patches = diff(
        const VElement(tag: 'ul', children: [
          VText('a', key: 'k1'),
        ]),
        const VElement(tag: 'ul', children: [
          VText('a', key: 'k1'),
          VText('b', key: 'k2'),
        ]),
      );
      expect(patches.any((p) => p is PatchInsertChild), isTrue);
    });
  });
}
