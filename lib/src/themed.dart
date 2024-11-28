import 'dart:ui' as ui
    show
        ParagraphStyle,
        TextStyle,
        Shadow,
        FontFeature,
        TextHeightBehavior,
        TextLeadingDistribution,
        FontVariation;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:themed/src/const_theme_exception.dart';

abstract class ThemeRef {}

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
/// import 'package:themed/themed.dart';
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

  /// Saved themes.
  static final Map<Object, Map<ThemeRef, Object>> _saved = {};
  static Object? _delayedThemeChangeByKey;

  /// The [Themed] widget should wrap the [child] that contains the tree of
  /// widgets where you want to use the color theme. It is recommended to provide a
  /// [defaultTheme].
  ///
  Themed({
    Key? key,
    Map<ThemeRef, Object>? defaultTheme,
    Map<ThemeRef, Object>? currentTheme,
    required this.child,
  }) : super(key: _themedKey) {
    if (defaultTheme != null) _defaultTheme = _toIdenticalKeyedMap(defaultTheme);
    if (currentTheme != null) _currentTheme = _toIdenticalKeyedMap(currentTheme);
  }

  static void _setState() {
    _themedKey.currentState?.setState(() {}); // ignore: invalid_use_of_protected_member
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

  /// Same as `Themed.of(context).transformColor = ...;`
  ///
  /// Sets a transform which will be applied to all colors.
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

  /// Same as `Themed.defaultTheme = { ... }`.
  ///
  /// The default theme must define all used colors.
  set defaultTheme(Map<ThemeRef, Object>? defaultTheme) {
    if (mounted)
      setState(() {
        _defaultTheme = _toIdenticalKeyedMap(defaultTheme);
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
    return _InheritedConstTheme(
      key: ValueKey<Object>(Object()), // ignore: prefer_const_constructors
      data: this,
      child: widget.child,
    );
  }

  /// See: https://stackoverflow.com/a/58513635/3411681
  void _rebuildAllChildren() {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
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

  @override
  int get value {
    Color? result = _currentTheme[this] as Color?;
    result ??= _defaultTheme[this] as Color?;
    result ??= defaultColor;
    if (result == null) throw ConstThemeException('Theme color "$id" is not defined.');
    if (_transformColor != null) result = _transformColor!(result);
    return result.value;
  }

  @override
  String toString() => 'ColorRef('
      '0x${value.toRadixString(16).padLeft(8, '0')}${id == null ? "" : ", id: $id"}'
      ')';

  /// The equality operator.
  ///
  /// Two [ColorRef]s are equal if they have the same [defaultColor] and [id].
  /// Please note, the current color (that depends on the current theme)
  /// is ignored.
  ///
  /// If you want to check equality for the [ColorRef]'s current color,
  /// you can use its [color] or [value] getters. For example:
  ///
  /// * ColorRef(Colors.white).color == ColorRef(Colors.white).color // Is true
  /// * ColorRef(Colors.white).color == Colors.white // Is true
  /// * ColorRef(Colors.white) == Colors.white // Is false
  ///
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ColorRef &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          defaultColor == other.defaultColor;

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
        // ignore: deprecated_member_use
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
