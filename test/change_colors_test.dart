import 'package:flutter/material.dart';
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
