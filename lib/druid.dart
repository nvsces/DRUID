/// druid — Dart UI Toolkit
///
/// A lightweight web UI framework with Virtual DOM and Signals reactivity.
///
/// ```dart
/// import 'package:druid/druid.dart';
///
/// class Counter extends StatefulWidget {
///   @override
///   State<Counter> createState() => _CounterState();
/// }
///
/// class _CounterState extends State<Counter> {
///   late final count = signal(0);
///
///   @override
///   Widget build(BuildContext context) => Div(children: [
///     H1(child: Text('Count: ${count.value}')),
///     Button(onClick: (_) => count.value++, child: Text('+')),
///   ]);
/// }
///
/// void main() => runApp(Counter());
/// ```
library druid;

// Core reactivity
export 'src/core/signal.dart' show Signal, Computed, Effect, signal, computed, effect;
export 'src/core/scheduler.dart' show batch;

// Virtual DOM (exposed for advanced use)
export 'src/vdom/vnode.dart' show VNode, VElement, VText, EventHandler;
export 'src/vdom/differ.dart'
    show
        Patch,
        PatchReplace,
        PatchText,
        PatchSetProp,
        PatchRemoveProp,
        PatchInsertChild,
        PatchRemoveChild,
        PatchMoveChild,
        PatchChild,
        diff;
export 'src/vdom/patcher.dart' show mount, applyPatches;

// Widget model
export 'src/widgets/widget.dart' show Widget, StatelessWidget, StatefulWidget, State;
export 'src/widgets/context.dart' show BuildContext;
export 'src/widgets/text.dart' show Text;

// HTML widgets
export 'src/widgets/html.dart'
    show
        // Block
        Div, Span, Section, Article, Header, Footer, Main, Nav,
        // Headings
        H1, H2, H3, H4,
        // Text / inline
        P, Strong, Em, Small, Code, Pre, Hr, Br,
        // Interactive
        Button, Input, Textarea, Select, Option,
        // Form
        Form, Label,
        // Lists
        Ul, Ol, Li,
        // Media / links
        A, Img,
        // Table
        Table, Thead, Tbody, Tr, Th, Td,
        // Flutter-like container
        Container,
        // Gesture / event wrapper
        GestureDetector;

// Style system
export 'src/widgets/style.dart'
    show
        EdgeInsets,
        BorderRadius,
        Border,
        BoxShadow,
        BoxDecoration,
        TextStyle,
        FontWeight,
        FontStyle,
        TextAlign,
        TextOverflow,
        StyledText;

// CSS typed style
export 'src/widgets/css_units.dart'
    show CssValue, Px, Percent, Rem, CssEm, Vw, Vh, Auto, CssRaw;
export 'src/widgets/css_style.dart'
    show
        CssStyle,
        Display,
        Position,
        FlexDirection,
        FlexWrap,
        AlignItems,
        JustifyContent,
        AlignSelf,
        Overflow,
        Cursor,
        BoxSizing,
        Visibility,
        WhiteSpace,
        TextTransform,
        ObjectFit,
        PointerEvents;

// App entry point
export 'src/app.dart' show runApp;

// Utilities
export 'src/utils/stylesheet.dart'
    show
        injectStyleSheet,
        CssRule,
        StyleSheet,
        StyleRule,
        Keyframes,
        MediaQuery;

// Animation system
export 'src/animation/animation.dart' show HasAnimationValue;
export 'src/animation/curves.dart' show Curve, CurvedAnimation, Curves;
export 'src/animation/ticker.dart' show Ticker, TickCallback, TickerProvider, SingleTickerProviderMixin, MultiTickerProvider;
export 'src/animation/animation_controller.dart' show AnimationController, AnimationStatus;
export 'src/animation/tween.dart' show Tween, TweenAnimation, IntTween, DoubleTween;
export 'src/animation/animated_builder.dart' show AnimatedBuilder;

// Color
export 'src/core/color.dart' show Color;

// Theme
export 'src/theme/theme_data.dart' show ThemeData, ColorScheme, TextTheme;
export 'src/theme/theme.dart' show Theme;

// Bloc state management
export 'src/bloc/bloc.dart' show Bloc;
export 'src/bloc/bloc_provider.dart' show BlocProvider, BlocBuilder;

// Navigation / Routing
export 'src/navigation/route.dart'
    show RouteDefinition, RouteMatch, RouteGuard, RouteBuilder, matchRoute, parseQueryParams, extractPath;
export 'src/navigation/router_controller.dart' show RouterController;
export 'src/navigation/router_provider.dart' show RouterProvider;
export 'src/navigation/router.dart' show RouterOutlet, NestedRouterOutlet;
export 'src/navigation/link.dart' show Link;
