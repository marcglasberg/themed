import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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

  // INTERNAL NOTE (not part of the API docs): anti-aliasing problem.
  //
  // The correct result is: alpha' = alpha * (darkOpacity + delta * luminance).
  // A ColorFilter.matrix sees each pixel unpremultiplied (color separated from alpha),
  // and can only do sums, never multiply alpha by luminance. So the matrix in
  // `_ColorFilterGenerator.contrastAndOpacityMatrix` is an approximation: the best one
  // that never makes a pixel more opaque than it should be. It's exact for opaque and
  // for transparent pixels, but translucent pixels of the colors that fade faster
  // disappear. For example, the anti-aliased rounded corners of a dark button background
  // become jagged. Two ways to make it exact, if we ever want to:
  //
  // 1. Paint the child twice (exact on all platforms). In a custom RenderProxyBox,
  //    rasterize the child into a ui.Image on every paint, using the same technique as
  //    Flutter's `_RenderSnapshotWidget._paintAndDetachToImage` (an OffsetLayer, a
  //    PaintingContext, `stopRecordingIfNeeded`, and `offsetLayer.toImageSync`). Then:
  //    `canvas.saveLayer`, draw the image normally, draw the image again with
  //    `BlendMode.dstIn` and a color matrix whose alpha row is
  //    `alpha' = darkOpacity + delta * luminance` (ignoring the original alpha), and
  //    `canvas.restore`. Since dstIn works premultiplied (result = dst * srcAlpha), the
  //    blending does the multiplication the matrix can't. Notes:
  //    - Can't use SnapshotWidget itself: it caches the image, and doesn't update it
  //      when the child changes.
  //    - Can't paint the child twice without the image: a child with repaint boundaries
  //      would add the same layer twice to the tree, which isn't allowed.
  //    - Cost: one offscreen image per repaint. Only do it when opacityFactor != 1 and
  //      opacity < 1, so all other cases keep the current fast path.
  //    - Content that repaints by itself under its own RepaintBoundary (like a spinner)
  //      won't trigger our paint, so it would look frozen. Platform views can't be
  //      rasterized (see `offsetLayer.supportsRasterization()`), so fall back to the
  //      matrix for them.
  //    - Draw the image aligned to physical pixels, or it gets slightly blurry.
  //
  // 2. Fragment shader with `ImageFiltered(imageFilter: ui.ImageFilter.shader(...))`.
  //    Exact and fast (all on the GPU, no image per repaint), and works with content that
  //    repaints by itself. In the shader, the input texture is premultiplied, so:
  //    `L = dot(rgb, lum) / a` and `out = color * (darkOpacity + delta * L)`. Downsides:
  //    - Only works with Impeller (`ui.ImageFilter.isShaderFilterSupported`). On Skia
  //      (web, Windows, Linux, older Android devices) it throws, so we'd still need the
  //      matrix (or option 1) as a fallback.
  //    - Needs a newer minimum Flutter version (today the package allows >=3.16), and a
  //      .frag file declared under `flutter: shaders:` in pubspec.yaml, loaded with
  //      `FragmentProgram.fromAsset('packages/themed/shaders/...')`. Loading is async,
  //      so the first frames must use the fallback.
  //    - The first uniform must be a vec2 (the texture size, set by the engine), and
  //      there must be a sampler2D. On Impeller with OpenGL ES the y-axis is flipped,
  //      so the shader must invert it there.
  //
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
  ///
  /// In dark themes, try values both below and above 1, and keep the one that
  /// looks best. It depends on your colors.
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

    // Keep every element in place so toggling a filter never remounts the child.
    return Opacity(
      opacity: useOpacityWidget ? opacity : 1.0,
      child: _ColorFilters(
        filters: _filters(matrixOpacity: useOpacityWidget ? 1.0 : opacity),
        child: child,
      ),
    );
  }

  /// Returns the filters that are not neutral, from the outermost (applied
  /// last) to the innermost (applied first). The order in which they are
  /// applied is: hue, saturation, brightness, and then contrast and opacity.
  ///
  /// Each filter needs its own offscreen layer, which is expensive to draw.
  /// For this reason, neutral filters are left out.
  List<ColorFilter> _filters({required double matrixOpacity}) {
    //
    List<double>? contrastAndOpacityMatrix =
        (contrast == 0.0 && matrixOpacity == 1.0)
            ? null
            : _ColorFilterGenerator.contrastAndOpacityMatrix(
                contrast: contrast,
                contrastCenter: contrastCenter,
                opacity: matrixOpacity,
                opacityFactor: opacityFactor,
              );

    List<double>? brightnessMatrix = (brightness == 0.0)
        ? null
        : _ColorFilterGenerator.brightnessAdjustMatrix(value: brightness);

    List<double>? saturationMatrix = (saturation == 0.0)
        ? null
        : _ColorFilterGenerator.saturationAdjustMatrix(value: saturation);

    // Removing saturation only mixes each color with its own grey, so its
    // result is always a valid color, and nothing is clamped before the next
    // filter is applied. This means we can join it with the next filter into
    // a single matrix, which gives the same result with one less layer.
    //
    // Note: This is not true for the other filters. They can go outside of
    // the valid color range, and are clamped between one filter and the next,
    // so joining them would change the result.
    if (saturationMatrix != null && saturation < 0.0) {
      if (brightnessMatrix != null) {
        brightnessMatrix =
            _ColorFilterGenerator.concat(saturationMatrix, brightnessMatrix);
        saturationMatrix = null;
      } else if (contrastAndOpacityMatrix != null) {
        contrastAndOpacityMatrix = _ColorFilterGenerator.concat(
            saturationMatrix, contrastAndOpacityMatrix);
        saturationMatrix = null;
      }
    }

    return <ColorFilter>[
      if (contrastAndOpacityMatrix != null)
        ColorFilter.matrix(contrastAndOpacityMatrix),
      if (brightnessMatrix != null) ColorFilter.matrix(brightnessMatrix),
      if (saturationMatrix != null) ColorFilter.matrix(saturationMatrix),
      if (hue != 0.0)
        ColorFilter.matrix(_ColorFilterGenerator.hueAdjustMatrix(value: hue)),
    ];
  }
}

/// Applies the given [filters] to the child, from the last (innermost) to the
/// first (outermost). When there are no filters, it only paints the child.
///
/// It's a single element with a single render object, no matter how many
/// filters there are, so that turning filters on and off never remounts
/// the child.
class _ColorFilters extends SingleChildRenderObjectWidget {
  const _ColorFilters({required this.filters, required super.child});

  final List<ColorFilter> filters;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderColorFilters(filters);

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderColorFilters renderObject) {
    renderObject.filters = filters;
  }
}

class _RenderColorFilters extends RenderProxyBox {
  _RenderColorFilters(this._filters);

  List<ColorFilter> _filters;

  /// The layers of the filters, in the same order, kept to be reused in the
  /// next paint. It may have less layers than filters (before painting), or
  /// more (after filters are removed, until the next paint).
  final List<LayerHandle<ColorFilterLayer>> _layers = [];

  set filters(List<ColorFilter> value) {
    if (listEquals(_filters, value)) return;
    final hadFilters = _filters.isNotEmpty;
    _filters = value;
    if (hadFilters != value.isNotEmpty) markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => child != null && _filters.isNotEmpty;

  @override
  void paint(PaintingContext context, Offset offset) {
    // Discards the layers of filters that were removed.
    while (_layers.length > _filters.length) {
      _layers.removeLast().layer = null;
    }
    _paintFrom(0, context, offset);
  }

  /// Paints the child inside of the filters, starting from the filter with
  /// the given [index]. Each filter is a layer that contains the next one.
  void _paintFrom(int index, PaintingContext context, Offset offset) {
    if (index == _filters.length) {
      super.paint(context, offset);
      return;
    }

    if (index == _layers.length) _layers.add(LayerHandle<ColorFilterLayer>());
    final handle = _layers[index];

    handle.layer = context.pushColorFilter(
      offset,
      _filters[index],
      (PaintingContext context, Offset offset) =>
          _paintFrom(index + 1, context, offset),
      oldLayer: handle.layer,
    );
  }

  @override
  void dispose() {
    for (final handle in _layers) {
      handle.layer = null;
    }
    _layers.clear();
    super.dispose();
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

  @override
  void initState() {
    super.initState();
    _brightness = _AnimatedValue(widget.brightness);
    _saturation = _AnimatedValue(widget.saturation);
    _hue = _AnimatedValue(widget.hue);
    _contrast = _AnimatedValue(widget.contrast);
    _contrastCenter = _AnimatedValue(widget.contrastCenter);
    _opacity = _AnimatedValue(widget.opacity);
    _opacityFactor = _AnimatedValue(widget.opacityFactor);
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
      vsync: this,
      onTick: _rebuild,
    );
  }

  /// Called in each frame, while any of the values is animating.
  void _rebuild() => setState(() {});

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
    return ChangeColors(
      brightness: _brightness.value,
      saturation: _saturation.value,
      hue: _hue.value,
      contrast: _contrast.value,
      contrastCenter: _contrastCenter.value,
      opacity: _opacity.value,
      opacityFactor: _opacityFactor.value,
      child: widget.child,
    );
  }
}

/// A single animated value, with its own controller, so that each value
/// can use its own curve and duration, according to its direction.
class _AnimatedValue {
  //
  /// Only created when the value is animated for the first time. Most values
  /// are never animated, so this avoids creating (and later disposing) one
  /// controller and one ticker for each one of them.
  AnimationController? _controller;

  double _begin;
  double _end;
  Curve _curve = Curves.linear;

  _AnimatedValue(double initialValue)
      : _begin = initialValue,
        _end = initialValue;

  /// The current value.
  double get value {
    final controller = _controller;
    if (controller == null || _begin == _end) return _end;

    final t = controller.value;
    if (t >= 1.0) return _end;
    return _begin + (_end - _begin) * _curve.transform(t);
  }

  /// Animates the value to the given [target]. While it animates, [onTick] is
  /// called in each frame.
  void animateTo(
    double target, {
    required Curve raisingCurve,
    required Duration raisingDuration,
    required Curve loweringCurve,
    required Duration loweringDuration,
    required TickerProvider vsync,
    required VoidCallback onTick,
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
      // Jumps to the target. Note: Setting the value also stops the controller.
      _controller?.value = 1.0;
    } else {
      final controller = _controller ??= AnimationController(vsync: vsync)
        ..addListener(onTick);
      controller.duration = duration;
      controller.forward(from: 0.0);
    }
  }

  void dispose() => _controller?.dispose();
}

/// Creates the matrices of the color filters. Each matrix has 4 rows (the red,
/// green, blue and alpha of the resulting color), and 5 columns (how much of
/// the red, green, blue and alpha of the original color goes into it, plus an
/// offset from 0 to 255).
class _ColorFilterGenerator {
  //
  /// Note: The [value] can't be zero (use no filter instead).
  static List<double> hueAdjustMatrix({required double value}) {
    value = value * pi;

    final double cosVal = cos(value);
    final double sinVal = sin(value);
    const double lumR = 0.213;
    const double lumG = 0.715;
    const double lumB = 0.072;

    return <double>[
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
    ];
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
      lightOpacity =
          (opacityFactor == 0.0) ? 1.0 : min(1.0, opacity / opacityFactor);
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
      alphaRow = [
        delta * lumR,
        delta * lumG,
        delta * lumB,
        lightOpacity,
        -delta * 255
      ];
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

  /// Note: The [value] can't be zero (use no filter instead).
  static List<double> brightnessAdjustMatrix({required double value}) {
    value = (value <= 0) ? (value * 255) : (value * 100);

    return <double>[
      1, 0, 0, 0, value, //
      0, 1, 0, 0, value, //
      0, 0, 1, 0, value, //
      0, 0, 0, 1, 0, //
    ];
  }

  /// Note: The [value] can't be zero (use no filter instead).
  static List<double> saturationAdjustMatrix({required double value}) {
    value = value * 100;

    final double x = 1 + ((value > 0) ? ((3 * value) / 100) : (value / 100));
    const double lumR = 0.3086;
    const double lumG = 0.6094;
    const double lumB = 0.082;

    return <double>[
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
    ];
  }

  /// Returns a single matrix that does the same as applying the [first]
  /// matrix, and then applying the [second] matrix to its result.
  ///
  /// Note: This is only the same if the [first] matrix always results in valid
  /// colors, because the color filters clamp their results to the valid range.
  static List<double> concat(List<double> first, List<double> second) {
    final result = List<double>.filled(20, 0.0);

    for (int row = 0; row < 20; row += 5) {
      for (int column = 0; column < 5; column++) {
        // The offset of the second matrix is applied only once (last column).
        double sum = (column == 4) ? second[row + 4] : 0.0;

        for (int i = 0; i < 4; i++) {
          sum += second[row + i] * first[i * 5 + column];
        }
        result[row + column] = sum;
      }
    }
    return result;
  }
}
