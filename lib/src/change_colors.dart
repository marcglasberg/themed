import 'dart:math';

import 'package:flutter/material.dart';

// Based upon: https://stackoverflow.com/questions/64639589/how-to-adjust-hue-saturation-and-brightness-of-an-image-in-flutter
// from BananaNeil: https://stackoverflow.com/users/937841/banananeil.
// This is, in turn, based upon: https://stackoverflow.com/a/7917978/937841
// All credit goes to the above authors.

/// Use the [ChangeColors] widget to change the brightness, saturation,
/// hue, contrast and opacity of any widget, including images.
///
/// Example:
///
/// ```
/// ChangeColors(
///    hue: 0.55,
///    brightness: 0.2,
///    saturation: 0.1,
///    contrast: -0.3,
///    opacity: 0.8,
///    child: Image.asset('myImage.png'),
/// );
/// ```
///
/// For example, to make a button look disabled in a light theme, turn it
/// grey and lower its contrast toward a light grey:
///
/// ```
/// ChangeColors(
///    saturation: isDisabled ? -1.0 : 0.0,
///    contrast: isDisabled ? -0.6 : 0.0,
///    contrastCenter: 0.85,
///    child: MyButton(),
/// );
/// ```
///
/// Or, if you want to see through it, make it transparent, but let the dark
/// text fade faster than the light background, so that the background
/// doesn't disappear (see [opacityFactor]):
///
/// ```
/// ChangeColors(
///    saturation: isDisabled ? -1.0 : 0.0,
///    opacity: isDisabled ? 0.3 : 1.0,
///    opacityFactor: 0.3,
///    child: MyButton(),
/// );
/// ```
///
/// To achieve a greyscale effect, you may also use the
/// [ChangeColors.greyscale] constructor.
///
/// To animate the changes, use [AnimatedChangeColors] instead.
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
  /// Note: 0.0 is unchanged. Adding or subtracting multiples of 2.0 also keeps it unchanged.
  final double hue;

  /// Negative value lowers the contrast, moving all colors closer to the
  /// [contrastCenter] grey (-1 turns everything into that grey).
  /// Positive value raises the contrast (1 doubles it, but you can go above it).
  /// Note: 0.0 is unchanged.
  final double contrast;

  /// The grey that colors move toward when you lower the [contrast].
  /// From 0.0 (black) to 1.0 (white). The default is 0.5 (medium grey).
  ///
  /// Use a light grey (like 0.85) for a faded look in light themes,
  /// and a dark grey (like 0.15) in dark themes.
  final double contrastCenter;

  /// From 0.0 (invisible) to 1.0 (opaque). Values outside this range are clamped.
  /// Note: 1.0 is unchanged.
  final double opacity;

  /// Makes dark and light colors fade at different speeds, when the [opacity]
  /// is less than 1:
  ///
  /// * 1.0 (the default): All colors fade the same.
  ///
  /// * Less than 1: Dark colors fade faster than light colors. For example,
  ///   with 0.5 the light colors keep twice the opacity of the dark colors.
  ///   Good for light themes.
  ///
  /// * More than 1: Light colors fade faster than dark colors. For example,
  ///   with 2.0 the dark colors keep twice the opacity of the light colors.
  ///   Good for dark themes.
  ///
  /// Why is this useful? Suppose a button with dark text and a light
  /// background, in a light screen. If you make it transparent, the light
  /// background disappears into the screen very quickly, while the dark text
  /// is still easy to read. Using an [opacityFactor] less than 1 keeps the
  /// background visible while the text fades.
  ///
  /// Note: This works best with widgets that have a solid background,
  /// like buttons.
  final double opacityFactor;

  final Widget child;

  ChangeColors({
    Key? key,
    this.brightness = 0.0,
    double saturation = 0.0,
    this.hue = 0.0,
    double contrast = 0.0,
    double contrastCenter = 0.5,
    double opacity = 1.0,
    double opacityFactor = 1.0,
    required this.child,
  })  : saturation = _clampSaturation(saturation),
        contrast = _clampContrast(contrast),
        contrastCenter = _clampContrastCenter(contrastCenter),
        opacity = _clampOpacity(opacity),
        opacityFactor = _clampOpacityFactor(opacityFactor),
        super(key: key);

  ChangeColors.greyscale({
    Key? key,
    this.brightness = 0.0,
    double contrast = 0.0,
    double contrastCenter = 0.5,
    double opacity = 1.0,
    double opacityFactor = 1.0,
    required this.child,
  })  : saturation = -1.0,
        hue = 0.0,
        contrast = _clampContrast(contrast),
        contrastCenter = _clampContrastCenter(contrastCenter),
        opacity = _clampOpacity(opacity),
        opacityFactor = _clampOpacityFactor(opacityFactor),
        super(key: key);

  static double _clampSaturation(double value) => value.clamp(-1.0, double.nan);

  static double _clampContrast(double value) => max(value, -1.0);

  static double _clampContrastCenter(double value) => value.clamp(0.0, 1.0);

  static double _clampOpacity(double value) => value.clamp(0.0, 1.0);

  static double _clampOpacityFactor(double value) => max(value, 0.0);

  @override
  Widget build(BuildContext context) {
    // When the opacity factor is used, the opacity goes into the color matrix
    // instead of the Opacity widget. Opacity 0 still uses the Opacity widget,
    // so that the child is not painted.
    final bool useOpacityWidget = (opacityFactor == 1.0) || (opacity == 0.0);

    // The widget tree is always the same, whatever the values,
    // so that the child state is kept when the values change.
    return Opacity(
      opacity: useOpacityWidget ? opacity : 1.0,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(_ColorFilterGenerator.contrastAndOpacityMatrix(
          contrast: contrast,
          contrastCenter: contrastCenter,
          opacity: useOpacityWidget ? 1.0 : opacity,
          opacityFactor: opacityFactor,
        )),
        child: ColorFiltered(
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
                ))),
      ),
    );
  }
}

/// The animated version of [ChangeColors]. It changes the brightness,
/// saturation, hue, contrast and opacity of any widget, including images,
/// and animates these values whenever they change.
///
/// Each value is animated independently. When a value increases, it uses
/// [raisingCurve] and [raisingDuration]. When a value decreases, it uses
/// [loweringCurve] and [loweringDuration]. For example, if the saturation goes
/// from `0` to `-1`, it's decreasing, so it animates with [loweringCurve]
/// during [loweringDuration].
///
/// Example:
///
/// ```
/// AnimatedChangeColors(
///    saturation: isDisabled ? -1.0 : 0.0,
///    opacity: isDisabled ? 0.5 : 1.0,
///    raisingCurve: Curves.easeOut,
///    raisingDuration: const Duration(milliseconds: 300),
///    loweringCurve: Curves.easeIn,
///    loweringDuration: const Duration(milliseconds: 150),
///    child: Image.asset('myImage.png'),
/// );
/// ```
///
/// Note: The initial values are not animated. Only later changes are.
///
class AnimatedChangeColors extends StatefulWidget {
  //
  static const Curve defaultCurve = Curves.easeInOut;
  static const Duration defaultDuration = Duration(milliseconds: 200);

  /// Same as [ChangeColors.brightness].
  final double brightness;

  /// Same as [ChangeColors.saturation].
  final double saturation;

  /// Same as [ChangeColors.hue].
  /// Note: The hue is animated numerically. For example, going from 0.9 to -0.9
  /// will pass through 0.0, instead of wrapping through 1.0.
  final double hue;

  /// Same as [ChangeColors.contrast].
  final double contrast;

  /// Same as [ChangeColors.contrastCenter].
  final double contrastCenter;

  /// Same as [ChangeColors.opacity].
  final double opacity;

  /// Same as [ChangeColors.opacityFactor].
  final double opacityFactor;

  /// The curve used when a value increases. The default is [Curves.easeInOut].
  final Curve raisingCurve;

  /// The duration used when a value increases. The default is 200 milliseconds.
  final Duration raisingDuration;

  /// The curve used when a value decreases. The default is [Curves.easeInOut].
  final Curve loweringCurve;

  /// The duration used when a value decreases. The default is 200 milliseconds.
  final Duration loweringDuration;

  final Widget child;

  const AnimatedChangeColors({
    Key? key,
    this.brightness = 0.0,
    this.saturation = 0.0,
    this.hue = 0.0,
    this.contrast = 0.0,
    this.contrastCenter = 0.5,
    this.opacity = 1.0,
    this.opacityFactor = 1.0,
    this.raisingCurve = defaultCurve,
    this.raisingDuration = defaultDuration,
    this.loweringCurve = defaultCurve,
    this.loweringDuration = defaultDuration,
    required this.child,
  }) : super(key: key);

  @override
  State<AnimatedChangeColors> createState() => _AnimatedChangeColorsState();
}

class _AnimatedChangeColorsState extends State<AnimatedChangeColors>
    with TickerProviderStateMixin {
  //
  late final _AnimatedValue _brightness;
  late final _AnimatedValue _saturation;
  late final _AnimatedValue _hue;
  late final _AnimatedValue _contrast;
  late final _AnimatedValue _contrastCenter;
  late final _AnimatedValue _opacity;
  late final _AnimatedValue _opacityFactor;
  late final Listenable _listenable;

  @override
  void initState() {
    super.initState();
    _brightness = _AnimatedValue(widget.brightness, this);
    _saturation = _AnimatedValue(widget.saturation, this);
    _hue = _AnimatedValue(widget.hue, this);
    _contrast = _AnimatedValue(widget.contrast, this);
    _contrastCenter = _AnimatedValue(widget.contrastCenter, this);
    _opacity = _AnimatedValue(widget.opacity, this);
    _opacityFactor = _AnimatedValue(widget.opacityFactor, this);
    _listenable = Listenable.merge([
      _brightness.controller,
      _saturation.controller,
      _hue.controller,
      _contrast.controller,
      _contrastCenter.controller,
      _opacity.controller,
      _opacityFactor.controller,
    ]);
  }

  @override
  void didUpdateWidget(AnimatedChangeColors oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animate(_brightness, widget.brightness);
    _animate(_saturation, widget.saturation);
    _animate(_hue, widget.hue);
    _animate(_contrast, widget.contrast);
    _animate(_contrastCenter, widget.contrastCenter);
    _animate(_opacity, widget.opacity);
    _animate(_opacityFactor, widget.opacityFactor);
  }

  void _animate(_AnimatedValue animatedValue, double target) {
    animatedValue.animateTo(
      target,
      raisingCurve: widget.raisingCurve,
      raisingDuration: widget.raisingDuration,
      loweringCurve: widget.loweringCurve,
      loweringDuration: widget.loweringDuration,
    );
  }

  @override
  void dispose() {
    _brightness.dispose();
    _saturation.dispose();
    _hue.dispose();
    _contrast.dispose();
    _contrastCenter.dispose();
    _opacity.dispose();
    _opacityFactor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _listenable,
      child: widget.child,
      builder: (BuildContext context, Widget? child) => ChangeColors(
        brightness: _brightness.value,
        saturation: _saturation.value,
        hue: _hue.value,
        contrast: _contrast.value,
        contrastCenter: _contrastCenter.value,
        opacity: _opacity.value,
        opacityFactor: _opacityFactor.value,
        child: child!,
      ),
    );
  }
}

/// A single animated value, with its own controller, so that each value
/// can use its own curve and duration, according to its direction.
class _AnimatedValue {
  //
  final AnimationController controller;
  double _begin;
  double _end;
  Curve _curve = Curves.linear;

  _AnimatedValue(double initialValue, TickerProvider vsync)
      : _begin = initialValue,
        _end = initialValue,
        controller = AnimationController(vsync: vsync, value: 1.0);

  /// The current value.
  double get value {
    final t = controller.value;
    if (_begin == _end || t >= 1.0) return _end;
    return _begin + (_end - _begin) * _curve.transform(t);
  }

  void animateTo(
    double target, {
    required Curve raisingCurve,
    required Duration raisingDuration,
    required Curve loweringCurve,
    required Duration loweringDuration,
  }) {
    if (target == _end) return;

    // Start from the current value, even if a previous animation is still running.
    final current = value;
    _begin = current;
    _end = target;

    final isRaising = target > current;
    _curve = isRaising ? raisingCurve : loweringCurve;
    final duration = isRaising ? raisingDuration : loweringDuration;

    if (duration == Duration.zero || current == target) {
      controller.stop();
      controller.value = 1.0;
    } else {
      controller.duration = duration;
      controller.forward(from: 0.0);
    }
  }

  void dispose() => controller.dispose();
}



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

  /// Changes the contrast, and makes dark and light colors fade at different
  /// speeds. When [contrast] is 0 and [opacity] is 1, returns the identity.
  static List<double> contrastAndOpacityMatrix({
    required double contrast,
    required double contrastCenter,
    required double opacity,
    required double opacityFactor,
  }) {
    // Contrast: color' = c * color + (1 - c) * center.
    final double c = 1.0 + contrast;
    final double offset = (1.0 - c) * contrastCenter * 255;

    // The opacity of black, and the opacity of white.
    // The opacity of other colors goes between them, according to their luminance.
    double darkOpacity, lightOpacity;
    if (opacity == 0.0) {
      darkOpacity = lightOpacity = 0.0;
    } else if (opacityFactor <= 1.0) {
      darkOpacity = opacity;
      lightOpacity = (opacityFactor == 0.0) ? 1.0 : min(1.0, opacity / opacityFactor);
    } else {
      lightOpacity = opacity;
      darkOpacity = min(1.0, opacity * opacityFactor);
    }

    // We want: alpha' = alpha * (darkOpacity + (lightOpacity - darkOpacity) * luminance).
    // That's not linear (alpha times luminance), so it can't be done exactly with a matrix.
    // We use the best linear approximation that never makes a pixel more opaque than it
    // should be. It's exact for opaque pixels, and for transparent ones. For translucent
    // pixels (like anti-aliased edges and shadows) it may make them a bit more transparent.
    // The luminance is calculated from the colors before the contrast change.
    const double lumR = 0.2126, lumG = 0.7152, lumB = 0.0722;
    final List<double> alphaRow;
    if (lightOpacity >= darkOpacity) {
      // alpha' = lightOpacity * alpha - delta * (1 - luminance)
      final double delta = lightOpacity - darkOpacity;
      alphaRow = [delta * lumR, delta * lumG, delta * lumB, lightOpacity, -delta * 255];
    } else {
      // alpha' = darkOpacity * alpha - delta * luminance
      final double delta = darkOpacity - lightOpacity;
      alphaRow = [-delta * lumR, -delta * lumG, -delta * lumB, darkOpacity, 0];
    }

    return <double>[
      c, 0, 0, 0, offset, //
      0, c, 0, 0, offset, //
      0, 0, c, 0, offset, //
      ...alphaRow,
    ];
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
