import 'package:flutter/material.dart';
import 'package:themed/themed.dart';

/// This example demonstrates:
/// 1) The [Themed] package is compatible with [Theme] and [ThemeData].
/// 2) We can use the `const` keyword.
/// 3) An extension allows us to add a Color to a TextStyle.
class AppColors {
  static const primary = ColorRef('warning', Colors.blue);
  static const accent = ColorRef('accent', Colors.blueGrey);
  static const secondary = ColorRef('secondary', Colors.white);
  static const regular = ColorRef('body', Colors.black);
  static const warning = ColorRef('warning', Colors.red);
}

class AppTextStyle {
  static const title = TextStyleRef(
    'title',
    TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.secondary,
    ),
  );

  static const body = TextStyleRef(
    'title',
    TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      color: AppColors.regular,
    ),
  );

  static const number = TextStyleRef(
    'title',
    TextStyle(
      fontSize: 38,
      fontWeight: FontWeight.w600,
      color: AppColors.warning,
    ),
  );
}

Map<ThemeRef, Object> theme1 = {
  AppColors.primary: Colors.pink,
  AppColors.accent: Colors.purple,
  AppColors.secondary: Colors.green,
  AppColors.regular: Colors.brown,
  AppColors.warning: Colors.red,
  AppTextStyle.title: const TextStyle(
    fontSize: 26 * .7,
    fontWeight: FontWeight.w700,
    color: Colors.green,
  ),
  AppTextStyle.body: const TextStyle(
    fontSize: 17 * .7,
    fontWeight: FontWeight.w400,
    color: Colors.brown,
  ),
  AppTextStyle.number: const TextStyle(
    fontSize: 38 * .7,
    fontWeight: FontWeight.w600,
    color: Colors.red,
  ),
};

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Themed(
      child: MaterialApp(
        title: 'Flutter Demo',
        //
        // 1) The [Themed] package is compatible with [Theme] and [ThemeData]:
        theme: ThemeData(
          primaryColor: AppColors.primary,
          accentColor: AppColors.accent,
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //
        // 2) We can use the `const` keyword:
        title: const Text('Themed example', style: AppTextStyle.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //
            // 2) We can use the `const` keyword:
            const Text('You have pushed the button this many times:', style: AppTextStyle.body),
            //
            Text('$_counter', style: AppTextStyle.number),
            const SizedBox(height: 30),
            //
            ElevatedButton(
                onPressed: () {
                  Themed.currentTheme = theme1;
                },
                child: const Text('Theme 1')),
            //
            const ElevatedButton(
                onPressed: Themed.clearCurrentTheme, child: const Text('Default Theme')),
            //
            ElevatedButton(
              onPressed: () {
                if (Themed.ifCurrentTransformColorIs(ColorRef.shadesOfGreyTransform))
                  Themed.clearTransformColor();
                else
                  Themed.transformColor = ColorRef.shadesOfGreyTransform;
              },
              child: Text(
                Themed.ifCurrentTransformColorIs(ColorRef.shadesOfGreyTransform)
                    ? 'Remove transform'
                    : 'Shades of grey transform',
              ),
            ),
            //
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        //
        // 3) An extension allows us to add a Color to a TextStyle:
        child: Text('+', style: AppTextStyle.number + AppColors.secondary),
      ),
    );
  }
}
