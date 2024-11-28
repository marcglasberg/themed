import 'package:flutter/material.dart';

/// You can create a [MaterialColor] color swatch from a single [primary]
/// color (which you can later change using the Themed package):
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

/// You can create a [MaterialAccentColorSwatch] color swatch from a
/// single [primary] color (which you can later change using the Themed package):
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

  const MaterialAccentColorSwatch(this.primary, Map<int, Color> swatch)
      : super(0, swatch);

  @override
  int get value => primary.value;
}
