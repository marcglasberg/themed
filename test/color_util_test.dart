// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themed/themed.dart';

/// The color methods read each color only once, to be fast. Here we check that
/// they return exactly the same colors as their plain definitions, given below.
void main() {
  // The static methods of `Themed` need the binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  double limit(double value) => (value < 0) ? 0 : (value > 1 ? 1 : value);

  Color lighter(Color c, double value) =>
      Color.lerp(c, Colors.white, limit(value))!.withAlpha(c.alpha);

  Color darker(Color c, double value) =>
      Color.lerp(c, Colors.black, limit(value))!.withAlpha(c.alpha);

  Color average(Color c, Color other, double value) =>
      Color.lerp(c, other, limit(value))!;

  Color decolorize(Color c, double value) {
    final int average = (c.red + c.green + c.blue) ~/ 3;
    final grey = Color.fromARGB(c.alpha, average, average, average);
    return Color.lerp(c, grey, limit(value))!;
  }

  Color addOpacity(Color c, double value) =>
      Color.fromARGB((c.alpha * limit(value)).round(), c.red, c.green, c.blue);

  Color removeOpacity(Color c, double value) => Color.fromARGB(
      (c.alpha + ((255 - c.alpha) * limit(value))).round(),
      c.red,
      c.green,
      c.blue);

  Color shadesOfGrey(Color c) {
    final int average = (c.red + c.green + c.blue) ~/ 3;
    return Color.fromARGB(c.alpha, average, average, average);
  }

  const themeColor = ColorRef(Color(0xB03366CC), id: 'themeColor');
  const otherThemeColor = ColorRef(Color(0xFF10E040), id: 'otherThemeColor');

  final colors = <Color>[
    const Color(0xFF000000),
    const Color(0xFFFFFFFF),
    const Color(0x00000000),
    const Color(0xFF3366CC),
    const Color(0x80CC3311),
    const Color(0x0110E040),
    Colors.red,
    Colors.blue.shade200,
    // Colors that don't have exactly 8 bits per channel.
    const Color.from(alpha: 0.5, red: 0.3333, green: 0.123456, blue: 0.987654),
    Colors.green.withValues(alpha: 0.777),
    // Theme colors.
    themeColor,
    otherThemeColor,
  ];

  const values = [-1.0, 0.0, 0.1, 0.25, 0.5, 0.777, 1.0, 2.0];

  tearDown(() {
    Themed.clearCurrentTheme();
    Themed.clearTransformColor();
  });

  void checkAll() {
    for (final color in colors) {
      expect(ColorRef.shadesOfGreyTransform(color), shadesOfGrey(color));

      for (final value in values) {
        final reason = '$color, value $value';
        expect(color.lighter(value), lighter(color, value), reason: reason);
        expect(color.darker(value), darker(color, value), reason: reason);
        expect(color.decolorize(value), decolorize(color, value),
            reason: reason);
        expect(color.addOpacity(value), addOpacity(color, value),
            reason: reason);
        expect(color.removeOpacity(value), removeOpacity(color, value),
            reason: reason);

        for (final other in colors) {
          expect(color.average(other, value), average(color, other, value),
              reason: '$reason, other $other');
        }
      }
    }
  }

  test('The color methods return the same colors as their definitions.', () {
    checkAll();
  });

  test('The same, with theme colors changed by a theme and a transform.', () {
    Themed.currentTheme = {themeColor: const Color(0x40FFEE22)};
    checkAll();

    Themed.transformColor = ColorRef.shadesOfGreyTransform;
    checkAll();
  });

  test('The default values.', () {
    const color = Color(0x80CC3311);
    expect(color.lighter(), lighter(color, 0.5));
    expect(color.darker(), darker(color, 0.5));
    expect(color.average(Colors.blue), average(color, Colors.blue, 0.5));
    expect(color.decolorize(), decolorize(color, 1));
    expect(color.addOpacity(), addOpacity(color, 0.5));
    expect(color.removeOpacity(), removeOpacity(color, 0.5));
  });

  test('Some known results.', () {
    expect(const Color(0xFF804020).lighter(1), const Color(0xFFFFFFFF));
    expect(const Color(0x80804020).darker(1), const Color(0x80000000));
    expect(const Color(0xFF804020).lighter(0), const Color(0xFF804020));
    expect(const Color(0xFF306090).decolorize(), const Color(0xFF606060));
    expect(const Color(0xFF306090).addOpacity(0), const Color(0x00306090));
    expect(const Color(0x00306090).removeOpacity(1), const Color(0xFF306090));
    expect(themeColor.addOpacity(1), const Color(0xB03366CC));
    expect(ColorRef.shadesOfGreyTransform(const Color(0x80306090)),
        const Color(0x80606060));
  });

  test('TextStyle extension.', () {
    const style = TextStyle(fontSize: 15);
    expect(style + Colors.blue, style.copyWith(color: Colors.blue));
    expect(style + 'Roboto', style.copyWith(fontFamily: 'Roboto'));
    expect(style + const FontSize(20), style.copyWith(fontSize: 20));
    expect(style + const TextHeight(2), style.copyWith(height: 2));
    expect(
        style + FontWeight.bold, style.copyWith(fontWeight: FontWeight.bold));
    expect(style + null, same(style));
    expect(style.add(Colors.blue, apply: false), same(style));
    expect(style.add(Colors.blue), style.copyWith(color: Colors.blue));
  });
}
