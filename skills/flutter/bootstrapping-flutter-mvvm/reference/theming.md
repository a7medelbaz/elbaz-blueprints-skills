# Theming

All files below are already written by `scaffold_project.dart`. This describes how to **extend** them — do not recreate them.

## Contents
- Layer roles (which file to touch)
- Adding a semantic color
- Adding a text style or weight
- Component-level theming
- Fonts
- Accessing theme values in a widget

## Layer roles — which file to touch

| File | Holds | Referenced from |
|---|---|---|
| `core/theme/app_colors.dart` | Shade-scale palette (`primary50`...`primary900`, `grey50`...`grey900`, `amber*`, `blue*`, etc.) | `custom_colors.dart`, `theme_data/*` — **never** from a widget |
| `core/theme/app_font_weight.dart` | Named `FontWeight` wrapper (`AppFontWeight.bold`, `.extraBold`, ...) | `app_text_styles.dart` |
| `core/theme/app_text_styles.dart` | Fixed size × weight `TextStyle` constants (`font16ExtraBold`, ...) | Widgets, directly |
| `core/theme/app_fonts.dart` | Language → font family map (`AppFonts.byLanguage`) | `app.dart` (already wired) |
| `core/theme/app_font_family.dart` | One constant per distinct family chosen via `--fonts` | Anywhere a literal family-name string is needed |
| `core/theme/custom_colors.dart` | Semantic tokens with **no Material component role** (text/background/status colors) | Widgets, via `context.customColors` |
| `core/theme/theme_data/theme_data_light.dart` / `_dark.dart` | Full `ThemeData`: `colorScheme`, `textTheme`, button/input/card/divider/icon themes | `app.dart` (already wired) |

The scaffolded palette is a placeholder scale marked `TODO` — replace the shade values with the project's real ones, keeping the 50–900 structure.

## Adding a semantic color

`CustomColors` is for colors with **no Material component role** — nothing a standard `ThemeData` field or `ColorScheme` property already covers. `textPrimary`, `background`, `success`/`successBackground`, etc. are the shipped examples. `surface`/`surfaceVariant` (→ `ColorScheme.surface`), `border`/`divider` (→ `dividerTheme`, `cardTheme`'s border), and the primary icon color (→ `iconTheme.color`) are deliberately **excluded** — those already have a home in `ThemeData` (see [Component-level theming](#component-level-theming)), and duplicating them into `CustomColors` would create two conflicting sources of truth for the same visual property. When adding a field, ask first: does a `ThemeData`/`ColorScheme` property already mean this? If yes, it doesn't belong here.

Add the field in four places within `custom_colors.dart` — the constructor, `light`, `dark`, `copyWith`, and `lerp`:

```dart
final Color info;                                    // 1. field + constructor param

static const light = CustomColors(info: AppColors.blue700, /* ... */);
static const dark  = CustomColors(info: AppColors.blue200, /* ... */);

// 3. copyWith
info: info ?? this.info,

// 4. lerp — required, or the color snaps instead of animating on theme change
info: Color.lerp(info, other.info, t)!,
```

Forgetting `lerp` is the common mistake: it compiles, but the color jumps during theme transitions instead of animating — `CustomColors` stays a `ThemeExtension` specifically so every field animates the same way built-in `ThemeData` properties do. Reference an existing `AppColors` shade rather than a new literal — that's what the palette is for.

## Adding a text style or weight

`AppTextStyles` ships as a **fixed size × weight matrix** — `font24ExtraBold`, `font16SemiBold`, `font12Light`, etc. — built from `AppFontWeight`'s named weights (`thin` through `black`). Call a constant directly:

```dart
Text('Total', style: AppTextStyles.font18SemiBold)
Text(hint, style: AppTextStyles.font14Light.copyWith(color: AppColors.grey500))
```

These are `const` and deliberately **not** screen-adaptive — no `flutter_screenutil` `.sp` scaling, unlike spacing (`rw`/`rh`/`rr`). `.sp` is a runtime call and can't be used in a `const` expression; this scaffold prioritizes a simple, fixed matrix over device-adaptive font sizing. If a project needs `.sp` scaling, converting `font16ExtraBold` etc. from `const` fields to `get` getters returning `TextStyle(fontSize: 16.sp, ...)` is a project-specific change, not the shipped default.

**Adding a new size** — copy an existing size's three constants and change the number. **Adding a new weight** at an existing size — add a constant using another `AppFontWeight` value:
```dart
static const TextStyle font16Bold = TextStyle(
  fontSize: 16,
  fontWeight: AppFontWeight.bold,
);
```

Never write a bare `TextStyle(...)` inside a widget — always a named `AppTextStyles` constant.

## Component-level theming

Standard Material components are themed directly in `theme_data_light.dart`/`theme_data_dark.dart` — `elevatedButtonTheme`, `textButtonTheme`, `outlinedButtonTheme`, `inputDecorationTheme`, `cardTheme`, `dividerTheme`, `iconTheme`. To extend one, edit the field **in both files**, mirroring the light/dark pair so brightness support never regresses:

```dart
// theme_data_light.dart
chipTheme: ChipThemeData(
  backgroundColor: AppColors.grey100,
  labelStyle: AppTextStyles.font12SemiBold,
),

// theme_data_dark.dart — same field, dark-appropriate shades
chipTheme: ChipThemeData(
  backgroundColor: AppColors.grey700,
  labelStyle: AppTextStyles.font12SemiBold,
),
```

Always use `rr(...)` (from `core/utils/spacing.dart`) for `BorderRadius.circular(...)` inside a component theme — never a raw pixel number, per the skill's sizing rule.

`colorScheme: ColorScheme.fromSeed(...)` drives `Material`'s default widget colors as a baseline; the explicit component themes above override specific widgets on top of that baseline. Change the seed/roles here if the overall Material color derivation needs to shift, not per-widget.

## Fonts

The scaffold ships **locale-aware font switching**, not a single fixed font — which family renders is decided by `context.locale` at runtime, chosen when the project was scaffolded via `--fonts=lang:Family,...` (default `ar:Tajawal, en:Manrope`; ask the user before scaffolding if unclear — see `SKILL.md`).

`core/theme/app_fonts.dart`:
```dart
class AppFonts {
  AppFonts._();
  static const Map<String, String> byLanguage = {'en': 'Manrope', 'ar': 'Tajawal'};
  static const String fallback = 'Manrope'; // any language not in byLanguage
  static String forLocale(Locale locale) => byLanguage[locale.languageCode] ?? fallback;
}
```

**Where the switching actually happens — `app.dart`, not the theme_data files or `AppTextStyles`:**
```dart
final fontFamily = AppFonts.forLocale(context.locale);
// ...
theme: lightTheme.copyWith(
  textTheme: lightTheme.textTheme.apply(fontFamily: fontFamily),
),
darkTheme: darkTheme.copyWith(
  textTheme: darkTheme.textTheme.apply(fontFamily: fontFamily),
),
```

This is deliberate, not incidental: `lightTheme`/`darkTheme` are zero-argument getters with no `BuildContext`, so they have no way to know the current locale — only `app.dart`'s `build()` does. `AppTextStyles.font16ExtraBold` etc. never set `fontFamily` themselves (it stays `null`); Flutter resolves a `null` field in a widget's `TextStyle` from the ambient `Theme.of(context).textTheme`, which is exactly what `.apply(fontFamily: ...)` sets. So both `AppTextStyles`-styled text and plain `Text('...')` pick up the right font automatically — nothing about `AppTextStyles` or the theme_data files needs to change when a language/font mapping changes.

**`core/theme/app_font_family.dart`** holds one constant per **distinct** family actually chosen via `--fonts` at scaffold time — generated, never hardcoded:
```dart
class AppFontFamily {
  const AppFontFamily._();
  static const String manrope = 'Manrope';
  static const String tajawal = 'Tajawal';
}
```
This exists for the rare case something needs the family name as a literal string outside of `AppFonts` (e.g. a platform channel or a package API that takes a font family name directly) — `AppFonts.byLanguage`/`.forLocale()` remains the normal way to get "the right font for this locale." A project scaffolded with `--fonts=en:Poppins,fr:Lora` gets `AppFontFamily.poppins`/`.lora` instead — the constants always match whatever was actually chosen, never a stale Tajawal/Manrope default.

**Adding a language/family pair:**
1. Add the entry to `AppFonts.byLanguage` (and a constant to `AppFontFamily` if the family is new).
2. Register the family in `pubspec.yaml`'s `fonts:` block (same shape the scaffold already wrote — `Regular` + `Bold` at minimum).
3. Add the locale to `supportedLocales` in **both** `main_dev.dart` and `main_prod.dart` (see [Localization](conventions.md#localization)).
4. Download the real `.ttf` files from [Google Fonts](https://fonts.google.com) and place them in `assets/fonts/` under the exact filenames just registered — the scaffold registers the pubspec entries but never fetches font binaries (no network access, and they're binary content).

## Accessing theme values in a widget

```dart
context.customColors.textPrimary   // semantic, non-Material-role color
context.customColors.errorBackground
AppTextStyles.font16ExtraBold      // fixed size x weight constant
context.isDarkMode                 // brightness check
Theme.of(context).cardTheme        // any standard component theme
```

`customColors` is already defined on `ContextExt` in `core/utils/extensions/context_ext.dart`. **Do not declare a second extension** with the same getter — two extensions exposing one member on `BuildContext` is an ambiguous-extension-member compile error wherever both are in scope.
