import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themed/themed.dart';

void main() {
  const child = RepaintBoundary(child: ColoredBox(color: Colors.red));

  final cases = <String, ChangeColors Function()>{
    'defaults': () => ChangeColors(child: child),
    'unused contrast center': () =>
        ChangeColors(contrastCenter: 0.9, child: child),
    'unused opacity factor': () => ChangeColors(opacityFactor: 0, child: child),
    'brightness': () => ChangeColors(brightness: 0.2, child: child),
    'saturation': () => ChangeColors(saturation: -0.5, child: child),
    'hue': () => ChangeColors(hue: 0.4, child: child),
    'contrast': () => ChangeColors(contrast: -0.4, child: child),
    'weighted opacity': () =>
        ChangeColors(opacity: 0.5, opacityFactor: 2, child: child),
    'greyscale': () => ChangeColors.greyscale(child: child),
    'all filters': () => ChangeColors(
        brightness: 0.2,
        saturation: -0.5,
        hue: 0.4,
        contrast: -0.4,
        child: child),
  };

  for (final entry in cases.entries) {
    testWidgets('Only active layers: ${entry.key}.', (tester) async {
      await tester.pumpWidget(entry.value());
      final expected = entry.key == 'all filters'
          ? 4
          : ['defaults', 'unused contrast center', 'unused opacity factor']
                  .contains(entry.key)
              ? 0
              : 1;
      expect(tester.layers.whereType<ColorFilterLayer>(), hasLength(expected));

      // Update the same render objects, discard old layers, then re-enable them.
      await tester.pumpWidget(ChangeColors(child: child));
      expect(tester.layers.whereType<ColorFilterLayer>(), isEmpty);
      await tester.pumpWidget(entry.value());
      expect(tester.layers.whereType<ColorFilterLayer>(), hasLength(expected));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Filter updates preserve unkeyed child state and focus.',
      (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    Widget build(double value) => MaterialApp(
          home: Scaffold(
            body: ChangeColors(
              brightness: value,
              hue: value,
              saturation: value,
              contrast: value,
              child: TextField(focusNode: focusNode),
            ),
          ),
        );

    await tester.pumpWidget(build(0));
    final state = tester.state(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Preserved');
    focusNode.requestFocus();
    await tester.pump();
    for (final value in [0.3, -0.2, 0.0, 0.4, 0.0]) {
      await tester.pumpWidget(build(value));
      expect(tester.state(find.byType(TextField)), same(state));
      expect(focusNode.hasFocus, isTrue);
      expect(find.text('Preserved'), findsOneWidget);
    }
  });

  testWidgets(
      'Interrupted animations preserve state and remove neutral layers.',
      (tester) async {
    Widget build(double value) => AnimatedChangeColors(
          brightness: value,
          saturation: value,
          hue: value,
          contrast: value,
          raisingCurve: Curves.linear,
          loweringCurve: Curves.linear,
          raisingDuration: const Duration(milliseconds: 100),
          loweringDuration: const Duration(milliseconds: 100),
          child: const _StateProbe(),
        );

    await tester.pumpWidget(build(0));
    final state = tester.state(find.byType(_StateProbe));
    expect(tester.layers.whereType<ColorFilterLayer>(), isEmpty);
    await tester.pumpWidget(build(0.4));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.widget<ChangeColors>(find.byType(ChangeColors)).brightness,
        closeTo(0.2, 0.001));
    expect(tester.layers.whereType<ColorFilterLayer>(), hasLength(4));

    await tester.pumpWidget(build(0));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.widget<ChangeColors>(find.byType(ChangeColors)).brightness,
        closeTo(0.1, 0.001));
    expect(tester.layers.whereType<ColorFilterLayer>(), hasLength(4));
    await tester.pumpAndSettle();
    expect(tester.layers.whereType<ColorFilterLayer>(), isEmpty);
    expect(tester.state(find.byType(_StateProbe)), same(state));

    await tester.pumpWidget(build(-0.4));
    await tester.pumpAndSettle();
    expect(tester.layers.whereType<ColorFilterLayer>(), hasLength(4));
    expect(tester.state(find.byType(_StateProbe)), same(state));
    expect(tester.takeException(), isNull);
  });
}

class _StateProbe extends StatefulWidget {
  const _StateProbe();

  @override
  State<_StateProbe> createState() => _StateProbeState();
}

class _StateProbeState extends State<_StateProbe> {
  @override
  Widget build(BuildContext context) =>
      const RepaintBoundary(child: ColoredBox(color: Colors.blue));
}
