# Theming

## AppColors — raw palette

`core/theme/app_colors.dart` — only raw constants, never referenced directly from UI widgets (use `CustomColors` or `Theme.of(context)` instead):
```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1E88E5);
  static const Color secondary = Color(0xFF26A69A);
  static const Color error = Color(0xFFD32F2F);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  // TODO: replace with the project's real palette
}
```

## CustomColors — semantic tokens via ThemeExtension

Use `ThemeExtension` for colors that change meaning between light/dark (e.g. "success," "card background") rather than hardcoding a color per theme in widgets.

`core/theme/custom_colors.dart`:
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  final Color success;
  final Color cardBackground;

  const CustomColors({required this.success, required this.cardBackground});

  static const light = CustomColors(
    success: Color(0xFF2E7D32),
    cardBackground: AppColors.white,
  );

  static const dark = CustomColors(
    success: Color(0xFF66BB6A),
    cardBackground: Color(0xFF1E1E1E),
  );

  @override
  CustomColors copyWith({Color? success, Color? cardBackground}) => CustomColors(
    success: success ?? this.success,
    cardBackground: cardBackground ?? this.cardBackground,
  );

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      success: Color.lerp(success, other.success, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
    );
  }
}
```

Access via a `context_ext.dart` helper (add alongside the navigation helpers):
```dart
extension ThemeExt on BuildContext {
  CustomColors get customColors => Theme.of(this).extension<CustomColors>()!;
}
```

Usage in a widget: `context.customColors.success`.

## AppTextStyles

`core/theme/app_text_styles.dart` — named static getters, not raw `TextStyle()` calls scattered through widgets:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading1 => TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold);
  static TextStyle get body => TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal);
  static TextStyle get caption => TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w300);
}
```

## Wiring into ThemeData

`core/theme/theme_data/theme_data_light.dart`:
```dart
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../custom_colors.dart';

ThemeData get lightTheme => ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.white,
  extensions: const [CustomColors.light],
);
```

`core/theme/theme_data/theme_data_dark.dart` mirrors this with `Brightness.dark` and `CustomColors.dark`.

Wire both into `MaterialApp` in `app.dart`:
```dart
MaterialApp(
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: ThemeMode.system,
)
```
