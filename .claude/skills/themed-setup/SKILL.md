---
name: themed-setup
description: Set up the `themed` package in a Flutter app, with a design system including colors, and light/dark mode themes, spacing constants, and status bar utilities. Use when the user wants to add themes or create a design system.
---

# Setting Up Themed in a Flutter App

You are helping the user set up the `themed` package in their Flutter app, and create
a design system that's easy to use. Follow these steps:

## Step 1: Import it.

If the `themed` package is not in the `pubspec.yaml` file dependencies, add it:

```yaml
dependencies:
  themed: ^8.1.0
```

Check `https://pub.dev/packages/themed` for the latest version.

Run `flutter pub get` to install the package.

## Step 2: Determine File Location

Ask the user where to create `app_themes.dart`. Examples:

- `lib/app_themes.dart` (simple projects)
- `lib/theme/app_themes.dart` (organized projects)
- `lib/core/theme/app_themes.dart` (feature-based architecture)

## Step 3: Gather Design Requirements

Ask the user if they want separate light and dark themes, or just a light (or just dark)
theme.

Check the code to see if the user already uses specific fonts or colors.
If so, incorporate them. If not, start with sensible defaults:

1. **Font family**: Use `Roboto` or `Inter`
2. **Brand colors**: Create some common brand colors.

## Step 4: Create app_themes.dart

Create the design system file with this structure (customize based on user answers):

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:themed/themed.dart';

// ============================================================================
// TYPOGRAPHY
// ============================================================================

class Font {
  Font._();

  static const String _fontFamily = 'YOUR_FONT';
  static const List<String> _fallback = ['Arial'];

  static const mini = TextStyleRef(
    TextStyle(
      fontSize: 14.0,
      height: 1.5,
      fontWeight: FontWeight.w400,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      inherit: true,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  static const miniBold = TextStyleRef(
    TextStyle(
      fontSize: 14.0,
      height: 1.5,
      fontWeight: FontWeight.w600,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      inherit: true,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  static const small = TextStyleRef(
    TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontWeight: FontWeight.w400,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      inherit: true,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  static const smallBold = TextStyleRef(
    TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontWeight: FontWeight.w600,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      inherit: true,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  static const smallDimmed = TextStyleRef(
    TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontWeight: FontWeight.w400,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      inherit: true,
      color: AppColors.textDimmed,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  static const medium = TextStyleRef(
    TextStyle(
      fontSize: 20.0,
      height: 1.4,
      fontWeight: FontWeight.w400,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      inherit: true,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  static const mediumBold = TextStyleRef(
    TextStyle(
      fontSize: 20.0,
      height: 1.4,
      fontWeight: FontWeight.w600,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      inherit: true,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  static const mediumDimmed = TextStyleRef(
    TextStyle(
      fontSize: 20.0,
      height: 1.4,
      fontWeight: FontWeight.w400,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      inherit: true,
      color: AppColors.textDimmed,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  static const large = TextStyleRef(
    TextStyle(
      fontSize: 28.0,
      height: 1.35,
      fontWeight: FontWeight.w700,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      inherit: true,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );
}

// ============================================================================
// COLORS
// ============================================================================

class AppColors {
  AppColors._();

  // Raw colors (private, light theme defaults)
  static const _dark9 = Color.fromRGBO(0, 0, 0, 0.90);
  static const _dark6 = Color.fromRGBO(0, 0, 0, 0.40);
  static const _dark4 = Color.fromRGBO(0, 0, 0, 0.20);
  static const _dark2 = Color.fromRGBO(0, 0, 0, 0.07);

  static const _light9 = Color.fromRGBO(255, 255, 255, 0.95);
  static const _light6 = Color.fromRGBO(255, 255, 255, 0.45);
  static const _light4 = Color.fromRGBO(255, 255, 255, 0.20);

  static const _white = Color.fromRGBO(255, 255, 255, 1);
  static const _white1 = Color.fromRGBO(245, 245, 245, 1);
  static const _white2 = Color.fromRGBO(237, 237, 237, 1);

  static const _black = Color.fromRGBO(0, 0, 0, 1);
  static const _black1 = Color.fromRGBO(15, 15, 15, 1);
  static const _black2 = Color.fromRGBO(27, 27, 27, 1);
  static const _black3 = Color.fromRGBO(40, 40, 40, 1);

  static const _red = Color.fromRGBO(255, 60, 30, 1);
  static const _green = Color.fromRGBO(11, 140, 75, 1);
  static const _yellow = Color.fromRGBO(247, 144, 9, 1);
  static const _blue = Color(0xFF2196F3);

  // ColorRef definitions (use throughout the app)
  static const transparent = Colors.transparent;

  // Backgrounds
  static const background = ColorRef(_white, id: 'bg');
  static const backgroundSecondary = ColorRef(_white1, id: 'bg1');
  static const backgroundTertiary = ColorRef(_white2, id: 'bg2');
  static const surface = ColorRef(_white, id: 'srf');

  // Text
  static const textPrimary = ColorRef(_dark9, id: 'txt');
  static const textDimmed = ColorRef(_dark6, id: 'txtD');
  static const textOnDark = ColorRef(_light9, id: 'txtL');

  // Borders
  static const border = ColorRef(_dark2, id: 'brd');
  static const divider = ColorRef(_white2, id: 'div');

  // Semantic
  static const error = ColorRef(_red, id: 'err');
  static const success = ColorRef(_green, id: 'suc');
  static const warning = ColorRef(_yellow, id: 'wrn');
  static const info = ColorRef(_blue, id: 'inf');
  static const link = ColorRef(_blue, id: 'lnk');

  // Brand/Interactive
  static const primary = ColorRef(_blue, id: 'pri');
  static const shadow = ColorRef(_black, id: 'shd');
}

// ============================================================================
// THEME MAPS
// ============================================================================

Map<ThemeRef, Object> darkTheme = {
  AppColors.background: AppColors._black1,
  AppColors.backgroundSecondary: AppColors._black2,
  AppColors.backgroundTertiary: AppColors._black3,
  AppColors.surface: AppColors._black2,
  AppColors.textPrimary: AppColors._light9,
  AppColors.textDimmed: AppColors._light6,
  AppColors.textOnDark: AppColors._dark9,
  AppColors.border: AppColors._light4,
  AppColors.divider: AppColors._black3,
  AppColors.primary: const Color(0xFF64B5F6),
};

// ============================================================================
// UTILITIES
// ============================================================================

bool get isLightMode => Themed.ifCurrentThemeIs(const {});

bool get isDarkMode => !isLightMode;

// Spacing
const double px0 = 0;
const double px2 = 2;
const double px4 = 4;
const double px6 = 6;
const double px8 = 8;
const double px12 = 12;
const double px16 = 16;
const double px20 = 20;
const double px24 = 24;
const double px32 = 32;
const double px48 = 48;
const double px64 = 64;

// Border radius
class AppTheme {
  AppTheme._();

  static const borderRadius4 = BorderRadius.all(Radius.circular(4));
  static const borderRadius8 = BorderRadius.all(Radius.circular(8));
  static const borderRadius12 = BorderRadius.all(Radius.circular(12));
  static const borderRadius16 = BorderRadius.all(Radius.circular(16));
}

// Status bar
void setStatusBarLight() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
}

void setStatusBarDark() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
}
```

### Important Reminders

- All `ColorRef` and `TextStyleRef` must be `const`
- Use unique `id` when two constants would otherwise be identical
- `Themed` widget must be above `MaterialApp`
- Avoid circular references in theme maps

## Step 5: Update `main.dart`

Wrap `MaterialApp` with `Themed`:

```dart
import 'package:themed/themed.dart';
import 'app_themes.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Themed(
      child: MaterialApp(
        theme: ThemeData(
          ...
        ),
        home: const HomePage(),
      ),
    );
  }
}
```

## Step 6: Add to CLAUDE.md

Add to CLAUDE.md some concise instructions on how to use the design system.
In special, include: "Do not use hardcoded colors or text styles that are not part of the
design system present in file `app_themes.dart`, and only add new colors or text styles
to it when really needed."

## Step 7: Show Usage Examples

After setup, explain it to the user how to use the design system:

```dart
// Use colors
Container(color: AppColors.background)

// Use fonts
Text('Title', style: Font.large)
Text('Body', style: Font.medium)

// Combine with + operator
Text('Custom', style: Font.medium + Colors.red)

// Switch themes
Themed.currentTheme = darkTheme; // Dark mode
Themed.clearCurrentTheme(); // Back to light
```
