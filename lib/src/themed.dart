// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui
    show
        ParagraphStyle,
        TextStyle,
        Shadow,
        FontFeature,
        TextHeightBehavior,
        TextLeadingDistribution,
        FontVariation;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:themed/src/const_theme_exception.dart';

abstract class ThemeRef {}

/// You must have a single [Themed] widget in your widget tree, above
/// your [MaterialApp] or [CupertinoApp] widgets:
///
/// ```dart
/// import 'package:themed/themed.dart';
///
/// Widget build(BuildContext context) {
///   return Themed(
///       child: MaterialApp(...)
///   );
/// }
/// ```
///
/// You may, or may not, also provide a [defaultTheme] and a [currentTheme]:
///
/// ```dart
/// Widget build(BuildContext context) {
///   return Themed(
///       defaultTheme: { ... },
///       currentTheme: { ... },
///       child:
///   );
/// }
/// ```
///
///  # Usage
///
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
class Themed extends StatefulWidget {
  //
  static final _themedKey = GlobalKey<_ThemedState>();

  final Widget child;

  /// Saved themes.
  static final Map<Object, Map<ThemeRef, Object>> _saved = {};
  static Object? _delayedThemeChangeByKey;

  /// You must have a single [Themed] widget in your widget tree, above
  /// your [MaterialApp] or [CupertinoApp] widgets:
  ///
  /// ```dart
  /// import 'package:themed/themed.dart';
  ///
  /// Widget build(BuildContext context) {
  ///   return Themed(
  ///       child: MaterialApp(...)
  ///   );
  /// }
  /// ```
  ///
  /// You may, or may not, also provide a [defaultTheme] and a [currentTheme]:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return Themed(
  ///       defaultTheme: { ... },
  ///       currentTheme: { ... },
  ///       child: ...
  ///   );
  /// }
  /// ```
  ///
  ///  # Usage
  ///
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
  Themed({
    Map<ThemeRef, Object>? defaultTheme,
    Map<ThemeRef, Object>? currentTheme,
    required this.child,
  }) : super(key: _themedKey) {
    if (defaultTheme != null) _defaultTheme = _toIdenticalKeyedMap(defaultTheme);
    if (currentTheme != null) _currentTheme = _toIdenticalKeyedMap(currentTheme);
  }

  /// Calling [Themed.reset] will remove the entire widget tree inside [Themed] for one
  /// frame, and then restore it, rebuilding everything. This can be helpful when some
  /// widgets are not responding to theme changes. This is a brute-force method, and it's
  /// not necessary in all cases.
  /// A side effect is that the all stateful widgets below [Themed] will be recreated,
  /// and their state reset by calling their `initState()` method. This means you should
  /// only use this method if you don't mind loosing all this state, or if you have
  /// mechanisms to recover it, like for example having the state come from above
  /// the [Themed] widget.
  static void reset() {
    var homepageState = _themedKey.currentState;
    homepageState?._reset();
  }

  static void _setState() {
    _themedKey.currentState?.setState(() {}); // ignore: invalid_use_of_protected_member

    var context = _themedKey.currentContext;
    if (context != null) _rebuildAllChildrenOfContext(context);
  }

  /// Same as `Themed.of(context).currentTheme = { ... };`
  ///
  /// The current theme overrides the default theme. If a color is present in the current theme, it
  /// will be used. If not, the color from the default theme will be used instead. For this reason,
  /// the current theme doesn't need to have all the colors, but only the ones you want to change
  /// from the default.
  static set currentTheme(Map<ThemeRef, Object>? currentTheme) {
    _delayedThemeChangeByKey = null;
    _currentTheme = _toIdenticalKeyedMap(currentTheme);
    _setState();
  }

  /// Same as `Themed.of(context).clearTheme();`
  ///
  /// Removes the current theme, falling back to the default theme
  static void clearCurrentTheme() {
    _clearCurrentTheme();
    _setState();
  }

  /// Same as `Themed.of(context).defaultTheme = { ... };`
  ///
  /// The default theme must define all used colors.
  static set defaultTheme(Map<ThemeRef, Object>? defaultTheme) {
    _defaultTheme = _toIdenticalKeyedMap(defaultTheme);
    _setState();
  }

  /// Saves a [theme] with a [key].
  /// See [setThemeByKey] to understand how to use the saved theme.
  ///
  static void save({required Object key, required Map<ThemeRef, Object> theme}) {
    _saved[key] = theme;
    if (_delayedThemeChangeByKey == key) {
      _delayedThemeChangeByKey = null;
      currentTheme = theme;
    }
  }

  /// Saves a map of themes by key. Example:
  ///
  /// ```
  /// final Map<Key, Map<ThemeRef, Object>> myThemes = {
  ///   Keys.light: lightTheme,
  ///   Keys.dark: darkTheme,
  /// };
  ///
  /// Themed.saveAll(myThemes);
  /// ```
  ///
  /// See [setThemeByKey] to understand how to use the saved themes.
  ///
  static void saveAll(Map<dynamic, Map<ThemeRef, Object>> themesByKey) {
    themesByKey.forEach((key, value) => Themed.save(key: key, theme: value));
  }

  /// If you call [setThemeByKey] with a [key], and a theme was previously saved with that [key]
  /// (by using the [save] method), then the current theme will immediately change into that theme.
  ///
  /// However, if a theme was NOT previously saved with that [key], then the current theme will
  /// not change immediately, but may change later, as soon as you save a theme with that [key].
  ///
  /// In other words, you can first save a them then set it,
  /// or you can first set it and then save it.
  ///
  static void setThemeByKey(Object key) {
    var theme = _saved[key];
    if (theme == null)
      _delayedThemeChangeByKey = key;
    else {
      _delayedThemeChangeByKey = null;
      currentTheme = _saved[key];
    }
  }

  /// Removes all saved themes.
  /// Or, to remove just a specific saved theme, pass its [key].
  /// Note: This will not change the current theme.
  static void clearSavedThemeByKey([Object? key]) {
    if (key != null) {
      _saved.remove(key);
      if (_delayedThemeChangeByKey == key) _delayedThemeChangeByKey = null;
    } else {
      _delayedThemeChangeByKey = null;
      _saved.clear();
    }
  }

  /// Sets a transform which will be applied to all colors.
  ///
  /// Same as `Themed.of(context).transformColor = ...;`
  ///
  static set transformColor(Color Function(Color)? transform) {
    _setTransformColor(transform);
    _setState();
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
    _setState();
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

  /// Same as `Themed.ifCurrentTransformColorIs(...)`.
  ///
  /// Returns true if the given color transform is equal to the current one.
  static bool ifCurrentTransformColorIs(Color Function(Color)? transform) =>
      _ifCurrentTransformColorIs(transform);

  /// Same as `Themed.ifCurrentTransformTextStyleIs(...)`.
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
  set currentTheme(Map<ThemeRef, Object>? currentTheme) {
    Themed._delayedThemeChangeByKey = null;
    if (mounted)
      setState(() {
        _currentTheme = _toIdenticalKeyedMap(currentTheme);
        _rebuildAllChildren();
      });
  }

  /// Removes the current theme, falling back to the default theme.
  ///
  ///     Themed.of(context).clearCurrentTheme()
  ///
  /// Same as `Themed.clearCurrentTheme();`.
  ///
  void clearCurrentTheme() {
    if (mounted)
      setState(() {
        _clearCurrentTheme();
        _rebuildAllChildren();
      });
  }

  /// To set the default theme:
  ///
  ///     Themed.of(context).defaultTheme = { ... };
  ///
  /// Same as `Themed.defaultTheme = { ... }`.
  ///
  /// Note the default theme MUST define all used colors.
  ///
  set defaultTheme(Map<ThemeRef, Object>? defaultTheme) {
    if (mounted)
      setState(() {
        _defaultTheme = _toIdenticalKeyedMap(defaultTheme);
        _rebuildAllChildren();
      });
  }

  /// Sets a transform which will be applied to all colors:
  ///
  ///     Themed.of(context).transformColor = ...
  ///
  /// Same as `Themed.transformColor = ...`.
  ///
  set transformColor(Color Function(Color)? transform) {
    if (mounted)
      setState(() {
        _setTransformColor(transform);
        _rebuildAllChildren();
      });
  }

  void clearTransformColor() {
    transformColor = null;
  }

  /// Sets a transform which will be applied to all text styles:
  ///
  ///     Themed.of(context).transformTextStyle = ...
  ///
  /// Same as `Themed.transformTextStyle = ...`.
  ///
  set transformTextStyle(TextStyle Function(TextStyle)? transform) {
    if (mounted)
      setState(() {
        _setTransformTextStyle(transform);
        _rebuildAllChildren();
      });
  }

  void clearTransformTextStyle() {
    transformTextStyle = null;
  }

  /// Returns true if the given theme is equal to the current one.
  /// Note: To check if the default them is being used, do: `ifThemeIs({})`.
  ///
  ///     Themed.of(context).ifCurrentThemeIs({...})
  ///
  /// Same as `Themed.ifCurrentThemeIs(...)`.
  ///
  bool ifCurrentThemeIs(Map<ThemeRef, Object> theme) => _ifCurrentThemeIs(theme);

  /// Returns true if the given color transform is equal to the current one.
  ///
  ///     Themed.of(context).ifCurrentTransformColorIs(...)
  ///
  /// Same as `Themed.ifCurrentTransformColorIs(...)`.
  ///
  bool ifCurrentTransformColorIs(Color Function(Color)? transform) =>
      _ifCurrentTransformColorIs(transform);

  /// Returns true if the given text style transform is equal to the current one.
  ///
  ///     Themed.of(context).ifCurrentTransformTextStyleIs(...)
  ///
  /// Same as `Themed.ifCurrentTransformTextStyleIs(...)`.
  ///
  bool ifCurrentTransformTextStyleIs(TextStyle Function(TextStyle)? transform) =>
      _ifCurrentTransformTextStyleIs(transform);

  bool _isResetting = false;

  void _reset() {
    if (mounted) {
      setState(() {
        _isResetting = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _isResetting = false);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isResetting) {
      return const SizedBox();
    } else {
      return _InheritedConstTheme(
        data: this,
        child: widget.child,
      );
    }
  }

  /// See: https://stackoverflow.com/a/58513635/3411681
  void _rebuildAllChildren() {
    _rebuildAllChildrenOfContext(context);
  }
}

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

class ColorRef extends Color implements ThemeRef {
  //
  final String? id;

  final Color? defaultColor;

  const ColorRef(this.defaultColor, {this.id}) : super(0);

  const ColorRef.fromId(this.id)
      : defaultColor = null,
        super(0);

  /// Transform that removes the colors, leaving only shades of gray.
  /// Use it like this: `Themed.setTransform(ColorRef.shadesOfGrey);`
  static Color shadesOfGreyTransform(Color color) {
    int average = (color.red + color.green + color.blue) ~/ 3;
    return Color.fromARGB(color.alpha, average, average, average);
  }

  Color get color => Color(value);

  /// A 32 bit value representing this color.
  ///
  /// The bits are assigned as follows:
  ///
  /// * Bits 24-31 are the alpha value.
  /// * Bits 16-23 are the red value.
  /// * Bits 8-15 are the green value.
  /// * Bits 0-7 are the blue value.
  @Deprecated('Use component accessors like .r or .g.')
  @override
  int get value {
    Color? result = _currentTheme[this] as Color?;
    result ??= _defaultTheme[this] as Color?;
    result ??= defaultColor;
    if (result == null) throw ConstThemeException('Theme color "$id" is not defined.');
    if (_transformColor != null) result = _transformColor!(result);
    return result.value;
  }

  /// The alpha channel of this color.
  ///
  /// A value of 0.0 means this color is fully transparent. A value of 1.0 means
  /// this color is fully opaque.
  @override
  double get a => ((value >> 24) & 0xFF) / 255.0;

  /// The red channel of this color.
  @override
  double get r {
    return ((value >> 16) & 0xFF) / 255.0;
  }

  /// The green channel of this color.
  @override
  double get g {
    return ((value >> 8) & 0xFF) / 255.0;
  }

  /// The blue channel of this color.
  @override
  double get b {
    return (value & 0xFF) / 255.0;
  }

  @override
  String toString() => 'ColorRef('
      '0x${value.toRadixString(16).padLeft(8, '0')}${id == null ? "" : ", id: $id"}'
      ')';

  /// The equality operator.
  ///
  /// Two [ColorRef]s are equal if they have the same [defaultColor] and [id].
  /// Please note, the current color (that depends on the current theme) is irrelevant.
  ///
  /// To compare by current color (that depends on the current theme), use
  /// method [sameColor] instead.
  ///
  @override
  bool operator ==(Object other) {
    //
    // During theme changes, for one single frame, no color is considered
    // the same as itself. This will make sure all colors rebuild.
    if (identical(this, other))
      return !_rebuilding;
    //
    else
      return super == other &&
          other is ColorRef &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          defaultColor == other.defaultColor;
  }

  /// Return true if [other] is a [ColorRef] or [Color] with the same color as
  /// this one. Note: If [other] is a [ColorRef], the compared color is the current one,
  /// i.e., the one that depend on the current theme.
  ///
  bool sameColor(Object other) {
    return identical(this, other) ||
        (other is ColorRef && value == other.value) ||
        (other is Color && value == other.value);
  }

  @override
  int get hashCode => id.hashCode ^ defaultColor.hashCode;
}

class TextStyleRef extends TextStyle implements ThemeRef {
  //
  final String? id;
  final TextStyle? defaultTextStyle;

  const TextStyleRef(this.defaultTextStyle, {this.id}) : super();

  const TextStyleRef.fromId(this.id)
      : defaultTextStyle = null,
        super();

  TextStyle get textStyle {
    TextStyle? result = _currentTheme[this] as TextStyle?;
    result ??= _defaultTheme[this] as TextStyle?;
    result ??= defaultTextStyle;
    if (result == null)
      throw ConstThemeException('Theme text-style "$id" is not defined.');
    if (_transformTextStyle != null) result = _transformTextStyle!(result);
    return result;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextStyleRef &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          defaultTextStyle == other.defaultTextStyle;

  @override
  int get hashCode => id.hashCode ^ defaultTextStyle.hashCode;

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
    List<ui.FontVariation>? fontVariations,
    String? package,
    TextOverflow? overflow,
  }) {
    return textStyle.apply(
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
      overflow: overflow,
      package: package,
    );
  }

  @override
  Paint? get background => textStyle.background;

  @override
  Color? get backgroundColor => textStyle.backgroundColor;

  @override
  Color? get color => textStyle.color;

  @override
  RenderComparison compareTo(TextStyle other) {
    return textStyle.compareTo(other);
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
    List<ui.FontVariation>? fontVariations,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? debugLabel,
    TextOverflow? overflow,
    String? package,
  }) {
    return textStyle.copyWith(
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
      fontVariations: fontVariations,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      debugLabel: debugLabel,
      overflow: overflow,
      package: package,
    );
  }

  @override
  String? get debugLabel => textStyle.debugLabel;

  @override
  TextDecoration? get decoration => textStyle.decoration;

  @override
  Color? get decorationColor => textStyle.decorationColor;

  @override
  TextDecorationStyle? get decorationStyle => textStyle.decorationStyle;

  @override
  double? get decorationThickness => textStyle.decorationThickness;

  @override
  String? get fontFamily => textStyle.fontFamily;

  @override
  List<String>? get fontFamilyFallback => textStyle.fontFamilyFallback;

  @override
  List<ui.FontFeature>? get fontFeatures => textStyle.fontFeatures;

  @override
  double? get fontSize => textStyle.fontSize;

  @override
  FontStyle? get fontStyle => textStyle.fontStyle;

  @override
  FontWeight? get fontWeight => textStyle.fontWeight;

  @override
  Paint? get foreground => textStyle.foreground;

  @override
  ui.ParagraphStyle getParagraphStyle({
    TextAlign? textAlign,
    TextDirection? textDirection,
    TextScaler textScaler = TextScaler.noScaling,
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
    return textStyle.getParagraphStyle(
      textAlign: textAlign,
      textDirection: textDirection,
      textScaler: textScaler,
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
  ui.TextStyle getTextStyle({
    @Deprecated(
      'Use textScaler instead. '
      'Use of textScaleFactor was deprecated in preparation for the upcoming nonlinear text scaling support. '
      'This feature was deprecated after v3.12.0-2.0.pre.',
    )
    double textScaleFactor = 1.0,
    TextScaler textScaler = TextScaler.noScaling,
  }) =>
      textStyle.getTextStyle(
        textScaleFactor: textScaleFactor,
        textScaler: textScaler,
      );

  @override
  double? get height => textStyle.height;

  @override
  bool get inherit => textStyle.inherit;

  @override
  ui.TextLeadingDistribution? get leadingDistribution => textStyle.leadingDistribution;

  @override
  double? get letterSpacing => textStyle.letterSpacing;

  @override
  Locale? get locale => textStyle.locale;

  @override
  TextStyle merge(TextStyle? other) => textStyle.merge(other);

  @override
  List<ui.Shadow>? get shadows => textStyle.shadows;

  @override
  TextBaseline? get textBaseline => textStyle.textBaseline;

  @override
  DiagnosticsNode toDiagnosticsNode({String? name, DiagnosticsTreeStyle? style}) =>
      textStyle.toDiagnosticsNode(name: name, style: style);

  @override
  String toStringShort() => textStyle.toStringShort();

  @override
  double? get wordSpacing => textStyle.wordSpacing;

  @override
  TextOverflow? get overflow => textStyle.overflow;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    String? result = defaultTextStyle?.toString();
    if (result != null) {
      int pos = result.indexOf('(');
      if (pos == -1) return result;
      result =
          'TextStyleRef(${result.substring(pos + 1, result.length - 1)}${id == null ? "" : ", id: $id"})';
      return result;
    } else
      return 'TextStyleRef(id: ${id == null ? "" : id})';
  }
}

/// The current theme overrides the default theme. If a value is present in the current
/// theme, it will be used. If not, the value from the default theme will be used instead.
/// For this reason, the current theme doesn't need to have all values, but only the ones
/// you want to change from the default.
Map<ThemeRef, Object> _currentTheme = const {};

/// The default theme usually defines all values (colors and text-styles), or is left
/// empty.
///
/// If a value is not present in the current theme and also not present in the default
/// theme, then the DEFAULT VALUE will be used instead. The default value is optional,
/// and is that one defined when the value is created. For example, in
/// `static const errorColor = ColorRef('errorColor',  Color(0xFFCA2323));`
/// the default value is `Color(0xFFCA2323)`.
///
Map<ThemeRef, Object> _defaultTheme = const {};

Color Function(Color)? _transformColor;

TextStyle Function(TextStyle)? _transformTextStyle;

bool _rebuilding = false;

void _rebuildAllChildrenOfContext(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }

  _rebuilding = true;

  (context as Element).visitChildren(rebuild);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _rebuilding = false;
  });
}

/// Removes the current theme, falling back to the default theme.
void _clearCurrentTheme() {
  Themed._delayedThemeChangeByKey = null;
  _currentTheme = const {};
}

/// Returns true if the given theme is equal to the current one.
/// Note: To check if the default them is being used, do: `ifThemeIs({})`.
bool _ifCurrentThemeIs(Map<ThemeRef, Object> theme) {
  theme = _toIdenticalKeyedMap(theme);
  return mapEquals(theme, _currentTheme);
}

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

/// Converts a given Map<ThemeRef, Object>? to a new map with identical keys.
///
/// This is done to ensure that the keys in the map are compared by identity rather
/// than by equality, which is important because ThemeRef values may have custom equality
/// logic that could cause issues.
///
/// - If the input theme is null, it returns an empty map.
/// - Otherwise, it creates a new map using Map<ThemeRef, Object>.identity(), which
/// ensures that keys are compared by identity. It then iterates over the keys and values
/// of the input map, adding them to the new map.
///
/// Finally, it returns the new map.
/// This approach ensures that the keys in the resulting map are compared by their
/// identity, avoiding potential issues with custom equality logic in ThemeRef values.
///
Map<ThemeRef, Object> _toIdenticalKeyedMap(Map<ThemeRef, Object>? theme) {
  if (theme == null)
    return const {};
  else {
    // Note: We add the maps like this, because the original theme may have ThemeRef
    // values which present our weird equality, so it may fail if we do it any other way.
    var result = Map<ThemeRef, Object>.identity();
    List<ThemeRef> keys = theme.keys.toList();
    List<Object> values = theme.values.toList();
    for (int i = 0; i < keys.length; i++) {
      result[keys[i]] = values[i];
    }
    return result;
  }
}
