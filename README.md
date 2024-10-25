[![pub package](https://img.shields.io/pub/v/themed.svg)](https://pub.dartlang.org/packages/themed)

# themed

The **Themed** package:

* Lets you define a theme with **const** values, but change them dynamically anyway.
* `ChangeColors` widget to change the brightness, saturation and hue of widgets or images.
* Color extension methods: `Colors.blue.decolorize()` and more.
* TextStyle extension methods: `var myStyle = TextStyle(fontSize: 15) + Colors.blue` and
  more.

## Const values that you can change

As we all know, using const variables is the easiest way to create and use themes:

```
static const myColor = Colors.white;
static const myStyle = TextStyle(fontSize: 16);

Container(
  color: myColor,
  child: const Text('Hi', style: myStyle)))
```

However, if you do it like that you can't later change the theme dynamically.
By using the **Themed** package you can:

```
static const myColor = ColorRef(Colors.white); 
static const myStyle = TextStyleRef(TextStyle(fontSize: 16)); 

Container(
   color: myColor,
   child: const Text('Hello', style: myStyle)))
   
// Later, change the theme dynamically.
Themed.currentTheme = {
   myColor: Colors.blue,
   myStyle: TextStyle(fontSize: 20);
}      
```

![](https://raw.githubusercontent.com/marcglasberg/themed/master/example/lib/images/themed.png)

There is no need to use `Theme.of(context)` anymore:

```
// So old-fashioned. 
Container(
   color: Theme.of(context).primary,
   child: Text('Hello', style: TextStyle(color: Theme.of(context).secondary)))
```

Also, since `Theme.of` needs the `context` and is not constant, you can't use it in
constructors. However, the *Themed* package has no such limitations:

```
// The const color is the default value of an optional parameter.
MyWidget({
    this.color = myColor,
  });
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

# Compatibility

The *Themed* package is a competitor to writing `Theme.of(context).xxx` in your build
methods, but it’s *NOT* a competitor to Flutter’s native theme system and the `Theme`
widget. It’s there to solve a different problem, and it’s usually used together with
the `Theme` widget. For example, if you want to set a global default color for all
buttons, you’ll use the `Theme` widget. You may use it together with the `Themed`
package however, meaning that `Themed` colors and styles may be used inside
a `ThemeData` widget:

```
static const myColor1 = ColorRef(Colors.red);
static const myColor2 = ColorRef(Colors.blue);
...

child: MaterialApp(
   theme: ThemeData(
      primaryColor: MyTheme.color2,
      elevatedButtonTheme: 
         ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(primary: MyTheme.color2),
      ),
   ),
```                   

## How to define a theme map

Each theme should be a `Map<ThemeRef, Object>`, where the **keys** are your `ColorRef`
and `TextStyleRef` const values, and the **values** are the colors and styles you want to
use on that theme. For example:

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
// Setting a theme:
Themed.currentTheme = theme1;

// Setting another theme:
Themed.currentTheme = theme2;

// Removing the current theme (and falling back to the default theme):
Themed.clearCurrentTheme();

// This would also remove the current theme:
Themed.currentTheme = null;
```

# Organization

You can also organize your theme in a class:

```
class MyTheme {
   static const myColor = ColorRef(Colors.white); 
   static const myStyle = TextStyleRef(TextStyle(fontSize: 16, color: Colors.red)); 
}

Container(
   color: MyTheme.myColor,
   child: const Text('Hello', style: MyTheme.myStyle)))    
```

# Color transform

Instead of changing the current theme you can create a **color transformation**.
For example, this will turn your theme into shades of grey:

```
static Color shadesOfGreyTransform(Color color) {
  int average = (color.red + color.green + color.blue) ~/ 3;
  return Color.fromARGB(color.alpha, average, average, average);
}
```

Note you can create your own function to process colors, but `shadesOfGreyTransform` is
already provided:

```
// Turn it on:
Themed.transformColor = ColorRef.shadesOfGreyTransform;

// Then, later, turn it off:
Themed.clearTransformColor();
```

# Changing brightness, saturation and hue of widgets or images.

Use the provided `ChangeColors` widget to change the brightness, saturation and hue of any
widget, including images. Example:

```
ChangeColors(
   hue: 0.55,
   brightness: 0.2,
   saturation: 0.1,
   child: Image.asset('myImage.png'),
);
```

To achieve a greyscale effect, you may also use the `ChangeColors.greyscale` constructor.

_Note: This widget is based upon
<a href="https://stackoverflow.com/questions/64639589/how-to-adjust-hue-saturation-and-brightness-of-an-image-in-flutter">
this code</a> (from <a href="https://stackoverflow.com/users/937841/banananeil">
BananaNeil's</a>), which is in turn based
upon <a href='https://stackoverflow.com/a/7917978/937841'>
this code</a> (by <a href="https://stackoverflow.com/users/812976/richard-lalancette">
Richard Lalancette</a>)._

# Color extension

The `lighter` method makes the color lighter (more white). Example:

```
// 20% more white.
Colors.blue.lighter(0.2); 
```

The `darker` method makes the color darker (more black). Example:

```
// 20% more black.
Colors.blue.darker(0.2); 
```

The `average` method makes the current color more similar to the given `color`. Example:

```
// 50% blue and 50% red.
Colors.blue.average(Colors.red); 

// 20% blue and 80% red.
Colors.blue.average(Colors.red, 0.8);
```

The `decolorize` method makes the current color more grey. Example:

```
// Grey, with luminance similar to the original blue.
Colors.blue.decolorize(); 

// Blue with 20% less color.
Colors.blue.decolorize(0.2);
```

The `addOpacity` method makes the current color more transparent than it already is, by
the given amount. The `removeOpacity` method makes the current color less transparent than
it already is, by the given amount. This is different from the `withOpacity` method,
as you can see below.

```
// 50% transparent blue.
Colors.blue.addOpacity(0.5); 

// 80% transparent black.
Colors.transparent.removeOpacity(0.2); 

// Also 50% transparent blue.
Colors.withOpacity(0.5); 

// 75% transparent blue, because we add 50% and then more 50%.
Colors.blue.addOpacity(0.5).addOpacity(0.5);

// This is 50% transparent blue, because the opacity is replaced, not added.
Colors.withOpacity(0.5).withOpacity(0.5);
```

There are also two methods for advanced color representation conversion: The `rgbaToArgb`
method converts the RGBA color representation to ARGB. The `abgrToArgb` method
converts the ABGR color representation to ARGB.

# TextStyle transform

You can also create a **style transformation**. For example, this will make your fonts
larger:

```
static TextStyle largerText(TextStyle textStyle) =>
      textStyle.copyWith(fontSize: textStyle.fontSize! * 1.5);

// Turn it on:
Themed.transformTextStyle = largerText;

// Then, later, turn it off:
Themed.clearTransformTextStyle();
```

# TextStyle extension

With the provided extension, you can make your code more clean-code by creating new text
styles by adding colors and other values to a `TextStyle`. For example:

```
const myStyle = TextStyle(...);

// Using some style:
Text('Hello', style: myStyle);

// Making text black:
Text('Hello', style: myStyle + Colors.black);

// Changing some other stuff:
Text('Hello', style: myStyle + FontWeight.w900 + FontSize(20.0) + TextHeight(1.2));
```

# Beware not to define the same constant

Please remember Dart constants point to the same memory space.
In this example, `colorA`, `colorB` and `colorC` represent the same variable:

```
class MyTheme {
  static const colorA = ColorRef(Colors.white);
  static const colorB = ColorRef(Colors.white);
  static const colorC = colorA;    
}
```

If you later change the color of `colorA`, you are also automatically changing the color
of `colorB` and `colorB`.

If you want to create 3 independent colors, and be able to change them independently, you
have to create different constants. You can provide an `id` string, just to
differentiate them. For example:

```
class MyTheme {
  static const colorA = ColorRef(Colors.white, id:'A');
  static const colorB = ColorRef(Colors.white, id:'B');
  static const colorB = ColorRef(colorA, id:'C');
}
```

# Avoid circular dependencies

The following will lead to a `StackOverflowError` error:

```
Map<ThemeRef, Object> anotherTheme = {
   MyTheme.color1: MyTheme.color2,
   MyTheme.color2: MyTheme.color1,
};
```

You can have references which depend on other references, no problem. But both direct and
indirect circular references must be avoided.

# Other ways to use it

If you want, you may also define a **default** theme, and a **current** theme for your
app:

```
@override
Widget build(BuildContext context) {
   return Themed(
      defaultTheme: { ... },
      currentTheme: { ... },
      child: MaterialApp(
        ...      
```

The `defaultTheme` and `currentTheme` are both optional. They are simply theme maps, as
explained below.

When a color/style is used, it will first search it inside the `currentTheme`.

If it's not found there, it searches inside of `defaultTheme`.

If it's still not found there, it uses the default color/style which was defined in the
constructor. For example, here the default color is white: `ColorRef(Colors.white)`.

Please note: If you define all your colors in the `defaultTheme`, then you don't need to
provide default values in the constructor. You can then use the `fromId` constructor:

```
class MyTheme {
  static const color1 = ColorRef.fromId('c1');
  static const color2 = ColorRef.fromId('c2');
  static const color3 = ColorRef.fromId('c3');
  static const mainStyle = TextStyleRef.fromId('mainStyle');  
}
```

## Saving and setting Themes by key

You can save themes with keys, and then later use the keys to set the theme. The keys can
be anything (Strings, enums etc.):

```
// Save some themes using keys.
enum Keys {light, dark};
Themed.save(key: Keys.light, theme: { ... })
Themed.save(key: Keys.dark, theme: { ... })

// Then set the theme.
Themed.setThemeByKey(Keys.light);
```

It also works the other way around:
If you use the key first, and only save a theme with that key later:

```
// Set the theme with a key, even before saving the theme.
Themed.setThemeByKey(Keys.light);

// The theme will change as soon as you save a theme with that key.
Themed.save(key: Keys.light, theme: { ... })
```

Note: You can also use the methods `saveAll` to save many themes by key at the same time,
and `clearSavedThemeByKey` to remove saved themes.

Important: When I say "save" above, I mean it's saved in memory, not in the device disk.

---

# Copyright

**This package is copyrighted and brought to you
by <a href="https://www.parksidesecurities.com/">
Parkside Technologies</a>, a company which is simplifying global access to US stocks.**

This package is published here with permission.

Please, see the license page for more information.

***

*The Flutter packages I've authored:*

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
* <a href="https://pub.dev/packages/themed">themed</a>
* <a href="https://pub.dev/packages/bdd_framework">bdd_framework</a>

*My Medium Articles:*

* <a href="https://medium.com/flutter-community/https-medium-com-marcglasberg-async-redux-33ac5e27d5f6">
  Async Redux: Flutter’s non-boilerplate version of Redux</a> 
  (versions: <a href="https://medium.com/flutterando/async-redux-pt-brasil-e783ceb13c43">
  Português</a>)
* <a href="https://medium.com/flutter-community/i18n-extension-flutter-b966f4c65df9">
  i18n_extension</a> 
  (versions: <a href="https://medium.com/flutterando/qual-a-forma-f%C3%A1cil-de-traduzir-seu-app-flutter-para-outros-idiomas-ab5178cf0336">
  Português</a>)
* <a href="https://medium.com/flutter-community/flutter-the-advanced-layout-rule-even-beginners-must-know-edc9516d1a2">
  Flutter: The Advanced Layout Rule Even Beginners Must Know</a> 
  (versions: <a href="https://habr.com/ru/post/500210/">русский</a>)
* <a href="https://medium.com/flutter-community/the-new-way-to-create-themes-in-your-flutter-app-7fdfc4f3df5f">
  The New Way to create Themes in your Flutter App</a> 

*My article in the official Flutter documentation*:

* <a href="https://flutter.dev/docs/development/ui/layout/constraints">Understanding
  constraints</a>

<br>_Marcelo Glasberg:_<br>

<a href="https://github.com/marcglasberg">_github.com/marcglasberg_</a>
<br>
<a href="https://www.linkedin.com/in/marcglasberg/">_linkedin.com/in/marcglasberg/_</a>
<br>
<a href="https://twitter.com/glasbergmarcelo">_twitter.com/glasbergmarcelo_</a>
<br>
<a href="https://stackoverflow.com/users/3411681/marcg">
_stackoverflow.com/users/3411681/marcg_</a>
<br>
<a href="https://medium.com/@marcglasberg">_medium.com/@marcglasberg_</a>
<br>
