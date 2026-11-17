Sponsored by [MyText.ai](https://mytext.ai)

[![](./example/SponsoredByMyTextAi.jpg)](https://mytext.ai)

## 8.4.2

* Performance improvements. There are no API changes:

  * `AnimatedChangeColors` is a lot faster to create and to dispose. Its
    animation controllers are now only created for the values that actually
    animate, when they animate for the first time.

  * `ChangeColors` and `AnimatedChangeColors` now use fewer widgets and render
    objects, so they are faster to create, rebuild, layout and paint.

  * When `ChangeColors` removes saturation (a negative `saturation`, or
    `ChangeColors.greyscale`) together with a change in brightness, contrast, or
    with the `opacityFactor`, they now share a single layer, instead of using
    one layer each. The result is the same, but it's faster to draw. This is the
    case of making a button look disabled, as shown in the README.

  * The `Color` extension methods (`lighter`, `darker`, `average`, `decolorize`,
    `addOpacity` and `removeOpacity`) are faster, especially when used with theme
    colors (`ColorRef`).

  * Theme colors (`ColorRef`) are a lot faster to read and to paint. Their
    current value is now cached until the themes change. The cache is not used
    while there is a color transform, and its size is limited.

  * `ColorRef.shadesOfGreyTransform` is faster. This makes all theme colors
    faster to read and paint, when this transform is in use.

  * Comparing two different `ColorRef`s is faster, and `Themed.ifCurrentThemeIs`
    no longer copies the given theme.

* Fix: `MaterialColorSwatch` and `MaterialAccentColorSwatch` were painted as
  transparent, when used directly as a color (and not through one of their
  shades).

* Fix: Comparing a `ColorRef` with a different one doesn't throw anymore, when
  one of them is not defined in the theme.

* The `pubspec.yaml` now asks for Flutter 3.27.0 or newer. This was already the
  minimum version for version 8 and up (see below), but it was not declared.

## 8.4.0

* `ChangeColors` and `AnimatedChangeColors` now skip compositing layers for
  neutral color adjustments, including the default values. Active filters keep
  their original order and behavior.
* Preserve child state and focus when filters turn on or off, including during
  animations. Public APIs and animation curves and durations are unchanged.

## 8.3.1

* `ChangeColors` and `AnimatedChangeColors` now accept a `contrast` parameter.
  Negative values lower the contrast, moving all colors closer to the
  `contrastCenter` grey, and positive values raise it. The defaults are
  `0` (unchanged) and `0.5` (medium grey).

* `ChangeColors` and `AnimatedChangeColors` now accept an `opacityFactor`
  parameter, which makes dark and light colors fade at different speeds.
  Less than `1` makes dark colors fade faster, and more than `1` makes light
  colors fade faster. The default `1` fades all colors the same.
  See the README for how to use this to make a button look disabled.

* `ChangeColors` now accepts an `opacity` parameter, from `0` (invisible)
  to `1` (opaque, unchanged). The default is `1`.

* New `AnimatedChangeColors` widget, which animates changes to the brightness,
  saturation, hue and opacity. Increasing values use `raisingCurve` and
  `raisingDuration`, while decreasing values use `loweringCurve` and
  `loweringDuration`. The defaults are `Curves.easeInOut` and 200 milliseconds.

## 8.1.1

* `Themed.reset`

## 8.0.2

* Version 8 and up are compatible with Flutter 3.27.0 and up. Note: Version 7.0.0 is
  not compatible with the new Flutter versions, but it will not throw any errors. It will
  just not work as expected. This means you MUST upgrade as soon as you upgrade your
  Flutter version:

  ```yaml
  dependencies:
    themed: ^8.0.1
  ``` 

## 7.0.0

* Theme change improvement: Now, when a theme is changed, it will make all color
  references different from themselves during exactly one frame. This will assure
  that all widgets that depend on the theme will be rebuilt with the new theme.
  While technically this is a breaking change, it's unlikely to affect you.

* `ColorRef.sameColor()` method to compare the current color of two `ColorRef` objects,
  or with a `Color` object. Note that the compared color is the effective one, that
  depend on the current theme.

* Fixed bug that affected Hot Reload.

## 5.1.1

* Added `Color.removeOpacity()` extension method.
  Note methods `addOpacity()`, `darker()`, `lighter()`, `average()` and `decolorize`
  already existed.

## 5.0.3

* Flutter 3.16.0 compatible.

## 4.0.0

* Flutter 3.13.0 compatible.

## 3.0.2

* Flutter 2.8.0 compatible.

## 2.4.0

* `ChangeColors` widget to change the brightness, saturation and hue of any widget,
  including images.

## 2.3.0

* Color extension: `darker`, `lighter`, `average`, `decolorize`, `addOpacity`,
  `rgbaToArgb` and `abgrToArgb` methods.

## 2.2.0

* Improved `ColorRef.toString()` and `TextStyleRef.toString()` methods.

## 2.1.0

* Saving and setting themes by key: `Themed.save()`, `Themed.setThemeByKey()` etc.

* Fixed https://github.com/marcglasberg/themed/issues/1

## 2.0.5

* Compatible with Flutter 2.5.

## 2.0.1

* Breaking change: The `id` now must only be provided if it's necessary to differentiate
  constants.

## 1.0.0

* Initial Commit.
