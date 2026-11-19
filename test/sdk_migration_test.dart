import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:themed/themed.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() {
    Themed.clearCurrentTheme();
    Themed.defaultTheme = null;
  });

  test('TextStyleRef forwards hyphen handling and paragraph overrides', () {
    const base = TextStyle(fontSize: 17, fontFamily: 'Roboto', height: 1.3);
    const ref = TextStyleRef(base);
    for (final hyphens in [null, Hyphens.manual, Hyphens.hidden]) {
      expect(
        ref.getParagraphStyle(
          hyphens: hyphens,
          maxLines: 2,
          textDirection: TextDirection.rtl,
        ),
        base.getParagraphStyle(
          hyphens: hyphens,
          maxLines: 2,
          textDirection: TextDirection.rtl,
        ),
      );
    }
    Themed.currentTheme = {ref: const TextStyle(fontSize: 23)};
    expect(
      ref.getParagraphStyle(hyphens: Hyphens.hidden),
      const TextStyle(fontSize: 23).getParagraphStyle(hyphens: Hyphens.hidden),
    );
  });

  test('swatches are accepted by standalone Material themes after a map change', () {
    const color = ColorRef(Color(0xFF112233), id: 'primary');
    final MaterialColor material = MaterialColorSwatch(color, {
      for (final shade in [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]) shade: color,
    });
    const MaterialAccentColor accent = MaterialAccentColorSwatch(color, {200: color});
    expect(ThemeData(useMaterial3: false, primarySwatch: material).primaryColor.toARGB32(), color.toARGB32());
    Themed.currentTheme = {color: const Color(0xFF445566)};
    expect(material.shade500.toARGB32(), 0xFF445566);
    expect(accent.shade200.toARGB32(), 0xFF445566);
  });
}
