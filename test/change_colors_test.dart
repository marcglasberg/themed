import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themed/themed.dart';

void main() {
  //
  ChangeColors findChangeColors(WidgetTester tester) =>
      tester.widget<ChangeColors>(find.byType(ChangeColors));

  Widget animated({
    double saturation = 0.0,
    double opacity = 1.0,
    Curve raisingCurve = Curves.linear,
    Duration raisingDuration = const Duration(milliseconds: 100),
    Curve loweringCurve = Curves.linear,
    Duration loweringDuration = const Duration(milliseconds: 400),
  }) =>
      AnimatedChangeColors(
        saturation: saturation,
        opacity: opacity,
        raisingCurve: raisingCurve,
        raisingDuration: raisingDuration,
        loweringCurve: loweringCurve,
        loweringDuration: loweringDuration,
        child: const SizedBox(width: 10, height: 10),
      );

  test('ChangeColors clamps the opacity.', () {
    const child = SizedBox();
    expect(ChangeColors(opacity: 0.5, child: child).opacity, 0.5);
    expect(ChangeColors(opacity: -1, child: child).opacity, 0.0);
    expect(ChangeColors(opacity: 2, child: child).opacity, 1.0);
    expect(ChangeColors(child: child).opacity, 1.0);
    expect(ChangeColors.greyscale(opacity: 0.3, child: child).opacity, 0.3);
  });

  testWidgets('ChangeColors applies the opacity.', (tester) async {
    await tester.pumpWidget(ChangeColors(opacity: 0.4, child: const SizedBox()));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.4);
  });

  test('ChangeColors clamps the contrast, contrastCenter and opacityFactor.', () {
    const child = SizedBox();
    expect(ChangeColors(child: child).contrast, 0.0);
    expect(ChangeColors(child: child).contrastCenter, 0.5);
    expect(ChangeColors(child: child).opacityFactor, 1.0);
    expect(ChangeColors(contrast: -2, child: child).contrast, -1.0);
    expect(ChangeColors(contrast: 3, child: child).contrast, 3.0);
    expect(ChangeColors(contrastCenter: -1, child: child).contrastCenter, 0.0);
    expect(ChangeColors(contrastCenter: 2, child: child).contrastCenter, 1.0);
    expect(ChangeColors(opacityFactor: -1, child: child).opacityFactor, 0.0);
    expect(ChangeColors(opacityFactor: 3, child: child).opacityFactor, 3.0);
    expect(ChangeColors.greyscale(contrast: -0.5, child: child).contrast, -0.5);
  });

  testWidgets('ChangeColors defaults add an identity color matrix.', (tester) async {
    await tester.pumpWidget(ChangeColors(opacity: 0.4, child: const SizedBox()));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.4);
    final outer = tester.widgetList<ColorFiltered>(find.byType(ColorFiltered)).first;
    expect(
        outer.colorFilter,
        const ColorFilter.matrix(<double>[
          1, 0, 0, 0, 0, //
          0, 1, 0, 0, 0, //
          0, 0, 1, 0, 0, //
          0, 0, 0, 1, 0, //
        ]));
  });

  testWidgets('ChangeColors moves the opacity to the matrix when using opacityFactor.',
      (tester) async {
    await tester.pumpWidget(
        ChangeColors(opacity: 0.4, opacityFactor: 0.5, child: const SizedBox()));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1.0);

    // Opacity 0 still uses the Opacity widget, so the child is not painted.
    await tester.pumpWidget(
        ChangeColors(opacity: 0.0, opacityFactor: 0.5, child: const SizedBox()));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.0);
  });

  group('Rendered pixels.', () {
    //
    // Renders one pixel of each color (in a row), and returns their RGBA values.
    Future<List<List<int>>> render(
      WidgetTester tester,
      List<Color> colors,
      ChangeColors Function(Widget child) build,
    ) async {
      final key = GlobalKey();
      await tester.pumpWidget(Center(
        child: RepaintBoundary(
          key: key,
          child: build(Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            children: [
              for (final color in colors) Container(width: 1, height: 1, color: color),
            ],
          )),
        ),
      ));

      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final bytes = (await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
        image.dispose();
        return data!;
      }))!;

      return [
        for (int i = 0; i < colors.length; i++)
          [for (int c = 0; c < 4; c++) bytes.getUint8(i * 4 + c)],
      ];
    }

    const black = Color(0xFF000000);
    const white = Color(0xFFFFFFFF);
    const grey = Color(0xFF808080); // Luminance ~0.5.

    testWidgets('Default values change nothing.', (tester) async {
      final pixels = await render(tester, [black, white, grey, const Color(0xFF3366CC)],
          (child) => ChangeColors(child: child));
      expect(pixels, [
        [0, 0, 0, 255],
        [255, 255, 255, 255],
        [128, 128, 128, 255],
        [0x33, 0x66, 0xCC, 255],
      ]);
    });

    testWidgets('Contrast -1 turns everything into the center grey.', (tester) async {
      final pixels = await render(tester, [black, white],
          (child) => ChangeColors(contrast: -1, contrastCenter: 0.8, child: child));
      expect(pixels[0], [204, 204, 204, 255]);
      expect(pixels[1], [204, 204, 204, 255]);
    });

    testWidgets('Contrast -0.5 goes half way to the center grey.', (tester) async {
      final pixels = await render(tester, [black, white],
          (child) => ChangeColors(contrast: -0.5, contrastCenter: 0.5, child: child));
      expect(pixels[0][0], closeTo(64, 1));
      expect(pixels[1][0], closeTo(191, 1));
    });

    testWidgets('Contrast 1 doubles the contrast.', (tester) async {
      final pixels = await render(tester, [const Color(0xFF606060), const Color(0xFFA0A0A0)],
          (child) => ChangeColors(contrast: 1, child: child));
      // 0x60 = 96 -> 2 * 96 - 127.5 = 64.5. And 0xA0 = 160 -> 2 * 160 - 127.5 = 192.5.
      expect(pixels[0][0], closeTo(64.5, 1));
      expect(pixels[1][0], closeTo(192.5, 1));
    });

    testWidgets('opacityFactor below 1 makes dark colors fade faster.', (tester) async {
      final pixels = await render(tester, [black, white, grey],
          (child) => ChangeColors(opacity: 0.2, opacityFactor: 0.5, child: child));
      expect(pixels[0][3], closeTo(0.2 * 255, 1)); // Black.
      expect(pixels[1][3], closeTo(0.4 * 255, 1)); // White.
      expect(pixels[2][3], closeTo(0.3 * 255, 1)); // Grey.
    });

    testWidgets('opacityFactor above 1 makes light colors fade faster.', (tester) async {
      final pixels = await render(tester, [black, white, grey],
          (child) => ChangeColors(opacity: 0.2, opacityFactor: 2, child: child));
      expect(pixels[0][3], closeTo(0.4 * 255, 1)); // Black.
      expect(pixels[1][3], closeTo(0.2 * 255, 1)); // White.
      expect(pixels[2][3], closeTo(0.3 * 255, 1)); // Grey.
    });

    testWidgets('opacityFactor never goes above fully opaque.', (tester) async {
      final pixels = await render(tester, [black, white],
          (child) => ChangeColors(opacity: 0.8, opacityFactor: 0.5, child: child));
      expect(pixels[0][3], closeTo(0.8 * 255, 1));
      expect(pixels[1][3], 255);
    });

    testWidgets('opacityFactor keeps transparent pixels transparent.', (tester) async {
      final pixels = await render(tester, [const Color(0x00000000), const Color(0x00FFFFFF)],
          (child) => ChangeColors(opacity: 0.5, opacityFactor: 0.1, child: child));
      expect(pixels[0][3], 0);
      expect(pixels[1][3], 0);
    });

    testWidgets('opacityFactor never makes translucent pixels more opaque.', (tester) async {
      final pixels = await render(tester, [const Color(0x80000000), const Color(0x80FFFFFF)],
          (child) => ChangeColors(opacity: 0.5, opacityFactor: 0.5, child: child));
      // Ideal: black is 0.5 * 0.5, and white is 0.5 * 1.0.
      expect(pixels[0][3], lessThanOrEqualTo(0.25 * 255 + 1));
      expect(pixels[1][3], closeTo(0.5 * 255, 1)); // White is exact.
    });
  });

  testWidgets('AnimatedChangeColors animates the new values.', (tester) async {
    Widget build(double contrast, double opacityFactor) => AnimatedChangeColors(
          contrast: contrast,
          contrastCenter: 0.8,
          opacityFactor: opacityFactor,
          loweringCurve: Curves.linear,
          loweringDuration: const Duration(milliseconds: 100),
          child: const SizedBox(),
        );

    await tester.pumpWidget(build(0.0, 1.0));
    await tester.pumpWidget(build(-1.0, 0.5));
    await tester.pump(const Duration(milliseconds: 50));
    expect(findChangeColors(tester).contrast, closeTo(-0.5, 0.001));
    expect(findChangeColors(tester).opacityFactor, closeTo(0.75, 0.001));
    expect(findChangeColors(tester).contrastCenter, 0.8);

    await tester.pumpAndSettle();
    expect(findChangeColors(tester).contrast, -1.0);
    expect(findChangeColors(tester).opacityFactor, 0.5);
  });

  testWidgets('AnimatedChangeColors does not animate the initial values.',
      (tester) async {
    await tester.pumpWidget(animated(saturation: -1.0, opacity: 0.5));
    expect(findChangeColors(tester).saturation, -1.0);
    expect(findChangeColors(tester).opacity, 0.5);
  });

  testWidgets('AnimatedChangeColors uses the lowering curve and duration.',
      (tester) async {
    await tester.pumpWidget(animated(saturation: 0.0));
    await tester.pumpWidget(animated(saturation: -1.0));

    await tester.pump(const Duration(milliseconds: 100));
    expect(findChangeColors(tester).saturation, closeTo(-0.25, 0.001));

    await tester.pump(const Duration(milliseconds: 100));
    expect(findChangeColors(tester).saturation, closeTo(-0.5, 0.001));

    await tester.pumpAndSettle();
    expect(findChangeColors(tester).saturation, -1.0);
  });

  testWidgets('AnimatedChangeColors uses the raising curve and duration.',
      (tester) async {
    await tester.pumpWidget(animated(opacity: 0.0));
    await tester.pumpWidget(animated(opacity: 1.0, raisingCurve: Curves.easeIn));

    await tester.pump(const Duration(milliseconds: 50));
    expect(findChangeColors(tester).opacity,
        closeTo(Curves.easeIn.transform(0.5), 0.001));

    await tester.pump(const Duration(milliseconds: 50));
    expect(findChangeColors(tester).opacity, 1.0);
  });

  testWidgets('AnimatedChangeColors changes direction from the current value.',
      (tester) async {
    await tester.pumpWidget(animated(opacity: 1.0));
    await tester.pumpWidget(animated(opacity: 0.0)); // Lowering: 400ms.

    await tester.pump(const Duration(milliseconds: 200));
    expect(findChangeColors(tester).opacity, closeTo(0.5, 0.001));

    // Now raising from 0.5 to 1.0 in 100ms.
    await tester.pumpWidget(animated(opacity: 1.0));
    await tester.pump(const Duration(milliseconds: 50));
    expect(findChangeColors(tester).opacity, closeTo(0.75, 0.001));

    await tester.pumpAndSettle();
    expect(findChangeColors(tester).opacity, 1.0);
  });

  testWidgets('AnimatedChangeColors keeps the child state.', (tester) async {
    final key = GlobalKey();
    Widget build(double saturation) => AnimatedChangeColors(
          saturation: saturation,
          child: SizedBox(key: key),
        );

    await tester.pumpWidget(build(0.0));
    final element = key.currentContext;
    await tester.pumpWidget(build(-1.0));
    await tester.pumpAndSettle();
    expect(key.currentContext, same(element));
  });
}
