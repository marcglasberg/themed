# themed

By using some dark Dart magic, the **themed** package lets you define a theme with
**const** values, and then go and change them dynamically anyway.

To convince yourself it works, please run the provided example.

This is the easiest possible way to create and use themes:

```
class MyTheme {
   static const someColor = ... 
   static const someStyle = ... 
}

Container(
   color: MyTheme.someColor,
   child: const Text('Hello', style: MyTheme.someStyle)),
)
```

There is no need to use `Theme.of(context)` anymore:

```
// So old-fashioned! 
Container(
   color: Theme.of(context).primary,
   child: Text('Hello', style: TextStyle(color: Theme.of(context).secondary)),
)
```

Since `Theme.of` needs the `context`, you can also NOT use it in constructors. However, the *themed*
package has no such limitations:

```
// The const color is the default value of an optional parameter.
MyWidget({
    this.color = MyTheme.someColor,
  });

```

---

# How to use it

Start by defining your default colors and styles by using `ColorRef` instead of `Color`,
and `TextStyleRef` instead of `TextStyle`.

The `ColorRef` extends `Color`, and it takes a "reference" identifier which should be unique, and a
default color. For example:

```
ColorRef('color1', Colors.white);
```

The `TextStyleRef` extends `TextStyle`, and it takes a "reference" identifier which should be
unique, and a default style. For example:

```
TextStyleRef('mainStyle', TextStyle(fontSize: 16, color: Colors.red));
```

Putting it all together:

```
class MyTheme {
  static const color1 = ColorRef('color1', Colors.white);
  static const color2 = ColorRef('color2', Colors.blue);
  static const color3 = ColorRef('color3', Colors.green);
  static const mainStyle = TextStyleRef('mainStyle', TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.color1);  
}
```

Now you can just use these colors and styles normally, inside `Container`s, `Text`s etc, and even
inside a `ThemeData` widget:

```
child: MaterialApp(
   theme: ThemeData(
      primaryColor: MyTheme.color2,
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(primary: MyTheme.color2),
      ),
   ),
```

                   
---

# Setup

Wrap your widget tree with the `Themed` widget, above the `MaterialApp`:

```
@override
Widget build(BuildContext context) {
   return Themed(
      child: MaterialApp(
        ...      
```

If you want, you may also define a **default** theme, and a **current** theme:

```
@override
Widget build(BuildContext context) {
   return Themed(
      defaultTheme: { ... },
      currentTheme: { ... },
      child: MaterialApp(
        ...      
```

The `defaultTheme` and `currentTheme` are simply theme maps, as explained below.

When a color/style is used, it will first search it inside of the `currentTheme`.

If it's not found there, it searches inside of `defaultTheme`.

If it's still not found there, it uses the default color/style which was defined in the constructor.
For example, here the default color is `white`:

```
ColorRef('color1', Colors.white);
```

## How to define a theme map

Each theme should be a `Map<ThemeRef, Object>`, where the keys are your `ColorRef`
and `TextStyleRef` const values, and the values are the colors and styles you want to use on that
theme. For example:

```
Map<ThemeRef, Object> theme1 = {
  MyTheme.color1: Colors.yellow,
  MyTheme.color2: Colors.pink,
  MyTheme.color3: Colors.purple,
  MyTheme.mainStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: MyTheme.color1),
};
```

At any point in your app you can just change the current theme by doing:

```
// Then, later:
Themed.currentTheme = theme1;

// Then, later:
Themed.currentTheme = theme2;

// Removing the current theme (and falling back to the default theme):
Themed.clearCurrentTheme();

// This would also remove the current theme:
Themed.currentTheme = null;
```

# Color transform

Instead of changing the current theme you can create a color transformation. For example, this will
turn your theme into shades of grey:

```
static Color shadesOfGreyTransform(Color color) {
  int average = (color.red + color.green + color.blue) ~/ 3;
  return Color.fromARGB(color.alpha, average, average, average);
}
```

Note you can create your own function to process colors, but `shadesOfGreyTransform` is already
provided:

```
// Turn it on:
Themed.transformColor = ColorRef.shadesOfGreyTransform;

// Then, later, turn it off:
Themed.clearTransformColor();
```

# TextStyle transform

You can also create on a style transformation. For example, this will make your fonts larger:

```
static TextStyle largerText(TextStyle textStyle) =>
      textStyle.copyWith(fontSize: textStyle.fontSize! * 1.5);

// Turn it on:
Themed.transformTextStyle = largerText;

// Then, later, turn it off:
Themed.clearTransformTextStyle();
```

# TextStyle extension

With the provided extension, you can make your code more clean-code by creating new text styles by
adding colors and other values to a `TextStyle`. For example:

```
// Using some style:
Text('Hello', style: MyTheme.mainStyle);

// Making text black:
Text('Hello', style: MyTheme.mainStyle + Colors.black);

// Changing a lot of other stuff:
Text('Hello', style: MyTheme.mainStyle + FontWeight.w900 + FontSize(20.0) + TextHeight(1.2));
```

---

# Copyright

This package is copyrighted and brought to you by <a href="https://www.parksidesecurities.com/">
Parkside Technologies</a>, a company which is simplifying global access to US stocks.
              
This package is published here with permission.

Please, see the license page for more information.

***

**Authored by Marcelo Glasberg**

*Other Flutter packages I've authored:*

* <a href="https://pub.dev/packages/async_redux">async_redux</a>
* <a href="https://pub.dev/packages/provider_for_redux">provider_for_redux</a>
* <a href="https://pub.dev/packages/i18n_extension">i18n_extension</a>
* <a href="https://pub.dev/packages/align_positioned">align_positioned</a>
* <a href="https://pub.dev/packages/network_to_file_image">network_to_file_image</a>
* <a href="https://pub.dev/packages/image_pixels">image_pixels</a>
* <a href="https://pub.dev/packages/matrix4_transform">matrix4_transform</a>
* <a href="https://pub.dev/packages/back_button_interceptor">back_button_interceptor</a>
* <a href="https://pub.dev/packages/indexed_list_view">indexed_list_view</a>
* <a href="https://pub.dev/packages/animated_size_and_fade">animated_size_and_fade</a>
* <a href="https://pub.dev/packages/assorted_layout_widgets">assorted_layout_widgets</a>
* <a href="https://pub.dev/packages/weak_map">weak_map</a>
* <a href="https://pub.dev/packages/fast_immutable_collections">fast_immutable_collections</a>

