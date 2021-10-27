import "package:flutter/material.dart";

extension ColorUtil on Color {
  //
  /// Makes the color lighter (more white), by the given [value], from `0` (no change) to `1` (white).
  /// If [value] is not provided, it will be 0.5 (50% change).
  /// If [value] is less than 0, it's 0. If more than 1, it's 1.
  /// Doesn't change the opacity.
  Color lighter([double value = 0.5]) =>
      Color.lerp(this, Colors.white, _limit(value))!.withAlpha(alpha);

  /// Makes the color darker (more black), by the given [value], from `0` (no change) to `1` (black).
  /// If [value] is not provided, it will be 0.5 (50% change).
  /// If [value] is less than 0, it's 0. If more than 1, it's 1.
  /// Doesn't change the opacity.
  Color darker([double value = 0.5]) =>
      Color.lerp(this, Colors.black, _limit(value))!.withAlpha(alpha);

  /// Makes the current color more similar to the given [color], by the given [value],
  /// from `0` (no change) to `1` (equal to [color]).
  /// If [value] is not provided, it will be 0.5 (50% change).
  /// If [value] is less than 0, it's 0. If more than 1, it's 1.
  /// Doesn't change the opacity.
  Color average(Color color, [double value = 0.5]) => Color.lerp(this, color, _limit(value))!;

  /// Makes the current color more grey (aprox. keeping its luminance), by the given [value],
  /// from `0` (no change) to `1` (grey).
  /// If [value] is not provided, it will be 1 (100% change, no color at all).
  /// If [value] is less than 0, it's 0. If more than 1, it's 1.
  /// Doesn't change the opacity.
  Color decolorize([double value = 1]) {
    int average = (red + green + blue) ~/ 3;
    var color = Color.fromARGB(alpha, average, average, average);
    return Color.lerp(this, color, _limit(value))!;
  }

  /// Makes the current color more transparent, by the given [value],
  /// from `0` (total transparency) to `1` (no change).
  /// If [value] is not provided, it will be 0.5 (50% change).
  /// If [value] is less than 0, it's 0. If more than 1, it's 1.
  /// Makes it more transparent if percent < 1.
  Color addOpacity([double value = 0.5]) =>
      Color.fromARGB((alpha * _limit(value)).round(), red, green, blue);

  /// Converts the RGBA color representation to ARGB.
  static int rgbaToArgb(int rgbaColor) {
    int a = rgbaColor & 0xFF;
    int rgb = rgbaColor >> 8;
    return rgb + (a << 24);
  }

  /// Converts the ABGR color representation to ARGB.
  static int abgrToArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }

  double _limit(double value) => (value < 0) ? 0 : (value > 1 ? 1 : value);
}
