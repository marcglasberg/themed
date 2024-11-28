import 'package:flutter/material.dart';

extension TextStyleExtension on TextStyle {
  //
  /// You can create a [TextStyle] by adding the [TextStyle] to one these types:
  /// [Color], [String] (fontFamily), [FontSize], [FontWeight], [FontStyle],
  /// [TextBaseline], [Locale], List<[Shadow]>, List<[FontFeature]>, [Decoration],
  /// [TextDecorationStyle], or [TextHeight].
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
              shadows: obj is List<Shadow> ? obj : null,
              fontFeatures: obj is List<FontFeature> ? obj : null,
              decoration: obj is TextDecoration ? obj : null,
              decorationStyle: obj is TextDecorationStyle ? obj : null,
              height: obj is TextHeight ? obj.height : null,
            );

  /// Instead of using [operator +] you can use the [add] method.
  /// If [apply] is false, the provided [obj] will not be added.
  ///
  TextStyle add(Object? obj, {bool apply = true}) => (apply) ? this + obj : this;
}

class TextHeight {
  final double height;

  const TextHeight(this.height);
}

class FontSize {
  final double fontSize;

  const FontSize(this.fontSize);
}
