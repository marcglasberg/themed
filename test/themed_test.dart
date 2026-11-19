// ignore_for_file: deprecated_member_use

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:themed/themed.dart';

void main() {
  //
  const red = Color(0xFFFF0000);
  const green = Color(0xFF00FF00);
  const blue = Color(0xFF0000FF);

  const colorA = ColorRef(red, id: 'A');
  const colorB = ColorRef(green, id: 'B');
  const colorWithoutDefault = ColorRef.fromId('C');

  const styleA = TextStyleRef(TextStyle(fontSize: 10), id: 'A');
  const styleWithoutDefault = TextStyleRef.fromId('B');

  // The themes are global, so each test must leave them as it found them.
  tearDown(() {
    Themed.clearCurrentTheme();
    Themed.defaultTheme = null;
    Themed.clearTransformColor();
    Themed.clearTransformTextStyle();
  });

  group('ColorRef.', () {
    //
    test('Uses its default color when there are no themes.', () {
      expect(colorA.value, red.value);
      expect(colorA.toARGB32(), red.toARGB32());
      expect([colorA.a, colorA.r, colorA.g, colorA.b], [1.0, 1.0, 0.0, 0.0]);
    });

    test('Throws when the color is not defined anywhere.', () {
      expect(
          () => colorWithoutDefault.value, throwsA(isA<ConstThemeException>()));

      Themed.defaultTheme = {colorWithoutDefault: blue};
      expect(colorWithoutDefault.value, blue.value);
    });

    test('The current theme overrides the default theme.', () {
      Themed.defaultTheme = {colorA: green, colorB: blue};
      expect(colorA.value, green.value);
      expect(colorB.value, blue.value);

      Themed.currentTheme = {colorA: blue};
      expect(colorA.value, blue.value);
      expect(colorB.value, blue.value);
      expect(colorA.toARGB32(), blue.toARGB32());
      expect([colorA.a, colorA.r, colorA.g, colorA.b], [1.0, 0.0, 0.0, 1.0]);

      Themed.clearCurrentTheme();
      expect(colorA.value, green.value);

      Themed.defaultTheme = null;
      expect(colorA.value, red.value);
    });

    test('Applies the color transform.', () {
      Themed.transformColor = ColorRef.shadesOfGreyTransform;
      expect(colorA.value, 0xFF555555);
      expect(colorA.toARGB32(), 0xFF555555);

      Themed.clearTransformColor();
      expect(colorA.value, red.value);
    });

    test('Equality.', () {
      expect(colorA == colorA, isTrue);
      expect(colorA == colorB, isFalse);
      expect(colorA == red, isFalse); // ignore: unrelated_type_equality_checks

      // Not identical, but the same id, default color, and current color.
      final sameAsA = ColorRef(Color(red.value), id: 'A');
      expect(identical(colorA, sameAsA), isFalse);
      expect(colorA == sameAsA, isTrue);
      expect(colorA.hashCode, sameAsA.hashCode);

      // Different id or default color.
      expect(colorA == ColorRef(Color(red.value), id: 'X'), isFalse);
      expect(colorA == ColorRef(Color(blue.value), id: 'A'), isFalse);

      // The same id and default color, but a different current color.
      Themed.currentTheme = {sameAsA: blue};
      expect(colorA == sameAsA, isFalse);
    });

    test('Comparing different colors does not need them to be defined.', () {
      expect(colorWithoutDefault == colorA, isFalse);
      expect(colorA == colorWithoutDefault, isFalse);
    });

    test('sameColor compares the current colors.', () {
      expect(colorA.sameColor(red), isTrue);
      expect(colorA.sameColor(colorB), isFalse);

      Themed.currentTheme = {colorB: red};
      expect(colorA.sameColor(colorB), isTrue);
    });
  });

  group('TextStyleRef.', () {
    //
    test('Uses its default, the default theme, or the current theme.', () {
      expect(styleA.fontSize, 10);
      expect(() => styleWithoutDefault.fontSize,
          throwsA(isA<ConstThemeException>()));

      Themed.defaultTheme = {
        styleA: const TextStyle(fontSize: 20),
        styleWithoutDefault: const TextStyle(fontSize: 30),
      };
      expect(styleA.fontSize, 20);
      expect(styleWithoutDefault.fontSize, 30);

      Themed.currentTheme = {styleA: const TextStyle(fontSize: 40)};
      expect(styleA.fontSize, 40);
      expect(styleWithoutDefault.fontSize, 30);
    });

    test('Applies the text style transform.', () {
      Themed.transformTextStyle =
          (style) => style.copyWith(fontSize: style.fontSize! * 2);
      expect(styleA.fontSize, 20);
    });
  });

  group('Themed.ifCurrentThemeIs.', () {
    //
    test('Compares the given theme with the current one.', () {
      final themeA = <ThemeRef, Object>{
        colorA: blue,
        styleA: const TextStyle()
      };
      final themeB = <ThemeRef, Object>{
        colorA: green,
        styleA: const TextStyle()
      };

      expect(Themed.ifCurrentThemeIs({}), isTrue);
      expect(Themed.ifCurrentThemeIs(themeA), isFalse);

      Themed.currentTheme = themeA;
      expect(Themed.ifCurrentThemeIs(themeA), isTrue);
      expect(Themed.ifCurrentThemeIs(Map.of(themeA)), isTrue);
      expect(Themed.ifCurrentThemeIs(themeB), isFalse); // Another value.
      expect(Themed.ifCurrentThemeIs({}), isFalse); // Another length.
      expect(Themed.ifCurrentThemeIs({colorA: blue}), isFalse);
      expect(Themed.ifCurrentThemeIs({colorA: blue, colorB: const TextStyle()}),
          isFalse); // Another key.

      Themed.clearCurrentTheme();
      expect(Themed.ifCurrentThemeIs({}), isTrue);
      expect(Themed.ifCurrentThemeIs(themeA), isFalse);
    });

    test('Works with themes set by key.', () {
      final theme = <ThemeRef, Object>{colorA: blue};
      Themed.save(key: 'blue', theme: theme);
      addTearDown(Themed.clearSavedThemeByKey);

      Themed.setThemeByKey('blue');
      expect(Themed.ifCurrentThemeIs(theme), isTrue);
      expect(colorA.value, blue.value);
    });
  });

  testWidgets('Changing the theme rebuilds and repaints const widgets.',
      (tester) async {
    _BuildCounter.count = 0;
    await tester.pumpWidget(Themed(child: const _BuildCounter()));
    expect(_BuildCounter.count, 1);
    expect(find.byType(ColoredBox), paints..rect(color: red));

    Themed.currentTheme = {colorA: blue};
    await tester.pump();
    expect(_BuildCounter.count, 2);
    expect(find.byType(ColoredBox), paints..rect(color: blue));

    Themed.clearCurrentTheme();
    await tester.pump();
    expect(_BuildCounter.count, 3);
    expect(find.byType(ColoredBox), paints..rect(color: red));
  });

  // The current value of each color is cached, until the themes change.
  // Here, each color is read before each change, so that it's in the cache.
  group('ColorRef cache.', () {
    //
    test('Reading a color many times returns the same value.', () {
      Themed.defaultTheme = {colorA: green};
      for (int i = 0; i < 3; i++) {
        expect(colorA.value, green.value);
        expect([colorA.a, colorA.r, colorA.g, colorA.b], [1.0, 0.0, 1.0, 0.0]);
        expect(colorB.value, green.value);
      }
    });

    test('Follows the themes set by key.', () {
      addTearDown(Themed.clearSavedThemeByKey);
      expect(colorA.value, red.value);

      // The theme is only applied when it's saved.
      Themed.setThemeByKey('blue');
      expect(colorA.value, red.value);
      Themed.save(key: 'blue', theme: {colorA: blue});
      expect(colorA.value, blue.value);

      Themed.saveAll({
        'green': {colorA: green}
      });
      expect(colorA.value, blue.value);
      Themed.setThemeByKey('green');
      expect(colorA.value, green.value);
    });

    test('Follows a color that is defined as another theme color.', () {
      Themed.defaultTheme = {colorA: colorB};
      expect(colorA.value, green.value);
      expect(colorB.value, green.value);

      Themed.currentTheme = {colorB: blue};
      expect(colorA.value, blue.value);
      expect(colorB.value, blue.value);

      Themed.clearCurrentTheme();
      expect(colorA.value, green.value);
    });

    test('Is not used while there is a color transform.', () {
      Color toBlue(Color color) => blue;
      Color toGreen(Color color) => green;

      expect(colorA.value, red.value);

      Themed.transformColor = toBlue;
      expect(colorA.value, blue.value);
      expect(colorA.value, blue.value);

      Themed.transformColor = toGreen;
      expect(colorA.value, green.value);

      // The theme changes while there is a transform.
      Themed.transformColor = ColorRef.shadesOfGreyTransform;
      expect(colorA.value, 0xFF555555);
      Themed.currentTheme = {colorA: const Color(0xFF306090)};
      expect(colorA.value, 0xFF606060);

      Themed.clearTransformColor();
      expect(colorA.value, 0xFF306090);
      Themed.clearCurrentTheme();
      expect(colorA.value, red.value);
    });

    test('A transform that depends on something else is always applied.', () {
      Color target = blue;
      Themed.transformColor = (Color color) => target;
      expect(colorA.value, blue.value);

      target = green;
      expect(colorA.value, green.value);
    });

    test('Colors that are not const.', () {
      final colors = [
        for (int i = 0; i < 1000; i++) ColorRef(Color(0xFF000000 + i), id: 'A')
      ];
      for (int i = 0; i < colors.length; i++) {
        expect(colors[i].value, 0xFF000000 + i);
        expect(colors[i].value, 0xFF000000 + i);
      }

      Themed.currentTheme = {colors[7]: blue};
      expect(colors[6].value, 0xFF000006);
      expect(colors[7].value, blue.value);
    });

    test('Still works with more colors than the cache can hold.', () {
      final colors = [
        for (int i = 0; i < 2000; i++) ColorRef(Color(0xFF000000 + i), id: 'A')
      ];
      for (int round = 0; round < 2; round++) {
        for (int i = 0; i < colors.length; i++) {
          expect(colors[i].value, 0xFF000000 + i);
        }
      }

      // Both the colors that fit in the cache (the first ones that were read),
      // and the ones that don't, follow the themes.
      Themed.currentTheme = {colors[0]: blue, colors[1999]: green};
      expect(colors[0].value, blue.value);
      expect(colors[1].value, 0xFF000001);
      expect(colors[1999].value, green.value);

      Themed.defaultTheme = {colors[1998]: red};
      expect(colors[1998].value, red.value);
      expect(colors[1999].value, green.value);

      Themed.clearCurrentTheme();
      expect(colors[0].value, 0xFF000000);
      expect(colors[1999].value, 0xFF000000 + 1999);
    });

    test('A color that is not defined is not cached.', () {
      expect(
          () => colorWithoutDefault.value, throwsA(isA<ConstThemeException>()));
      Themed.currentTheme = {colorWithoutDefault: blue};
      expect(colorWithoutDefault.value, blue.value);
      Themed.clearCurrentTheme();
      expect(
          () => colorWithoutDefault.value, throwsA(isA<ConstThemeException>()));
    });

    testWidgets('Follows the themes given to the Themed widget.',
        (tester) async {
      expect(colorA.value, red.value);

      await tester.pumpWidget(Themed(
        defaultTheme: {colorA: green},
        child: const SizedBox(),
      ));
      expect(colorA.value, green.value);

      await tester.pumpWidget(Themed(
        defaultTheme: {colorA: green},
        currentTheme: {colorA: blue},
        child: const SizedBox(),
      ));
      expect(colorA.value, blue.value);

      await tester.pumpWidget(Themed(
        defaultTheme: {colorA: blue},
        currentTheme: {colorA: green},
        child: const SizedBox(),
      ));
      expect(colorA.value, green.value);
    });

    testWidgets('Follows the themes set with Themed.of(context).',
        (tester) async {
      await tester.pumpWidget(Themed(child: const SizedBox()));
      final themed = Themed.of(tester.element(find.byType(SizedBox)));
      expect(colorA.value, red.value);

      themed.defaultTheme = {colorA: green};
      expect(colorA.value, green.value);

      themed.currentTheme = {colorA: blue};
      expect(colorA.value, blue.value);

      themed.transformColor = ColorRef.shadesOfGreyTransform;
      expect(colorA.value, 0xFF555555);

      themed.clearTransformColor();
      expect(colorA.value, blue.value);

      themed.clearCurrentTheme();
      expect(colorA.value, green.value);

      themed.defaultTheme = null;
      expect(colorA.value, red.value);
      await tester.pump();
    });
  });

  group('Color swatches.', () {
    //
    test('MaterialColorSwatch has the channels of its primary color.', () {
      const swatch = MaterialColorSwatch(colorA, {500: colorA});
      expect(swatch.value, red.value);
      expect(swatch.toARGB32(), red.toARGB32());
      expect([swatch.a, swatch.r, swatch.g, swatch.b], [1.0, 1.0, 0.0, 0.0]);
      expect(Paint()..color = swatch,
          isA<Paint>().having((p) => p.color, 'color', red));

      Themed.currentTheme = {colorA: blue};
      expect(swatch.value, blue.value);
      expect([swatch.a, swatch.r, swatch.g, swatch.b], [1.0, 0.0, 0.0, 1.0]);
    });

    test('MaterialAccentColorSwatch has the channels of its primary color.',
        () {
      const swatch = MaterialAccentColorSwatch(green, {400: green});
      expect(swatch.value, green.value);
      expect(swatch.toARGB32(), green.toARGB32());
      expect([swatch.a, swatch.r, swatch.g, swatch.b], [1.0, 0.0, 1.0, 0.0]);
      expect(Paint()..color = swatch,
          isA<Paint>().having((p) => p.color, 'color', green));
    });
  });
}

/// A const widget that counts how many times it was built.
class _BuildCounter extends StatelessWidget {
  const _BuildCounter();

  static int count = 0;

  @override
  Widget build(BuildContext context) {
    count++;
    return const ColoredBox(
      color: ColorRef(Color(0xFFFF0000), id: 'A'),
      child: SizedBox.expand(),
    );
  }
}
