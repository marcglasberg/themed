import 'package:flutter/material.dart';
import 'package:themed/themed.dart';

/// This example demonstrates:
/// 1) The [Themed] package is compatible with [Theme] and [ThemeData].
/// 2) We can use the `const` keyword.
/// 3) An extension allows us to add a Color to a TextStyle.

class MyTheme {
  static const color1 = ColorRef(Colors.white);
  static const color2 = ColorRef(Colors.blue);
  static const color3 = ColorRef(Colors.green);

  static const mainStyle = TextStyleRef(
    TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: MyTheme.color1),
  );
}

Map<ThemeRef, Object> anotherTheme = {
  MyTheme.color1: Colors.yellow,
  MyTheme.color2: Colors.pink,
  MyTheme.color3: Colors.purple,
  MyTheme.mainStyle: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: MyTheme.color1,
  ),
};

Map<ThemeRef, Object> yellowTheme = {
  MyTheme.color1: Colors.yellow[200]!,
  MyTheme.color2: Colors.yellow[600]!,
  MyTheme.color3: Colors.yellow[900]!,
  MyTheme.mainStyle: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: MyTheme.color1,
  ),
};

const Widget space16 = SizedBox(width: 16, height: 16);
final Widget divider = Container(width: double.infinity, height: 2, color: Colors.grey);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Themed(
      child: MaterialApp(
        title: 'Themed example',
        debugShowCheckedModeBanner: false,
        //
        // 1) The [Themed] package is compatible with [Theme] and [ThemeData]:
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: MyTheme.color1,
              backgroundColor: Colors.blue,
            ),
          ),
        ),
        //
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.color2,
        //
        // 2) We can use the `const` keyword:
        title: const Text('Themed example', style: MyTheme.mainStyle),
      ),
      body: const HomePageContent(),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Click to navigate:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: MyTheme.color3,
            ),
          ),
          //
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ColorSettingsPage(),
                ),
              );
            },
            child: const Text('Open Color Settings Page'),
          ),
          //
        ],
      ),
    );
  }
}

class ColorSettingsPage extends StatefulWidget {
  @override
  _ColorSettingsPageState createState() => _ColorSettingsPageState();
}

class _ColorSettingsPageState extends State<ColorSettingsPage> {
  bool _usingStaticMethod = false;

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.color2,
        //
        // 2) We can use the `const` keyword:
        title: const Text('Color Settings Page', style: MyTheme.mainStyle),
      ),
      body: Column(
        children: [
          const ExampleText(),
          //
          SwitchListTile(
            title: _usingStaticMethod
                ? const Text('Themed.[static method]')
                : const Text('Themed.of(context)'),
            value: _usingStaticMethod,
            onChanged: (bool value) {
              setState(() {
                _usingStaticMethod = value;
              });
            },
          ),
          //
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    _usingStaticMethod ? _usingThemedStaticMethod() : _usingThemedOf(ctx),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column _usingThemedOf(BuildContext ctx) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        space16,
        //
        ElevatedButton(
          onPressed: () => Themed.of(ctx).currentTheme = anotherTheme,
          child: const Text('Themed.of(ctx).currentTheme = anotherTheme'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.of(ctx).currentTheme = null,
          child: const Text('Themed.of(ctx).currentTheme = null'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.of(ctx).clearCurrentTheme(),
          child: const Text('Themed.of(ctx).clearCurrentTheme()'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.of(ctx).defaultTheme = yellowTheme,
          child: const Text('Themed.of(ctx).defaultTheme = yellowTheme'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.of(ctx).defaultTheme = null,
          child: const Text('Themed.of(ctx).defaultTheme = null'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.of(ctx).transformColor = ColorRef.shadesOfGreyTransform,
          child: const Text(
              'Themed.of(ctx).transformColor = ColorRef.shadesOfGreyTransform',
              textAlign: TextAlign.center),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.of(ctx).transformColor = null,
          child: const Text('Themed.of(ctx).transformColor = null'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.of(ctx).clearTransformColor(),
          child: const Text('Themed.of(ctx).clearTransformColor()'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.of(ctx).transformTextStyle = largerText,
          child: const Text('Themed.of(ctx).transformTextStyle = largerText',
              textAlign: TextAlign.center),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.of(ctx).transformTextStyle = null,
          child: const Text('Themed.of(ctx).transformTextStyle = null'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.of(ctx).clearTransformTextStyle(),
          child: const Text('Themed.of(ctx).clearTransformTextStyle()'),
        ),
        //
        space16,
        Text(
            'Themed.of(ctx).ifCurrentThemeIs({}) == ${Themed.of(ctx).ifCurrentThemeIs({})}'),
        space16,
        Text(
            'Themed.of(ctx).ifCurrentThemeIs(anotherTheme) == ${Themed.of(ctx).ifCurrentThemeIs(anotherTheme)}'),
        space16,
        Text(
            'Themed.of(ctx).ifCurrentThemeIs(yellowTheme) == ${Themed.of(ctx).ifCurrentThemeIs(yellowTheme)}'),
        space16,
        Text(
            'Themed.of(ctx).ifCurrentTransformColorIs(null) == ${Themed.of(ctx).ifCurrentTransformColorIs(null)}'),
        space16,
        Text(
            'Themed.of(ctx).ifCurrentTransformColorIs(ColorRef.shadesOfGreyTransform) == ${Themed.of(ctx).ifCurrentTransformColorIs(ColorRef.shadesOfGreyTransform)}'),
        space16,
        Text(
            'Themed.of(ctx).ifCurrentTransformTextStyleIs(null) == ${Themed.of(ctx).ifCurrentTransformTextStyleIs(null)}'),
        space16,
        Text(
            'Themed.of(ctx).ifCurrentTransformTextStyleIs(largerText) == ${Themed.of(ctx).ifCurrentTransformTextStyleIs(largerText)}'),
        space16,
      ],
    );
  }

  Column _usingThemedStaticMethod() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        space16,
        //
        ElevatedButton(
          onPressed: () => Themed.currentTheme = anotherTheme,
          child: const Text('Themed.currentTheme = anotherTheme'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.currentTheme = null,
          child: const Text('Themed.currentTheme = null'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.clearCurrentTheme(),
          child: const Text('Themed.clearCurrentTheme()'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.defaultTheme = yellowTheme,
          child: const Text('Themed.defaultTheme = yellowTheme'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.defaultTheme = null,
          child: const Text('Themed.defaultTheme = null'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.transformColor = ColorRef.shadesOfGreyTransform,
          child: const Text('Themed.transformColor = ColorRef.shadesOfGreyTransform',
              textAlign: TextAlign.center),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.transformColor = null,
          child: const Text('Themed.transformColor = null'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.clearTransformColor(),
          child: const Text('Themed.clearTransformColor()'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.transformTextStyle = largerText,
          child: const Text('Themed.transformTextStyle = largerText',
              textAlign: TextAlign.center),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.transformTextStyle = null,
          child: const Text('Themed.transformTextStyle = null'),
        ),
        //
        ElevatedButton(
          onPressed: () => Themed.clearTransformTextStyle(),
          child: const Text('Themed.clearTransformTextStyle()'),
        ),
        //
        space16,
        Text('Themed.ifCurrentThemeIs({}) == ${Themed.ifCurrentThemeIs({})}'),
        space16,
        Text(
            'Themed.ifCurrentThemeIs(anotherTheme) == ${Themed.ifCurrentThemeIs(anotherTheme)}'),
        space16,
        Text(
            'Themed.ifCurrentThemeIs(yellowTheme) == ${Themed.ifCurrentThemeIs(yellowTheme)}'),
        space16,
        Text(
            'Themed.ifCurrentTransformColorIs(null) == ${Themed.ifCurrentTransformColorIs(null)}'),
        space16,
        Text(
            'Themed.ifCurrentTransformColorIs(ColorRef.shadesOfGreyTransform) == ${Themed.ifCurrentTransformColorIs(ColorRef.shadesOfGreyTransform)}'),
        space16,
        Text(
            'Themed.ifCurrentTransformTextStyleIs(null) == ${Themed.ifCurrentTransformTextStyleIs(null)}'),
        space16,
        Text(
            'Themed.ifCurrentTransformTextStyleIs(largerText) == ${Themed.ifCurrentTransformTextStyleIs(largerText)}'),
        space16,
      ],
    );
  }

  static TextStyle largerText(TextStyle textStyle) =>
      textStyle.copyWith(fontSize: textStyle.fontSize! * 1.5);
}

class ExampleText extends StatelessWidget {
  const ExampleText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 135),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Column(
              children: [
                Container(
                  color: MyTheme.color3,
                  child: const Text(
                    'This is some text!',
                    style: MyTheme.mainStyle,
                  ),
                ),
                space16,
                Container(
                  color: MyTheme.color3,
                  child: Text(
                    'This is another text!',
                    // 3) An extension allows us to add a Color to a TextStyle:
                    style: MyTheme.mainStyle + Colors.black,
                  ),
                ),
              ],
            ),
            const Spacer(),
            divider,
          ],
        ),
      ),
    );
  }
}
