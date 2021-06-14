import 'dart:ui' as ui
    show
        ParagraphStyle,
        TextStyle,
        Shadow,
        FontFeature,
        TextHeightBehavior,
        TextLeadingDistribution;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////

extension TextStyleExtension on TextStyle {
  //

  /// You can create a [TextStyle] by adding the [TextStyle] to one these types:
  /// [Color], [FontFamily], [FontSize], [FontWeight], [FontStyle], [TextBaseline], [Locale],
  /// [Shadows], [FontFeatures], [Decoration], or [DecorationStyle], or [DecorationStyle].
  ///
  /// For example:
  ///
  /// ```
  /// Text('Hello', style: TextStyle(fontSize: 14.0) + "Roboto" + Colors.red + FontStyle.italic);
  /// ```
  ///
  /// Note: If you add null, that's not an error. It will simply return the same TextStyle.
  /// However, if you add an invalid type it will throw an error in RUN TIME.
  ///
  TextStyle operator +(Object? obj) => //
      (obj == null)
          ? this
          : copyWith(
              color: obj is Color ? obj : null,
              fontFamily: obj is String ? obj : null,
              fontSize: obj is FontSize ? obj.fontSize : null,
              fontWeight: obj is FontWeight ? obj : null,
              fontStyle: obj is FontStyle ? obj : null,
              textBaseline: obj is TextBaseline ? obj : null,
              locale: obj is Locale ? obj : null,
              shadows: obj is List<ui.Shadow> ? obj : null,
              fontFeatures: obj is List<ui.FontFeature> ? obj : null,
              decoration: obj is TextDecoration ? obj : null,
              decorationStyle: obj is TextDecorationStyle ? obj : null,
              height: obj is TextHeight ? obj.height : null,
            );

  /// You can create a [TextStyle] by adding the [TextStyle] to one these types:
  /// [Color], [FontFamily], [FontSize], [FontWeight], [FontStyle], [TextBaseline], [Locale],
  /// [Shadows], [FontFeatures], [Decoration], or [DecorationStyle], or [DecorationStyle].
  ///
  /// For example:
  ///
  /// ```
  /// Text('Hello', style: TextStyle(fontSize: 14.0) + "Roboto" + Colors.red + FontStyle.italic);
  /// ```
  ///
  /// Note: If you add null, that's not an error. It will simply return the same TextStyle.
  /// However, if you add an invalid type it will throw an error in RUN TIME.
  ///
  TextStyle add(Object? obj, {bool apply = true}) => (apply) ? this + obj : this;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class TextHeight {
  double height;

  TextHeight(this.height);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class FontSize {
  double fontSize;

  FontSize(this.fontSize);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

abstract class ThemeRef {}

////////////////////////////////////////////////////////////////////////////////////////////////////

/// The current theme overrides the default theme. If a value is present in the current theme, it
/// will be used. If not, the value from the default theme will be used instead. For this reason,
/// the current theme doesn't need to have all values, but only the ones you want to change from
/// the default.
///
Map<ThemeRef, Object> _currentTheme = const {};

/// The default theme usually defines all value, or is left empty.
/// If a value is not present in the current theme and also not present in the default theme,
/// the default value will be used instead Note the default value is optional, and it's defined
/// when the value is created. For example:
/// `static const errorColor = ColorRef('errorColor',  Color(0xFFCA2323));`
///
Map<ThemeRef, Object> _defaultTheme = const {};

Color Function(Color)? _transformColor;

TextStyle Function(TextStyle)? _transformTextStyle;

/// Removes the current theme, falling back to the default theme.
void _clearCurrentTheme() {
  _currentTheme = {};
}

/// Returns true if the given theme is equal to the current one.
/// Note: To check if the default them is being used, do: `ifThemeIs({})`.
bool _ifCurrentThemeIs(Map<ThemeRef, Object> theme) => mapEquals(theme, _currentTheme);

/// Sets a transform which will be applied to all colors.
void _setTransformColor(Color Function(Color)? transform) {
  _transformColor = transform;
}

/// Returns true if the given color transform is equal to the current one.
bool _ifCurrentTransformColorIs(Color Function(Color)? transform) =>
    identical(transform, _transformColor);

/// Sets a transform which will be applied to all colors.
void _setTransformTextStyle(TextStyle Function(TextStyle)? transform) {
  _transformTextStyle = transform;
}

/// Returns true if the given text style transform is equal to the current one.
bool _ifCurrentTransformTextStyleIs(TextStyle Function(TextStyle)? transform) =>
    identical(transform, _transformTextStyle);

////////////////////////////////////////////////////////////////////////////////////////////////////

/// Instead of:
///
/// Container(
///    color: Theme.of(context).warningColor,
///    child: Text("hello!", style: Theme.of(context).titleTextStyle,
/// );
///
/// You can write:
///
/// Container(
///    color: const AppColor.warning,
///    child: Text("hello!", style: const AppStyle.title,
/// );
///
/// Wrap your widget tree with the `Themed` widget.
/// Note, there must at most one single `Themed` widget in the tree.
///
/// ```dart
/// import 'package:kolor_theme/kolor_theme.dart';
///
/// @override
/// Widget build(BuildContext context) {
///   return Themed(
///       child: Scaffold( ... )
///   );
/// }
/// ```
///
/// You can provide a default theme theme, like this:
///
/// ```dart
/// return Themed(
///     defaultTheme: { ... },
///     child: Scaffold( ... )
/// ```
///
class Themed extends StatefulWidget {
  //
  static final _themedKey = GlobalKey<_ThemedState>();

  final Widget child;

  /// The [Themed] widget should wrap the [child] which contains the tree of
  /// widgets you want to use the color theme. It' recommended that you provide a
  /// [defaultTheme].
  ///
  Themed({
    Key? key,
    Map<ThemeRef, Object> defaultTheme = const {},
    Map<ThemeRef, Object>? currentTheme,
    required this.child,
  }) : super(key: _themedKey) {
    _defaultTheme = defaultTheme;
    if (currentTheme != null) _currentTheme = currentTheme;
  }

  /// Same as `Themed.of(context).theme = { ... };`
  ///
  /// The current theme overrides the default theme. If a color is present in the current theme, it
  /// will be used. If not, the color from the default theme will be used instead. For this reason,
  /// the current theme doesn't need to have all the colors, but only the ones you want to change
  /// from the default.
  static set currentTheme(Map<ThemeRef, Object>? currentTheme) {
    _currentTheme = currentTheme ?? {};
    // _themedKey.currentState?._rebuildAllChildren();
    _themedKey.currentState?.setState(() {});
  }

  /// Same as `Themed.of(context).clearTheme();`
  ///
  /// Removes the current theme, falling back to the default theme
  static void clearCurrentTheme() {
    _clearCurrentTheme();
    // _themedKey.currentState?._rebuildAllChildren();
    _themedKey.currentState?.setState(() {});
  }

  /// Same as `Themed.of(context).defaultTheme = { ... };`
  ///
  /// The default theme must define all used colors.
  static set defaultTheme(Map<ThemeRef, Object> defaultTheme) {
    _defaultTheme = defaultTheme;
    // _themedKey.currentState?._rebuildAllChildren();
    _themedKey.currentState?.setState(() {});
  }

  /// Same as `Themed.of(context).transformColor = ...;`
  ///
  /// Sets a transform which will be applied to all colors.
  static set transformColor(Color Function(Color)? transform) {
    print('---------- Themed.transformColor ----------\n\n');
    print('\n');
    _setTransformColor(transform);
    // _themedKey.currentState?._rebuildAllChildren();
    _themedKey.currentState?.setState(() {});
  }

  /// Same as `Themed.of(context).clearTransformColor();`
  ///
  /// Removes the current color transform.
  static void clearTransformColor() {
    transformColor = null;
  }

  /// Same as `Themed.of(context).transformTextStyle = ...;`
  ///
  /// Sets a transform which will be applied to all text styles. For example:
  ///
  /// ```
  /// Themed.transformTextStyle = (TextStyle style) =>
  ///    (style.fontSize == null)
  ///        ? style
  ///        : style.copyWith(fontSize: style.fontSize! * 1.20);
  /// ```
  static set transformTextStyle(TextStyle Function(TextStyle)? transform) {
    _setTransformTextStyle(transform);
    // _themedKey.currentState?._rebuildAllChildren();
    _themedKey.currentState?.setState(() {});
  }

  /// Same as `Themed.of(context).clearTransformTextStyle();`
  ///
  /// Removes the current text style transform.
  static void clearTransformTextStyle() {
    transformTextStyle = null;
  }

  /// Returns true if the given theme is equal to the current one.
  /// Note: To check if the default them is being used, do: `ifThemeIs({})`.
  static bool ifCurrentThemeIs(Map<ThemeRef, Object> theme) => _ifCurrentThemeIs(theme);

  /// Same as `Themed.ifCurrentTransformColorIs( ... )`.
  ///
  /// Returns true if the given color transform is equal to the current one.
  static bool ifCurrentTransformColorIs(Color Function(Color)? transform) =>
      _ifCurrentTransformColorIs(transform);

  /// Same as `Themed.ifCurrentTransformTextStyleIs( ... )`.
  ///
  /// Returns true if the given text style transform is equal to the current one.
  static bool ifCurrentTransformTextStyleIs(TextStyle Function(TextStyle)? transform) =>
      _ifCurrentTransformTextStyleIs(transform);

  /// Getter:
  /// print(Themed.of(context).theme);
  ///
  /// Setter:
  /// Themed.of(context).theme = Locale("en", "US");
  ///
  static _ThemedState of(BuildContext context) {
    _InheritedConstTheme? inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedConstTheme>();

    if (inherited == null)
      throw ConstThemeException("Can't find the `Themed` widget up in the tree. "
          "Please make sure to wrap some ancestor widget with `Themed`.");

    return inherited.data;
  }

  @override
  _ThemedState createState() => _ThemedState();
}

// /////////////////////////////////////////////////////////////////////////////

class _ThemedState extends State<Themed> {
  //
  /// To change the current theme:
  ///
  ///     Themed.of(context).currentTheme = { ... };
  ///
  /// Same as `Themed.currentTheme = { ... }`.
  ///
  /// The current theme overrides the default theme. If a color is present in the current theme, it
  /// will be used. If not, the color from the default theme will be used instead. For this reason,
  /// the current theme doesn't need to have all the colors, but only the ones you want to change
  /// from the default.
  ///
  set currentTheme(Map<ThemeRef, Object> currentTheme) {
    if (mounted)
      setState(() {
        _currentTheme = currentTheme;
        _rebuildAllChildren();
      });
  }

  /// Same as `Themed.defaultTheme = { ... }`.
  ///
  /// The default theme must define all used colors.
  set defaultTheme(Map<ThemeRef, Object> defaultTheme) {
    if (mounted)
      setState(() {
        _defaultTheme = defaultTheme;
        _rebuildAllChildren();
      });
  }

  /// Same as `Themed.transformColor = ...`.
  ///
  /// Sets a transform which will be applied to all colors.
  set transformColor(Color Function(Color)? transform) {
    if (mounted)
      setState(() {
        _setTransformColor(transform);
        _rebuildAllChildren();
      });
  }

  /// Same as `Themed.transformTextStyle = ...`.
  ///
  /// Sets a transform which will be applied to all text styles.
  set transformTextStyle(TextStyle Function(TextStyle)? transform) {
    if (mounted)
      setState(() {
        _setTransformTextStyle(transform);
        _rebuildAllChildren();
      });
  }

  /// Same as `Themed.ifCurrentThemeIs( ... )`.
  ///
  /// Returns true if the given theme is equal to the current one.
  /// Note: To check if the default them is being used, do: `ifThemeIs({})`.
  bool ifCurrentThemeIs(Map<ThemeRef, Object> theme) => _ifCurrentThemeIs(theme);

  /// Same as `Themed.clearCurrentTheme();`.
  ///
  /// Removes the current theme, falling back to the default theme.
  void clearCurrentTheme() {
    if (mounted)
      setState(() {
        _clearCurrentTheme();
        _rebuildAllChildren();
      });
  }

  /// Same as `Themed.ifCurrentTransformColorIs( ... )`.
  ///
  /// Returns true if the given color transform is equal to the current one.
  bool ifCurrentTransformColorIs(Color Function(Color)? transform) =>
      _ifCurrentTransformColorIs(transform);

  /// Same as `Themed.ifCurrentTransformTextStyleIs( ... )`.
  ///
  /// Returns true if the given text style transform is equal to the current one.
  bool ifCurrentTransformTextStyleIs(TextStyle Function(TextStyle)? transform) =>
      _ifCurrentTransformTextStyleIs(transform);

  @override
  Widget build(BuildContext context) {
    // print('---------- _ThemedState.build ----------1\n\n');
    // print('---------- _ThemedState.build ----------2\n\n');
    _rebuildAllChildrenX();

    return _InheritedConstTheme(
      data: this,
      child: widget.child,
    );
  }

  /// See: https://stackoverflow.com/a/58513635/3411681
  void _rebuildAllChildren() {
    // print('---------- _ThemedState._rebuildAllChildren ----------1\n\n');
    // print('---------- _ThemedState._rebuildAllChildren ----------2\n\n');
    // void rebuild(Element el) {
    //   el.markNeedsBuild();
    //   el.visitChildren(rebuild);
    // }
    //
    // (context as Element).visitChildren(rebuild);
    //
    // WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {}));
  }

  /// See: https://stackoverflow.com/a/58513635/3411681
  void _rebuildAllChildrenX() {
    // print('---------- _ThemedState._rebuildAllChildren ----------1\n\n');
    // print('---------- _ThemedState._rebuildAllChildren ----------2\n\n');
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);

    // setState(() {});
    // WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {}));
  }
}

// /////////////////////////////////////////////////////////////////////////////

class _InheritedConstTheme extends InheritedWidget {
  //
  final _ThemedState data;

  _InheritedConstTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedConstTheme old) => true;
}

// /////////////////////////////////////////////////////////////////////////////

class ConstThemeException {
  String msg;

  ConstThemeException(this.msg);

  @override
  String toString() => msg;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConstThemeException && runtimeType == other.runtimeType && msg == other.msg;

  @override
  int get hashCode => msg.hashCode;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class ColorRef extends Color implements ThemeRef {
  //
  final String ref;

  final Color? color;

  const ColorRef(this.ref, [this.color]) : super(0);

  /// Transform that removes the colors, leaving only shades of gray.
  /// Use it like this: `KolorTheme.setTransform(ColorRef.shadesOfGrey);`
  static Color shadesOfGreyTransform(Color color) {
    int average = (color.red + color.green + color.blue) ~/ 3;
    return Color.fromARGB(color.alpha, average, average, average);
  }

  @override
  int get value {
    Color? result = _currentTheme[this] as Color?;
    result ??= _defaultTheme[this] as Color?;
    result ??= color;
    if (result == null) throw ConstThemeException('Theme color "$ref" is not defined.');
    if (_transformColor != null) result = _transformColor!(result);
    return result.value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && other is ColorRef && runtimeType == other.runtimeType && ref == other.ref;

  @override
  int get hashCode => ref.hashCode;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class TextStyleRef implements TextStyle, ThemeRef {
  //
  final String ref;
  final TextStyle? textStyle;

  const TextStyleRef(this.ref, [this.textStyle]) : super();

  TextStyle get _ts {
    TextStyle? result = _currentTheme[this] as TextStyle?;
    result ??= _defaultTheme[this] as TextStyle?;
    result ??= textStyle;
    if (result == null) throw ConstThemeException('Theme text-style "$ref" is not defined.');
    if (_transformTextStyle != null) result = _transformTextStyle!(result);
    return result;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is TextStyleRef &&
          runtimeType == other.runtimeType &&
          ref == other.ref;

  @override
  int get hashCode => ref.hashCode;

  @override
  TextStyle apply({
    Color? color,
    Color? backgroundColor,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double decorationThicknessFactor = 1.0,
    double decorationThicknessDelta = 0.0,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    double fontSizeFactor = 1.0,
    double fontSizeDelta = 0.0,
    int fontWeightDelta = 0,
    FontStyle? fontStyle,
    double letterSpacingFactor = 1.0,
    double letterSpacingDelta = 0.0,
    double wordSpacingFactor = 1.0,
    double wordSpacingDelta = 0.0,
    double heightFactor = 1.0,
    double heightDelta = 0.0,
    TextBaseline? textBaseline,
    ui.TextLeadingDistribution? leadingDistribution,
    Locale? locale,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
  }) {
    return _ts.apply(
      color: color,
      backgroundColor: backgroundColor,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThicknessFactor: decorationThicknessFactor,
      decorationThicknessDelta: decorationThicknessDelta,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      fontWeightDelta: fontWeightDelta,
      fontStyle: fontStyle,
      letterSpacingFactor: letterSpacingFactor,
      letterSpacingDelta: letterSpacingDelta,
      wordSpacingFactor: wordSpacingFactor,
      wordSpacingDelta: wordSpacingDelta,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      textBaseline: textBaseline,
      leadingDistribution: leadingDistribution,
      locale: locale,
      shadows: shadows,
      fontFeatures: fontFeatures,
    );
  }

  @override
  Paint? get background => _ts.background;

  @override
  Color? get backgroundColor => _ts.backgroundColor;

  @override
  Color? get color => _ts.color;

  @override
  RenderComparison compareTo(TextStyle other) {
    return _ts.compareTo(other);
  }

  @override
  TextStyle copyWith({
    bool? inherit,
    Color? color,
    Color? backgroundColor,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    ui.TextLeadingDistribution? leadingDistribution,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? debugLabel,
  }) {
    return _ts.copyWith(
      inherit: inherit,
      color: color,
      backgroundColor: backgroundColor,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      leadingDistribution: leadingDistribution,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      debugLabel: debugLabel,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties, {String prefix = ''}) {
    _ts.debugFillProperties(properties, prefix: prefix);
  }

  @override
  String? get debugLabel => _ts.debugLabel;

  @override
  TextDecoration? get decoration => _ts.decoration;

  @override
  Color? get decorationColor => _ts.decorationColor;

  @override
  TextDecorationStyle? get decorationStyle => _ts.decorationStyle;

  @override
  double? get decorationThickness => _ts.decorationThickness;

  @override
  String? get fontFamily => _ts.fontFamily;

  @override
  List<String>? get fontFamilyFallback => _ts.fontFamilyFallback;

  @override
  List<ui.FontFeature>? get fontFeatures => _ts.fontFeatures;

  @override
  double? get fontSize => _ts.fontSize;

  @override
  FontStyle? get fontStyle => _ts.fontStyle;

  @override
  FontWeight? get fontWeight => _ts.fontWeight;

  @override
  Paint? get foreground => _ts.foreground;

  @override
  ui.ParagraphStyle getParagraphStyle({
    TextAlign? textAlign,
    TextDirection? textDirection,
    double textScaleFactor = 1.0,
    String? ellipsis,
    int? maxLines,
    ui.TextHeightBehavior? textHeightBehavior,
    Locale? locale,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? height,
    StrutStyle? strutStyle,
  }) {
    return _ts.getParagraphStyle(
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      ellipsis: ellipsis,
      maxLines: maxLines,
      textHeightBehavior: textHeightBehavior,
      locale: locale,
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      strutStyle: strutStyle,
    );
  }

  @override
  ui.TextStyle getTextStyle({double textScaleFactor = 1.0}) =>
      _ts.getTextStyle(textScaleFactor: textScaleFactor);

  @override
  double? get height => _ts.height;

  @override
  bool get inherit => _ts.inherit;

  @override
  ui.TextLeadingDistribution? get leadingDistribution => _ts.leadingDistribution;

  @override
  double? get letterSpacing => _ts.letterSpacing;

  @override
  Locale? get locale => _ts.locale;

  @override
  TextStyle merge(TextStyle? other) => _ts.merge(other);

  @override
  List<ui.Shadow>? get shadows => _ts.shadows;

  @override
  TextBaseline? get textBaseline => _ts.textBaseline;

  @override
  DiagnosticsNode toDiagnosticsNode({String? name, DiagnosticsTreeStyle? style}) =>
      _ts.toDiagnosticsNode(name: name, style: style);

  @override
  String toStringShort() => _ts.toStringShort();

  @override
  double? get wordSpacing => _ts.wordSpacing;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

/// You can create color swatches from colors only (which you can later change):
///
/// ```
/// static const MaterialColor myColorSwatch = MaterialColorRef(
///     AppColors.primary,
///     <int, Color>{
///       50: AppColors.primary,
///       100: AppColors.primary,
///       200: AppColors.primary,
///       300: AppColors.primary,
///       400: AppColors.primary,
///       500: AppColors.primary,
///       600: AppColors.primary,
///       700: AppColors.primary,
///       800: AppColors.primary,
///       900: AppColors.primary,
///     },
/// );
/// ```
class MaterialColorSwatch extends MaterialColor {
  final Color primary;

  const MaterialColorSwatch(this.primary, Map<int, Color> swatch) : super(0, swatch);

  @override
  int get value => primary.value;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

/// You can create color swatches from colors only (which you can later change):
///
/// ```
/// static const MaterialColor myColorSwatch = MaterialAccentColorSwatch(
///     AppColors.primary,
///     <int, Color>{
///       50: AppColors.primary,
///       100: AppColors.primary,
///       200: AppColors.primary,
///       400: AppColors.primary,
///       700: AppColors.primary,
///     },
/// );
/// ```
class MaterialAccentColorSwatch extends MaterialAccentColor {
  final Color primary;

  const MaterialAccentColorSwatch(this.primary, Map<int, Color> swatch) : super(0, swatch);

  @override
  int get value => primary.value;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
