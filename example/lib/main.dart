import 'package:flutter/material.dart';
import 'package:themed/themed.dart';

/// This example demonstrates:
/// 1) The [Themed] package is compatible with [Theme] and [ThemeData].
/// 2) We can use the `const` keyword.
/// 3) An extension allows us to add a Color to a TextStyle.

////////////////////////////////////////////////////////////////////////////////////////////////////

class MyTheme {
  static const color1 = ColorRef('color1', Colors.white);
  static const color2 = ColorRef('color2', Colors.blue);
  static const color3 = ColorRef('color3', Colors.green);

  static const mainStyle = TextStyleRef(
    'mainStyle',
    TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: MyTheme.color1),
  );
}

Map<ThemeRef, Object> anotherTheme = {
  MyTheme.color1: Colors.yellow,
  MyTheme.color2: Colors.pink,
  MyTheme.color3: Colors.purple,
  MyTheme.mainStyle:
      const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: MyTheme.color1),
};

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Themed(
      child: MaterialApp(
        title: 'Themed example',
        //
        // 1) The [Themed] package is compatible with [Theme] and [ThemeData]:
        theme: ThemeData(
          primaryColor: MyTheme.color2,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(primary: MyTheme.color2),
          ),
        ),
        //
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //
        // 2) We can use the `const` keyword:
        title: const Text('Themed example', style: MyTheme.mainStyle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //
            // 2) We can use the `const` keyword:
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: MyTheme.color3,
                    child: const Text('This is some text!', style: MyTheme.mainStyle),
                  ),
                  //
                  const SizedBox(height: 30),
                  //
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: MyTheme.color3,
                    child: Text(
                      'This is another text!',
                      // 3) An extension allows us to add a Color to a TextStyle:
                      style: MyTheme.mainStyle + Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            //
            Container(width: double.infinity, height: 2, color: Colors.grey),
            //
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _button1(),
                  _button2(),
                  _button3(),
                ],
              ),
            ),
            //
          ],
        ),
      ),
    );
  }

  ElevatedButton _button1() {
    return ElevatedButton(
      onPressed: () {
        if (Themed.ifCurrentThemeIs(anotherTheme))
          Themed.clearCurrentTheme();
        else
          Themed.currentTheme = anotherTheme;
      },
      child: Text(
        Themed.ifCurrentThemeIs(anotherTheme) ? 'Back to default theme' : 'Apply another theme',
      ),
    );
  }

  ElevatedButton _button2() {
    return ElevatedButton(
      onPressed: () {
        if (Themed.ifCurrentTransformColorIs(ColorRef.shadesOfGreyTransform))
          Themed.clearTransformColor();
        else
          Themed.transformColor = ColorRef.shadesOfGreyTransform;
      },
      child: Text(
        Themed.ifCurrentTransformColorIs(ColorRef.shadesOfGreyTransform)
            ? 'Remove color transform'
            : 'Shades of grey transform',
      ),
    );
  }

  ElevatedButton _button3() {
    return ElevatedButton(
      onPressed: () {
        if (Themed.ifCurrentTransformTextStyleIs(largerText))
          Themed.clearTransformTextStyle();
        else
          Themed.transformTextStyle = largerText;
      },
      child: Text(
        Themed.ifCurrentTransformTextStyleIs(largerText)
            ? 'Remove font transform'
            : 'Larger font transform',
      ),
    );
  }

  static TextStyle largerText(TextStyle textStyle) =>
      textStyle.copyWith(fontSize: textStyle.fontSize! * 1.5);
}
