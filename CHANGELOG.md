Sponsored by [MyText.ai](https://mytext.ai)

[![](./example/SponsoredByMyTextAi.png)](https://mytext.ai)

## 8.0.0

* Version 8.0.0 is compatible with Flutter 3.27.0 and up. Note: Version 7.0.0 is not
  compatible with the new Flutter versions, but it will not throw any errors. It will
  just not work as expected. This means you MUST upgrade to the current version 8.0.0 as
  soon as you upgrade your Flutter version:

  ```yaml
  dependencies:
    themed: ^8.0.0
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
