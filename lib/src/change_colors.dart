import 'dart:math';

import 'package:flutter/material.dart';

// Based upon: https://stackoverflow.com/questions/64639589/how-to-adjust-hue-saturation-and-brightness-of-an-image-in-flutter
// from BananaNeil: https://stackoverflow.com/users/937841/banananeil.
// This is, in turn, based upon: https://stackoverflow.com/a/7917978/937841
// All credit goes to the above authors.

/// Use the [ChangeColors] widget to change the brightness, saturation
/// and hue of any widget, including images.
///
/// Example:
///
/// ```
/// ChangeColors(
///    hue: 0.55,
///    brightness: 0.2,
///    saturation: 0.1,
///    child: Image.asset('myImage.png'),
/// );
/// ```
///
/// To achieve a greyscale effect, you may also use the
/// [ChangeColors.greyscale] constructor.
///
class ChangeColors extends StatelessWidget {
  //

  /// Negative value will make it darker (-1 is darkest).
  /// Positive value will make it lighter (1 is the maximum, but you can go above it).
  /// Note: 0.0 is unchanged.
  final double brightness;

  /// Negative value will make it less saturated (-1 is greyscale).
  /// Positive value will make it more saturated (1 is the maximum, but you can go above it).
  /// Note: 0.0 is unchanged.
  final double saturation;

  /// From -1.0 to 1.0 (Note: 1.0 wraps into -1.0, such as 1.2 is the same as -0.8).
  /// Note: 0.0 is unchanged. Adding or subtracting 2.0 also keeps it unchanged.
  final double hue;

  final Widget child;

  ChangeColors({
    Key? key,
    this.brightness = 0.0,
    double saturation = 0.0,
    this.hue = 0.0,
    required this.child,
  })  : saturation = _clampSaturation(saturation),
        super(key: key);

  ChangeColors.greyscale({
    Key? key,
    this.brightness = 0.0,
    required this.child,
  })  : saturation = -1.0,
        hue = 0.0,
        super(key: key);

  static double _clampSaturation(double value) => value.clamp(-1.0, double.nan);

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
        colorFilter: ColorFilter.matrix(_ColorFilterGenerator.brightnessAdjustMatrix(
          value: brightness,
        )),
        child: ColorFiltered(
            colorFilter: ColorFilter.matrix(_ColorFilterGenerator.saturationAdjustMatrix(
              value: saturation,
            )),
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(_ColorFilterGenerator.hueAdjustMatrix(
                value: hue,
              )),
              child: child,
            )));
  }
}

// ////////////////////////////////////////////////////////////////////////////

class _ColorFilterGenerator {
  //
  static List<double> hueAdjustMatrix({required double value}) {
    value = value * pi;

    if (value == 0)
      return [
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ];

    double cosVal = cos(value);
    double sinVal = sin(value);
    double lumR = 0.213;
    double lumG = 0.715;
    double lumB = 0.072;

    return List<double>.from(<double>[
      (lumR + (cosVal * (1 - lumR))) + (sinVal * (-lumR)),
      (lumG + (cosVal * (-lumG))) + (sinVal * (-lumG)),
      (lumB + (cosVal * (-lumB))) + (sinVal * (1 - lumB)),
      0,
      0,
      (lumR + (cosVal * (-lumR))) + (sinVal * 0.143),
      (lumG + (cosVal * (1 - lumG))) + (sinVal * 0.14),
      (lumB + (cosVal * (-lumB))) + (sinVal * (-0.283)),
      0,
      0,
      (lumR + (cosVal * (-lumR))) + (sinVal * (-(1 - lumR))),
      (lumG + (cosVal * (-lumG))) + (sinVal * lumG),
      (lumB + (cosVal * (1 - lumB))) + (sinVal * lumB),
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]).map((i) => i.toDouble()).toList();
  }

  static List<double> brightnessAdjustMatrix({required double value}) {
    if (value <= 0)
      value = value * 255;
    else
      value = value * 100;

    if (value == 0)
      return [
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ];

    return List<double>.from(
            <double>[1, 0, 0, 0, value, 0, 1, 0, 0, value, 0, 0, 1, 0, value, 0, 0, 0, 1, 0])
        .map((i) => i.toDouble())
        .toList();
  }

  static List<double> saturationAdjustMatrix({required double value}) {
    value = value * 100;

    if (value == 0)
      return [
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ];

    double x = ((1 + ((value > 0) ? ((3 * value) / 100) : (value / 100)))).toDouble();
    double lumR = 0.3086;
    double lumG = 0.6094;
    double lumB = 0.082;

    return List<double>.from(<double>[
      (lumR * (1 - x)) + x,
      lumG * (1 - x),
      lumB * (1 - x),
      0,
      0,
      lumR * (1 - x),
      (lumG * (1 - x)) + x,
      lumB * (1 - x),
      0,
      0,
      lumR * (1 - x),
      lumG * (1 - x),
      (lumB * (1 - x)) + x,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]).map((i) => i.toDouble()).toList();
  }
}
