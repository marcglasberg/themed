import "package:material_ui/material_ui.dart";
import 'package:themed/src/change_colors.dart';
import 'package:themed/src/themed.dart';

extension ColorUtil on Color {
  //
  /// Makes the color lighter (more white), by the given [value], from `0` (no change) to `1` (white).
  /// If [value] is not provided, it will be 0.5 (50% change).
  /// If [value] is less than 0, it's 0. If more than 1, it's 1.
  /// Doesn't change the opacity.
  ///
  /// See also: [ChangeColors]
  ///
  Color lighter([double value = 0.5]) => _mixKeepingAlpha(Colors.white, value);

  /// Makes the color darker (more black), by the given [value], from `0` (no change) to `1` (black).
  /// If [value] is not provided, it will be 0.5 (50% change).
  /// If [value] is less than 0, it's 0. If more than 1, it's 1.
  /// Doesn't change the opacity.
  ///
  /// See also: [ChangeColors]
  ///
  Color darker([double value = 0.5]) => _mixKeepingAlpha(Colors.black, value);

  /// Makes the current color more similar to the given [color], by the given [value],
  /// from `0` (no change) to `1` (equal to [color]).
  /// If [value] is not provided, it will be 0.5 (50% change).
  /// If [value] is less than 0, it's 0. If more than 1, it's 1.
  /// Doesn't change the opacity.
  ///
  /// See also: [ChangeColors]
  ///
  Color average(Color color, [double value = 0.5]) =>
      Color.lerp(_current, color._current, _limit(value))!;

  /// Makes the current color more grey (aprox. keeping its luminance), by the given [value],
  /// from `0` (no change) to `1` (grey).
  /// If [value] is not provided, it will be 1 (100% change, no color at all).
  /// If [value] is less than 0, it's 0. If more than 1, it's 1.
  /// Doesn't change the opacity.
  ///
  /// See also: [ChangeColors]
  ///
  Color decolorize([double value = 1]) {
    final Color color = _current;
    final int argb = color.value;
    final int average = (((argb >> 16) & 0xFF) + ((argb >> 8) & 0xFF) + (argb & 0xFF)) ~/ 3;
    final Color grey = Color.fromARGB(argb >> 24, average, average, average);
    return Color.lerp(color, grey, _limit(value))!;
  }

  /// Makes the current color more transparent, by the given [value],
  /// from `0` (total transparency) to `1` (no change).
  /// If [value] is not provided, it will be 0.5 (50% change).
  /// If [value] is less than 0, it's 0. If more than 1, it's 1.
  /// Makes it more transparent if percent < 1.
  Color addOpacity([double value = 0.5]) {
    final int argb = this.value;
    final int alpha = (argb >> 24) & 0xFF;
    return Color(_withAlpha(argb, (alpha * _limit(value)).round()));
  }

  /// Makes the current color more opaque, by the given [value],
  /// from `0` (no change) to `1` (fully opaque).
  /// If [value] is not provided, it will be 0.5 (50% change).
  /// If [value] is less than 0, it's 0. If more than 1, it's 1.
  /// Makes it more opaque if percent < 1.
  Color removeOpacity([double value = 0.5]) {
    final int argb = this.value;
    final int alpha = (argb >> 24) & 0xFF;
    return Color(_withAlpha(argb, (alpha + ((255 - alpha) * _limit(value))).round()));
  }

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

  // PERFORMANCE NOTE: Reading a color is not free. Its 32 bit `value` is calculated
  // each time it's read, and getters like `red` and `alpha` read it again. Also, a theme
  // color ([ColorRef]) is searched in the theme each time one of its channels is read.
  // For this reason, the methods above read the color only once.

  /// Makes this color more similar to [other], by the given [value], but keeps its alpha.
  Color _mixKeepingAlpha(Color other, double value) {
    final Color color = _current;
    final Color mixed = Color.lerp(color, other, _limit(value))!;
    return Color(_withAlpha(mixed.value, color.value >> 24));
  }

  /// For a theme color ([ColorRef]), returns its current color in the theme, which can
  /// then be read many times without searching the theme again. Otherwise, returns this.
  Color get _current {
    final Color self = this;
    return (self is ColorRef) ? self.color : self;
  }

  /// Returns the given [argb] color value, with its alpha replaced by [alpha] (0 to 255).
  static int _withAlpha(int argb, int alpha) => ((alpha & 0xFF) << 24) | (argb & 0x00FFFFFF);
}
