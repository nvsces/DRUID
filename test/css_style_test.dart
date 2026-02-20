import 'package:test/test.dart';

import 'package:druid/src/widgets/css_units.dart';
import 'package:druid/src/widgets/css_style.dart';
import 'package:druid/src/widgets/style.dart';
import 'package:druid/src/core/color.dart';

void main() {
  // -------------------------------------------------------------------------
  // CssValue units
  // -------------------------------------------------------------------------
  group('CssValue units', () {
    test('Px', () {
      expect(Px(10).toCss(), '10px');
      expect(Px(-3.5).toCss(), '-3.5px');
    });

    test('Percent', () {
      expect(Percent(50).toCss(), '50%');
      expect(Percent(100).toCss(), '100%');
    });

    test('Rem', () {
      expect(Rem(1.5).toCss(), '1.5rem');
    });

    test('CssEm', () {
      expect(CssEm(2).toCss(), '2em');
    });

    test('Vw / Vh', () {
      expect(Vw(100).toCss(), '100vw');
      expect(Vh(50).toCss(), '50vh');
    });

    test('Auto', () {
      expect(Auto().toCss(), 'auto');
    });

    test('CssRaw', () {
      expect(CssRaw('calc(100% - 20px)').toCss(), 'calc(100% - 20px)');
    });

    test('equality', () {
      expect(Px(10), Px(10));
      expect(Px(10), isNot(Px(20)));
      expect(Px(10), isNot(Rem(10)));
      expect(Auto(), Auto());
      expect(CssRaw('a'), CssRaw('a'));
      expect(CssRaw('a'), isNot(CssRaw('b')));
    });

    test('toString delegates to toCss', () {
      expect(Px(5).toString(), '5px');
      expect(Percent(50).toString(), '50%');
    });
  });

  // -------------------------------------------------------------------------
  // CssStyle.toMap — enum values
  // -------------------------------------------------------------------------
  group('CssStyle.toMap enums', () {
    test('Display', () {
      expect(CssStyle(display: Display.flex).toMap(), {'display': 'flex'});
      expect(CssStyle(display: Display.inlineBlock).toMap(), {'display': 'inline-block'});
      expect(CssStyle(display: Display.none).toMap(), {'display': 'none'});
      expect(CssStyle(display: Display.grid).toMap(), {'display': 'grid'});
      expect(CssStyle(display: Display.contents).toMap(), {'display': 'contents'});
    });

    test('Position', () {
      expect(CssStyle(position: Position.absolute).toMap(), {'position': 'absolute'});
      expect(CssStyle(position: Position.sticky).toMap(), {'position': 'sticky'});
      expect(CssStyle(position: Position.static_).toMap(), {'position': 'static'});
    });

    test('FlexDirection', () {
      expect(CssStyle(flexDirection: FlexDirection.column).toMap(), {'flex-direction': 'column'});
      expect(CssStyle(flexDirection: FlexDirection.rowReverse).toMap(), {'flex-direction': 'row-reverse'});
    });

    test('AlignItems', () {
      expect(CssStyle(alignItems: AlignItems.center).toMap(), {'align-items': 'center'});
      expect(CssStyle(alignItems: AlignItems.flexStart).toMap(), {'align-items': 'flex-start'});
    });

    test('JustifyContent', () {
      expect(CssStyle(justifyContent: JustifyContent.spaceBetween).toMap(), {'justify-content': 'space-between'});
    });

    test('Cursor', () {
      expect(CssStyle(cursor: Cursor.pointer).toMap(), {'cursor': 'pointer'});
      expect(CssStyle(cursor: Cursor.notAllowed).toMap(), {'cursor': 'not-allowed'});
      expect(CssStyle(cursor: Cursor.default_).toMap(), {'cursor': 'default'});
    });

    test('Overflow', () {
      expect(CssStyle(overflowX: Overflow.hidden).toMap(), {'overflow-x': 'hidden'});
      expect(CssStyle(overflowY: Overflow.auto_).toMap(), {'overflow-y': 'auto'});
    });

    test('WhiteSpace', () {
      expect(CssStyle(whiteSpace: WhiteSpace.nowrap).toMap(), {'white-space': 'nowrap'});
      expect(CssStyle(whiteSpace: WhiteSpace.preWrap).toMap(), {'white-space': 'pre-wrap'});
    });

    test('TextTransform', () {
      expect(CssStyle(textTransform: TextTransform.uppercase).toMap(), {'text-transform': 'uppercase'});
    });

    test('ObjectFit', () {
      expect(CssStyle(objectFit: ObjectFit.cover).toMap(), {'object-fit': 'cover'});
      expect(CssStyle(objectFit: ObjectFit.scaleDown).toMap(), {'object-fit': 'scale-down'});
    });

    test('BoxSizing', () {
      expect(CssStyle(boxSizing: BoxSizing.borderBox).toMap(), {'box-sizing': 'border-box'});
    });
  });

  // -------------------------------------------------------------------------
  // CssStyle.toMap — typed values
  // -------------------------------------------------------------------------
  group('CssStyle.toMap typed values', () {
    test('CssValue properties', () {
      final s = CssStyle(
        width: Px(200),
        height: Percent(100),
        top: Rem(1),
        gap: Px(8),
        fontSize: Rem(1.2),
      );
      final m = s.toMap();
      expect(m['width'], '200px');
      expect(m['height'], '100%');
      expect(m['top'], '1rem');
      expect(m['gap'], '8px');
      expect(m['font-size'], '1.2rem');
    });

    test('zIndex as int', () {
      expect(CssStyle(zIndex: 10).toMap(), {'z-index': '10'});
    });

    test('opacity as num', () {
      expect(CssStyle(opacity: 0.5).toMap(), {'opacity': '0.5'});
    });

    test('lineHeight as num', () {
      expect(CssStyle(lineHeight: 1.5).toMap(), {'line-height': '1.5'});
    });

    test('Color values', () {
      final s = CssStyle(
        color: Color(0xFFFF0000),
        background: Color(0xFF00FF00),
      );
      final m = s.toMap();
      expect(m['color'], '#ff0000');
      expect(m['background'], '#00ff00');
    });

    test('String fallback for color/background', () {
      final s = CssStyle(
        background: 'linear-gradient(135deg, #ff0, #0ff)',
        color: '#333',
      );
      final m = s.toMap();
      expect(m['background'], 'linear-gradient(135deg, #ff0, #0ff)');
      expect(m['color'], '#333');
    });

    test('EdgeInsets for padding/margin', () {
      final s = CssStyle(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.all(8),
      );
      final m = s.toMap();
      expect(m['padding'], '10.0px 14.0px 10.0px 14.0px');
      expect(m['margin'], '8.0px 8.0px 8.0px 8.0px');
    });

    test('CssValue for padding/margin', () {
      final s = CssStyle(
        padding: Px(16),
        margin: Auto(),
      );
      final m = s.toMap();
      expect(m['padding'], '16px');
      expect(m['margin'], 'auto');
    });

    test('Border typed', () {
      final s = CssStyle(
        border: Border(width: 1.5, color: Color(0xFFcccccc), style: 'solid'),
      );
      expect(s.toMap()['border'], '1.5px solid #cccccc');
    });

    test('Border string', () {
      final s = CssStyle(border: '1px dashed red');
      expect(s.toMap()['border'], '1px dashed red');
    });

    test('BorderRadius typed', () {
      final s = CssStyle(borderRadius: BorderRadius.circular(12));
      expect(s.toMap()['border-radius'], '12.0px 12.0px 12.0px 12.0px');
    });

    test('BorderRadius CssValue', () {
      final s = CssStyle(borderRadius: Px(8));
      expect(s.toMap()['border-radius'], '8px');
    });

    test('BoxShadow typed', () {
      final s = CssStyle(
        boxShadow: [
          BoxShadow(color: Color(0x33000000), offsetY: 8, blurRadius: 24),
        ],
      );
      expect(s.toMap()['box-shadow'], '0.0px 8.0px 24.0px 0.0px rgba(0, 0, 0, 0.2)');
    });

    test('BoxShadow string', () {
      final s = CssStyle(boxShadow: '0 4px 12px rgba(0,0,0,0.1)');
      expect(s.toMap()['box-shadow'], '0 4px 12px rgba(0,0,0,0.1)');
    });

    test('FontWeight typed', () {
      expect(CssStyle(fontWeight: FontWeight.bold).toMap()['font-weight'], '700');
      expect(CssStyle(fontWeight: FontWeight.w500).toMap()['font-weight'], '500');
    });

    test('FontWeight string', () {
      expect(CssStyle(fontWeight: '600').toMap()['font-weight'], '600');
    });

    test('TextOverflow ellipsis adds multiple properties', () {
      final m = CssStyle(textOverflow: TextOverflow.ellipsis).toMap();
      expect(m['overflow'], 'hidden');
      expect(m['text-overflow'], 'ellipsis');
      expect(m['white-space'], 'nowrap');
    });

    test('transform and transition as raw strings', () {
      final s = CssStyle(
        transform: 'translateY(10px) scale(1.2)',
        transition: 'all 0.3s ease',
      );
      final m = s.toMap();
      expect(m['transform'], 'translateY(10px) scale(1.2)');
      expect(m['transition'], 'all 0.3s ease');
    });

    test('grid string properties', () {
      final s = CssStyle(
        gridTemplateColumns: 'repeat(3, 1fr)',
        gridColumn: '1 / 3',
      );
      final m = s.toMap();
      expect(m['grid-template-columns'], 'repeat(3, 1fr)');
      expect(m['grid-column'], '1 / 3');
    });

    test('extra escape hatch', () {
      final s = CssStyle(
        display: Display.flex,
        extra: {'scroll-behavior': 'smooth', 'aspect-ratio': '16/9'},
      );
      final m = s.toMap();
      expect(m['display'], 'flex');
      expect(m['scroll-behavior'], 'smooth');
      expect(m['aspect-ratio'], '16/9');
    });
  });

  // -------------------------------------------------------------------------
  // CssStyle.toMap — empty
  // -------------------------------------------------------------------------
  test('empty CssStyle produces empty map', () {
    expect(CssStyle().toMap(), isEmpty);
  });

  // -------------------------------------------------------------------------
  // CssStyle.merge
  // -------------------------------------------------------------------------
  group('CssStyle.merge', () {
    test('other overrides this', () {
      final base = CssStyle(
        display: Display.flex,
        color: '#000',
        gap: Px(8),
      );
      final override = CssStyle(
        color: '#fff',
        cursor: Cursor.pointer,
      );
      final merged = base.merge(override);
      final m = merged.toMap();
      expect(m['display'], 'flex');
      expect(m['color'], '#fff');
      expect(m['gap'], '8px');
      expect(m['cursor'], 'pointer');
    });

    test('merge with null returns this', () {
      final s = CssStyle(display: Display.flex);
      expect(identical(s.merge(null), s), isTrue);
    });

    test('extra maps merge', () {
      final a = CssStyle(extra: {'a': '1', 'b': '2'});
      final b = CssStyle(extra: {'b': '3', 'c': '4'});
      final m = a.merge(b).toMap();
      expect(m['a'], '1');
      expect(m['b'], '3');
      expect(m['c'], '4');
    });
  });

  // -------------------------------------------------------------------------
  // CssStyle.copyWith
  // -------------------------------------------------------------------------
  group('CssStyle.copyWith', () {
    test('replaces specified fields', () {
      final s = CssStyle(
        display: Display.flex,
        gap: Px(8),
        color: '#000',
      );
      final copied = s.copyWith(gap: Px(16), color: '#fff');
      final m = copied.toMap();
      expect(m['display'], 'flex');
      expect(m['gap'], '16px');
      expect(m['color'], '#fff');
    });

    test('preserves original when no args', () {
      final s = CssStyle(display: Display.grid, zIndex: 5);
      final copied = s.copyWith();
      expect(copied.toMap(), s.toMap());
    });
  });

  // -------------------------------------------------------------------------
  // Full real-world style example
  // -------------------------------------------------------------------------
  test('real-world badge style', () {
    final s = CssStyle(
      position: Position.absolute,
      bottom: Px(80),
      left: Px(-10),
      background: '#ffffff',
      border: '1.5px solid #e2e2e2',
      borderRadius: Px(14),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      boxShadow: '0 8px 24px rgba(0,0,0,0.1)',
      display: Display.flex,
      alignItems: AlignItems.center,
      gap: Px(8),
      zIndex: 4,
      transform: 'translateY(10.50px)',
    );
    final m = s.toMap();
    expect(m['position'], 'absolute');
    expect(m['bottom'], '80px');
    expect(m['left'], '-10px');
    expect(m['background'], '#ffffff');
    expect(m['border'], '1.5px solid #e2e2e2');
    expect(m['border-radius'], '14px');
    expect(m['padding'], '10.0px 14.0px 10.0px 14.0px');
    expect(m['box-shadow'], '0 8px 24px rgba(0,0,0,0.1)');
    expect(m['display'], 'flex');
    expect(m['align-items'], 'center');
    expect(m['gap'], '8px');
    expect(m['z-index'], '4');
    expect(m['transform'], 'translateY(10.50px)');
  });
}
