/// Typed CSS style class for druid widgets.
///
/// ```dart
/// Div(
///   style: CssStyle(
///     display: Display.flex,
///     alignItems: AlignItems.center,
///     gap: Px(8),
///     padding: EdgeInsets.all(16),
///     background: Color(0xFF1a1a2e),
///     borderRadius: Px(12),
///   ),
///   children: [...],
/// )
/// ```
library druid.widgets.css_style;

import 'css_units.dart';
import 'style.dart';
import '../core/color.dart';

// ---------------------------------------------------------------------------
// Enums — discrete CSS property values
// ---------------------------------------------------------------------------

enum Display {
  none,
  block,
  inline,
  inlineBlock,
  flex,
  inlineFlex,
  grid,
  inlineGrid,
  contents,
}

enum Position {
  static_,
  relative,
  absolute,
  fixed,
  sticky,
}

enum FlexDirection {
  row,
  rowReverse,
  column,
  columnReverse,
}

enum FlexWrap {
  nowrap,
  wrap,
  wrapReverse,
}

enum AlignItems {
  stretch,
  flexStart,
  flexEnd,
  center,
  baseline,
}

enum JustifyContent {
  flexStart,
  flexEnd,
  center,
  spaceBetween,
  spaceAround,
  spaceEvenly,
}

enum AlignSelf {
  auto_,
  stretch,
  flexStart,
  flexEnd,
  center,
  baseline,
}

enum Overflow {
  visible,
  hidden,
  scroll,
  auto_,
}

enum Cursor {
  pointer,
  default_,
  text,
  move,
  grab,
  grabbing,
  notAllowed,
  none,
  crosshair,
  help,
  wait,
}

enum BoxSizing {
  contentBox,
  borderBox,
}

enum Visibility {
  visible,
  hidden,
  collapse,
}

enum WhiteSpace {
  normal,
  nowrap,
  pre,
  preWrap,
  preLine,
}

enum TextTransform {
  none,
  uppercase,
  lowercase,
  capitalize,
}

enum ObjectFit {
  fill,
  contain,
  cover,
  none,
  scaleDown,
}

enum PointerEvents {
  auto_,
  none,
}

// ---------------------------------------------------------------------------
// CssStyle
// ---------------------------------------------------------------------------

/// A fully typed CSS style declaration.
///
/// All fields are optional — only non-null values are emitted by [toMap].
/// Fields that accept multiple types (e.g. `background` can be [Color] or
/// [String]) use `Object?` with runtime conversion in [toMap].
///
/// Use [extra] as an escape hatch for CSS properties not covered by typed
/// fields.
class CssStyle {
  // -- Layout ---------------------------------------------------------------
  final Display? display;
  final Position? position;
  final BoxSizing? boxSizing;
  final Visibility? visibility;

  // -- Position offsets -----------------------------------------------------
  final CssValue? top;
  final CssValue? right;
  final CssValue? bottom;
  final CssValue? left;
  final int? zIndex;

  // -- Sizing ---------------------------------------------------------------
  final CssValue? width;
  final CssValue? height;
  final CssValue? minWidth;
  final CssValue? minHeight;
  final CssValue? maxWidth;
  final CssValue? maxHeight;

  // -- Spacing (CssValue | EdgeInsets) --------------------------------------
  final Object? padding;
  final Object? margin;

  // -- Flexbox --------------------------------------------------------------
  final FlexDirection? flexDirection;
  final FlexWrap? flexWrap;
  final AlignItems? alignItems;
  final JustifyContent? justifyContent;
  final AlignSelf? alignSelf;
  final CssValue? gap;
  final CssValue? rowGap;
  final CssValue? columnGap;
  final num? flex;
  final num? flexGrow;
  final num? flexShrink;
  final CssValue? flexBasis;
  final int? order;

  // -- Grid -----------------------------------------------------------------
  final String? gridTemplate;
  final String? gridTemplateColumns;
  final String? gridTemplateRows;
  final String? gridColumn;
  final String? gridRow;
  final String? gridArea;

  // -- Background / Color ---------------------------------------------------
  /// [Color] or [String] (e.g. `'linear-gradient(...)'`).
  final Object? background;

  /// [Color] or [String].
  final Object? color;

  final num? opacity;

  // -- Border ---------------------------------------------------------------
  /// [Border] or [String] (e.g. `'1px solid #ccc'`).
  final Object? border;

  /// [BorderRadius], [CssValue] or [String].
  final Object? borderRadius;

  // -- Shadow ---------------------------------------------------------------
  /// [List]<[BoxShadow]> or [String].
  final Object? boxShadow;

  // -- Typography -----------------------------------------------------------
  final CssValue? fontSize;

  /// [FontWeight] or [String] (e.g. `'600'`).
  final Object? fontWeight;

  /// [FontStyle] or [String].
  final Object? fontStyle;

  final String? fontFamily;
  final num? lineHeight;
  final CssValue? letterSpacing;
  final TextAlign? textAlign;
  final String? textDecoration;
  final TextTransform? textTransform;
  final WhiteSpace? whiteSpace;
  final TextOverflow? textOverflow;

  // -- Transform / Animation ------------------------------------------------
  final String? transform;
  final String? transformOrigin;
  final String? transition;
  final String? animation;
  final String? filter;
  final String? backdropFilter;

  // -- Other ----------------------------------------------------------------
  final Cursor? cursor;
  final PointerEvents? pointerEvents;
  final ObjectFit? objectFit;
  final String? backgroundClip;
  final String? webkitBackgroundClip;
  final String? webkitTextFillColor;
  final String? userSelect;
  final String? listStyle;
  final String? outline;
  final String? content;
  final Overflow? overflowX;
  final Overflow? overflowY;

  /// Escape hatch: arbitrary CSS properties not covered above.
  final Map<String, String>? extra;

  const CssStyle({
    this.display,
    this.position,
    this.boxSizing,
    this.visibility,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.zIndex,
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.padding,
    this.margin,
    this.flexDirection,
    this.flexWrap,
    this.alignItems,
    this.justifyContent,
    this.alignSelf,
    this.gap,
    this.rowGap,
    this.columnGap,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.order,
    this.gridTemplate,
    this.gridTemplateColumns,
    this.gridTemplateRows,
    this.gridColumn,
    this.gridRow,
    this.gridArea,
    this.background,
    this.color,
    this.opacity,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.fontFamily,
    this.lineHeight,
    this.letterSpacing,
    this.textAlign,
    this.textDecoration,
    this.textTransform,
    this.whiteSpace,
    this.textOverflow,
    this.transform,
    this.transformOrigin,
    this.transition,
    this.animation,
    this.filter,
    this.backdropFilter,
    this.cursor,
    this.pointerEvents,
    this.objectFit,
    this.backgroundClip,
    this.webkitBackgroundClip,
    this.webkitTextFillColor,
    this.userSelect,
    this.listStyle,
    this.outline,
    this.content,
    this.overflowX,
    this.overflowY,
    this.extra,
  });

  /// Convert to `Map<String, String>` for VNode props.
  Map<String, String> toMap() {
    final m = <String, String>{};

    // Layout
    if (display != null) m['display'] = _displayCss(display!);
    if (position != null) m['position'] = _positionCss(position!);
    if (boxSizing != null) m['box-sizing'] = _boxSizingCss(boxSizing!);
    if (visibility != null) m['visibility'] = _visibilityCss(visibility!);

    // Position offsets
    if (top != null) m['top'] = top!.toCss();
    if (right != null) m['right'] = right!.toCss();
    if (bottom != null) m['bottom'] = bottom!.toCss();
    if (left != null) m['left'] = left!.toCss();
    if (zIndex != null) m['z-index'] = '$zIndex';

    // Sizing
    if (width != null) m['width'] = width!.toCss();
    if (height != null) m['height'] = height!.toCss();
    if (minWidth != null) m['min-width'] = minWidth!.toCss();
    if (minHeight != null) m['min-height'] = minHeight!.toCss();
    if (maxWidth != null) m['max-width'] = maxWidth!.toCss();
    if (maxHeight != null) m['max-height'] = maxHeight!.toCss();

    // Spacing
    if (padding != null) m['padding'] = _spacingCss(padding!);
    if (margin != null) m['margin'] = _spacingCss(margin!);

    // Flexbox
    if (flexDirection != null) m['flex-direction'] = _flexDirectionCss(flexDirection!);
    if (flexWrap != null) m['flex-wrap'] = _flexWrapCss(flexWrap!);
    if (alignItems != null) m['align-items'] = _alignItemsCss(alignItems!);
    if (justifyContent != null) m['justify-content'] = _justifyContentCss(justifyContent!);
    if (alignSelf != null) m['align-self'] = _alignSelfCss(alignSelf!);
    if (gap != null) m['gap'] = gap!.toCss();
    if (rowGap != null) m['row-gap'] = rowGap!.toCss();
    if (columnGap != null) m['column-gap'] = columnGap!.toCss();
    if (flex != null) m['flex'] = '$flex';
    if (flexGrow != null) m['flex-grow'] = '$flexGrow';
    if (flexShrink != null) m['flex-shrink'] = '$flexShrink';
    if (flexBasis != null) m['flex-basis'] = flexBasis!.toCss();
    if (order != null) m['order'] = '$order';

    // Grid
    if (gridTemplate != null) m['grid-template'] = gridTemplate!;
    if (gridTemplateColumns != null) m['grid-template-columns'] = gridTemplateColumns!;
    if (gridTemplateRows != null) m['grid-template-rows'] = gridTemplateRows!;
    if (gridColumn != null) m['grid-column'] = gridColumn!;
    if (gridRow != null) m['grid-row'] = gridRow!;
    if (gridArea != null) m['grid-area'] = gridArea!;

    // Background / Color
    if (background != null) m['background'] = _colorOrString(background!);
    if (color != null) m['color'] = _colorOrString(color!);
    if (opacity != null) m['opacity'] = '$opacity';

    // Border
    if (border != null) m['border'] = _borderCss(border!);
    if (borderRadius != null) m['border-radius'] = _borderRadiusCss(borderRadius!);

    // Shadow
    if (boxShadow != null) m['box-shadow'] = _boxShadowCss(boxShadow!);

    // Typography
    if (fontSize != null) m['font-size'] = fontSize!.toCss();
    if (fontWeight != null) m['font-weight'] = _fontWeightCss(fontWeight!);
    if (fontStyle != null) m['font-style'] = _fontStyleCss(fontStyle!);
    if (fontFamily != null) m['font-family'] = fontFamily!;
    if (lineHeight != null) m['line-height'] = '$lineHeight';
    if (letterSpacing != null) m['letter-spacing'] = letterSpacing!.toCss();
    if (textAlign != null) m['text-align'] = textAlign!.name;
    if (textDecoration != null) m['text-decoration'] = textDecoration!;
    if (textTransform != null) m['text-transform'] = _textTransformCss(textTransform!);
    if (whiteSpace != null) m['white-space'] = _whiteSpaceCss(whiteSpace!);
    if (textOverflow != null) {
      if (textOverflow == TextOverflow.ellipsis) {
        m['overflow'] = 'hidden';
        m['text-overflow'] = 'ellipsis';
        m['white-space'] = 'nowrap';
      } else {
        m['text-overflow'] = 'clip';
      }
    }

    // Transform / Animation
    if (transform != null) m['transform'] = transform!;
    if (transformOrigin != null) m['transform-origin'] = transformOrigin!;
    if (transition != null) m['transition'] = transition!;
    if (animation != null) m['animation'] = animation!;
    if (filter != null) m['filter'] = filter!;
    if (backdropFilter != null) m['backdrop-filter'] = backdropFilter!;

    // Other
    if (cursor != null) m['cursor'] = _cursorCss(cursor!);
    if (pointerEvents != null) m['pointer-events'] = _pointerEventsCss(pointerEvents!);
    if (objectFit != null) m['object-fit'] = _objectFitCss(objectFit!);
    if (backgroundClip != null) m['background-clip'] = backgroundClip!;
    if (webkitBackgroundClip != null) m['-webkit-background-clip'] = webkitBackgroundClip!;
    if (webkitTextFillColor != null) m['-webkit-text-fill-color'] = webkitTextFillColor!;
    if (userSelect != null) m['user-select'] = userSelect!;
    if (listStyle != null) m['list-style'] = listStyle!;
    if (outline != null) m['outline'] = outline!;
    if (content != null) m['content'] = content!;
    if (overflowX != null) m['overflow-x'] = _overflowCss(overflowX!);
    if (overflowY != null) m['overflow-y'] = _overflowCss(overflowY!);

    // Escape hatch
    if (extra != null) m.addAll(extra!);

    return m;
  }

  /// Merge this style with [other]. Values from [other] take precedence.
  CssStyle merge(CssStyle? other) {
    if (other == null) return this;
    return CssStyle(
      display: other.display ?? display,
      position: other.position ?? position,
      boxSizing: other.boxSizing ?? boxSizing,
      visibility: other.visibility ?? visibility,
      top: other.top ?? top,
      right: other.right ?? right,
      bottom: other.bottom ?? bottom,
      left: other.left ?? left,
      zIndex: other.zIndex ?? zIndex,
      width: other.width ?? width,
      height: other.height ?? height,
      minWidth: other.minWidth ?? minWidth,
      minHeight: other.minHeight ?? minHeight,
      maxWidth: other.maxWidth ?? maxWidth,
      maxHeight: other.maxHeight ?? maxHeight,
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      flexDirection: other.flexDirection ?? flexDirection,
      flexWrap: other.flexWrap ?? flexWrap,
      alignItems: other.alignItems ?? alignItems,
      justifyContent: other.justifyContent ?? justifyContent,
      alignSelf: other.alignSelf ?? alignSelf,
      gap: other.gap ?? gap,
      rowGap: other.rowGap ?? rowGap,
      columnGap: other.columnGap ?? columnGap,
      flex: other.flex ?? flex,
      flexGrow: other.flexGrow ?? flexGrow,
      flexShrink: other.flexShrink ?? flexShrink,
      flexBasis: other.flexBasis ?? flexBasis,
      order: other.order ?? order,
      gridTemplate: other.gridTemplate ?? gridTemplate,
      gridTemplateColumns: other.gridTemplateColumns ?? gridTemplateColumns,
      gridTemplateRows: other.gridTemplateRows ?? gridTemplateRows,
      gridColumn: other.gridColumn ?? gridColumn,
      gridRow: other.gridRow ?? gridRow,
      gridArea: other.gridArea ?? gridArea,
      background: other.background ?? background,
      color: other.color ?? color,
      opacity: other.opacity ?? opacity,
      border: other.border ?? border,
      borderRadius: other.borderRadius ?? borderRadius,
      boxShadow: other.boxShadow ?? boxShadow,
      fontSize: other.fontSize ?? fontSize,
      fontWeight: other.fontWeight ?? fontWeight,
      fontStyle: other.fontStyle ?? fontStyle,
      fontFamily: other.fontFamily ?? fontFamily,
      lineHeight: other.lineHeight ?? lineHeight,
      letterSpacing: other.letterSpacing ?? letterSpacing,
      textAlign: other.textAlign ?? textAlign,
      textDecoration: other.textDecoration ?? textDecoration,
      textTransform: other.textTransform ?? textTransform,
      whiteSpace: other.whiteSpace ?? whiteSpace,
      textOverflow: other.textOverflow ?? textOverflow,
      transform: other.transform ?? transform,
      transformOrigin: other.transformOrigin ?? transformOrigin,
      transition: other.transition ?? transition,
      animation: other.animation ?? animation,
      filter: other.filter ?? filter,
      backdropFilter: other.backdropFilter ?? backdropFilter,
      cursor: other.cursor ?? cursor,
      pointerEvents: other.pointerEvents ?? pointerEvents,
      objectFit: other.objectFit ?? objectFit,
      backgroundClip: other.backgroundClip ?? backgroundClip,
      webkitBackgroundClip: other.webkitBackgroundClip ?? webkitBackgroundClip,
      webkitTextFillColor: other.webkitTextFillColor ?? webkitTextFillColor,
      userSelect: other.userSelect ?? userSelect,
      listStyle: other.listStyle ?? listStyle,
      outline: other.outline ?? outline,
      content: other.content ?? content,
      overflowX: other.overflowX ?? overflowX,
      overflowY: other.overflowY ?? overflowY,
      extra: _mergeExtra(extra, other.extra),
    );
  }

  /// Create a copy with selected fields replaced.
  CssStyle copyWith({
    Display? display,
    Position? position,
    BoxSizing? boxSizing,
    Visibility? visibility,
    CssValue? top,
    CssValue? right,
    CssValue? bottom,
    CssValue? left,
    int? zIndex,
    CssValue? width,
    CssValue? height,
    CssValue? minWidth,
    CssValue? minHeight,
    CssValue? maxWidth,
    CssValue? maxHeight,
    Object? padding,
    Object? margin,
    FlexDirection? flexDirection,
    FlexWrap? flexWrap,
    AlignItems? alignItems,
    JustifyContent? justifyContent,
    AlignSelf? alignSelf,
    CssValue? gap,
    CssValue? rowGap,
    CssValue? columnGap,
    num? flex,
    num? flexGrow,
    num? flexShrink,
    CssValue? flexBasis,
    int? order,
    String? gridTemplate,
    String? gridTemplateColumns,
    String? gridTemplateRows,
    String? gridColumn,
    String? gridRow,
    String? gridArea,
    Object? background,
    Object? color,
    num? opacity,
    Object? border,
    Object? borderRadius,
    Object? boxShadow,
    CssValue? fontSize,
    Object? fontWeight,
    Object? fontStyle,
    String? fontFamily,
    num? lineHeight,
    CssValue? letterSpacing,
    TextAlign? textAlign,
    String? textDecoration,
    TextTransform? textTransform,
    WhiteSpace? whiteSpace,
    TextOverflow? textOverflow,
    String? transform,
    String? transformOrigin,
    String? transition,
    String? animation,
    String? filter,
    String? backdropFilter,
    Cursor? cursor,
    PointerEvents? pointerEvents,
    ObjectFit? objectFit,
    String? backgroundClip,
    String? webkitBackgroundClip,
    String? webkitTextFillColor,
    String? userSelect,
    String? listStyle,
    String? outline,
    String? content,
    Overflow? overflowX,
    Overflow? overflowY,
    Map<String, String>? extra,
  }) =>
      CssStyle(
        display: display ?? this.display,
        position: position ?? this.position,
        boxSizing: boxSizing ?? this.boxSizing,
        visibility: visibility ?? this.visibility,
        top: top ?? this.top,
        right: right ?? this.right,
        bottom: bottom ?? this.bottom,
        left: left ?? this.left,
        zIndex: zIndex ?? this.zIndex,
        width: width ?? this.width,
        height: height ?? this.height,
        minWidth: minWidth ?? this.minWidth,
        minHeight: minHeight ?? this.minHeight,
        maxWidth: maxWidth ?? this.maxWidth,
        maxHeight: maxHeight ?? this.maxHeight,
        padding: padding ?? this.padding,
        margin: margin ?? this.margin,
        flexDirection: flexDirection ?? this.flexDirection,
        flexWrap: flexWrap ?? this.flexWrap,
        alignItems: alignItems ?? this.alignItems,
        justifyContent: justifyContent ?? this.justifyContent,
        alignSelf: alignSelf ?? this.alignSelf,
        gap: gap ?? this.gap,
        rowGap: rowGap ?? this.rowGap,
        columnGap: columnGap ?? this.columnGap,
        flex: flex ?? this.flex,
        flexGrow: flexGrow ?? this.flexGrow,
        flexShrink: flexShrink ?? this.flexShrink,
        flexBasis: flexBasis ?? this.flexBasis,
        order: order ?? this.order,
        gridTemplate: gridTemplate ?? this.gridTemplate,
        gridTemplateColumns: gridTemplateColumns ?? this.gridTemplateColumns,
        gridTemplateRows: gridTemplateRows ?? this.gridTemplateRows,
        gridColumn: gridColumn ?? this.gridColumn,
        gridRow: gridRow ?? this.gridRow,
        gridArea: gridArea ?? this.gridArea,
        background: background ?? this.background,
        color: color ?? this.color,
        opacity: opacity ?? this.opacity,
        border: border ?? this.border,
        borderRadius: borderRadius ?? this.borderRadius,
        boxShadow: boxShadow ?? this.boxShadow,
        fontSize: fontSize ?? this.fontSize,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
        fontFamily: fontFamily ?? this.fontFamily,
        lineHeight: lineHeight ?? this.lineHeight,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        textAlign: textAlign ?? this.textAlign,
        textDecoration: textDecoration ?? this.textDecoration,
        textTransform: textTransform ?? this.textTransform,
        whiteSpace: whiteSpace ?? this.whiteSpace,
        textOverflow: textOverflow ?? this.textOverflow,
        transform: transform ?? this.transform,
        transformOrigin: transformOrigin ?? this.transformOrigin,
        transition: transition ?? this.transition,
        animation: animation ?? this.animation,
        filter: filter ?? this.filter,
        backdropFilter: backdropFilter ?? this.backdropFilter,
        cursor: cursor ?? this.cursor,
        pointerEvents: pointerEvents ?? this.pointerEvents,
        objectFit: objectFit ?? this.objectFit,
        backgroundClip: backgroundClip ?? this.backgroundClip,
        webkitBackgroundClip: webkitBackgroundClip ?? this.webkitBackgroundClip,
        webkitTextFillColor: webkitTextFillColor ?? this.webkitTextFillColor,
        userSelect: userSelect ?? this.userSelect,
        listStyle: listStyle ?? this.listStyle,
        outline: outline ?? this.outline,
        content: content ?? this.content,
        overflowX: overflowX ?? this.overflowX,
        overflowY: overflowY ?? this.overflowY,
        extra: extra ?? this.extra,
      );
}

// ---------------------------------------------------------------------------
// Enum → CSS string converters
// ---------------------------------------------------------------------------

String _displayCss(Display d) => switch (d) {
      Display.none => 'none',
      Display.block => 'block',
      Display.inline => 'inline',
      Display.inlineBlock => 'inline-block',
      Display.flex => 'flex',
      Display.inlineFlex => 'inline-flex',
      Display.grid => 'grid',
      Display.inlineGrid => 'inline-grid',
      Display.contents => 'contents',
    };

String _positionCss(Position p) => switch (p) {
      Position.static_ => 'static',
      Position.relative => 'relative',
      Position.absolute => 'absolute',
      Position.fixed => 'fixed',
      Position.sticky => 'sticky',
    };

String _flexDirectionCss(FlexDirection d) => switch (d) {
      FlexDirection.row => 'row',
      FlexDirection.rowReverse => 'row-reverse',
      FlexDirection.column => 'column',
      FlexDirection.columnReverse => 'column-reverse',
    };

String _flexWrapCss(FlexWrap w) => switch (w) {
      FlexWrap.nowrap => 'nowrap',
      FlexWrap.wrap => 'wrap',
      FlexWrap.wrapReverse => 'wrap-reverse',
    };

String _alignItemsCss(AlignItems a) => switch (a) {
      AlignItems.stretch => 'stretch',
      AlignItems.flexStart => 'flex-start',
      AlignItems.flexEnd => 'flex-end',
      AlignItems.center => 'center',
      AlignItems.baseline => 'baseline',
    };

String _justifyContentCss(JustifyContent j) => switch (j) {
      JustifyContent.flexStart => 'flex-start',
      JustifyContent.flexEnd => 'flex-end',
      JustifyContent.center => 'center',
      JustifyContent.spaceBetween => 'space-between',
      JustifyContent.spaceAround => 'space-around',
      JustifyContent.spaceEvenly => 'space-evenly',
    };

String _alignSelfCss(AlignSelf a) => switch (a) {
      AlignSelf.auto_ => 'auto',
      AlignSelf.stretch => 'stretch',
      AlignSelf.flexStart => 'flex-start',
      AlignSelf.flexEnd => 'flex-end',
      AlignSelf.center => 'center',
      AlignSelf.baseline => 'baseline',
    };

String _overflowCss(Overflow o) => switch (o) {
      Overflow.visible => 'visible',
      Overflow.hidden => 'hidden',
      Overflow.scroll => 'scroll',
      Overflow.auto_ => 'auto',
    };

String _cursorCss(Cursor c) => switch (c) {
      Cursor.pointer => 'pointer',
      Cursor.default_ => 'default',
      Cursor.text => 'text',
      Cursor.move => 'move',
      Cursor.grab => 'grab',
      Cursor.grabbing => 'grabbing',
      Cursor.notAllowed => 'not-allowed',
      Cursor.none => 'none',
      Cursor.crosshair => 'crosshair',
      Cursor.help => 'help',
      Cursor.wait => 'wait',
    };

String _boxSizingCss(BoxSizing b) => switch (b) {
      BoxSizing.contentBox => 'content-box',
      BoxSizing.borderBox => 'border-box',
    };

String _visibilityCss(Visibility v) => switch (v) {
      Visibility.visible => 'visible',
      Visibility.hidden => 'hidden',
      Visibility.collapse => 'collapse',
    };

String _whiteSpaceCss(WhiteSpace w) => switch (w) {
      WhiteSpace.normal => 'normal',
      WhiteSpace.nowrap => 'nowrap',
      WhiteSpace.pre => 'pre',
      WhiteSpace.preWrap => 'pre-wrap',
      WhiteSpace.preLine => 'pre-line',
    };

String _textTransformCss(TextTransform t) => switch (t) {
      TextTransform.none => 'none',
      TextTransform.uppercase => 'uppercase',
      TextTransform.lowercase => 'lowercase',
      TextTransform.capitalize => 'capitalize',
    };

String _objectFitCss(ObjectFit o) => switch (o) {
      ObjectFit.fill => 'fill',
      ObjectFit.contain => 'contain',
      ObjectFit.cover => 'cover',
      ObjectFit.none => 'none',
      ObjectFit.scaleDown => 'scale-down',
    };

String _pointerEventsCss(PointerEvents p) => switch (p) {
      PointerEvents.auto_ => 'auto',
      PointerEvents.none => 'none',
    };

// ---------------------------------------------------------------------------
// Multi-type converters
// ---------------------------------------------------------------------------

String _colorOrString(Object v) {
  if (v is Color) return v.toCss();
  return v.toString();
}

String _spacingCss(Object v) {
  if (v is EdgeInsets) return v.toCss();
  if (v is CssValue) return v.toCss();
  return v.toString();
}

String _borderCss(Object v) {
  if (v is Border) return v.toCss();
  return v.toString();
}

String _borderRadiusCss(Object v) {
  if (v is BorderRadius) return v.toCss();
  if (v is CssValue) return v.toCss();
  return v.toString();
}

String _boxShadowCss(Object v) {
  if (v is List<BoxShadow>) return v.map((s) => s.toCss()).join(', ');
  return v.toString();
}

String _fontWeightCss(Object v) {
  if (v is FontWeight) {
    return switch (v) {
      FontWeight.w100 => '100',
      FontWeight.w200 => '200',
      FontWeight.w300 => '300',
      FontWeight.normal => '400',
      FontWeight.w500 => '500',
      FontWeight.w600 => '600',
      FontWeight.bold => '700',
      FontWeight.w800 => '800',
      FontWeight.w900 => '900',
    };
  }
  return v.toString();
}

String _fontStyleCss(Object v) {
  if (v is FontStyle) {
    return v == FontStyle.italic ? 'italic' : 'normal';
  }
  return v.toString();
}

Map<String, String>? _mergeExtra(
    Map<String, String>? a, Map<String, String>? b) {
  if (a == null) return b;
  if (b == null) return a;
  return {...a, ...b};
}
