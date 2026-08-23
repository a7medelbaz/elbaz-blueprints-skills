# Theming

All files below are already written by `scaffold_project.dart`. This describes how to **extend** them — do not recreate them.

## Contents
- Layer roles (which file to touch)
- Adding a semantic color
- Adding a text style
- Component-level theming
- Fonts
- Accessing theme values in a widget

## Layer roles — which file to touch

| File | Holds | Referenced from |
|---|---|---|
| `core/theme/app_colors.dart` | Shade-scale palette (`primary50`...`primary900`, `grey50`...`grey900`, etc.) | `custom_colors.dart`, `theme_data/*` — **never** from a widget |
| `core/theme/custom_colors.dart` | Semantic tokens with **no Material component role** (`success`) | Widgets, via `context.customColors` |
| `core/theme/app_text_styles.dart` | Parameterized weight functions (`extraBold(size)`, `bold(size)`, ...) | Widgets, directly |
| `core/theme/app_fonts.dart` | Language → font family map (`AppFonts.byLanguage`) | `app.dart` (already wired) |
| `core/theme/theme_data/theme_data_light.dart` / `_dark.dart` | Full `ThemeData`: `colorScheme`, `textTheme`, button/input/card/divider/icon themes | `app.dart` (already wired) |

The scaffolded palette is a placeholder scale marked `TODO` — replace the shade values with the project's real ones, keeping the 50–900 structure.

## Adding a semantic color

`CustomColors` is for colors with **no Material component role** — nothing a standard `ThemeData` field already covers. `success` is the shipped example. Card backgrounds, dividers, icon colors, input borders — those belong in `ThemeData` directly (see [Component-level theming](#component-level-theming)), not here.

Add the field in four places within `custom_colors.dart` — the constructor, `light`, `dark`, `copyWith`, and `lerp`:

```dart
final Color warning;                                    // 1. field + constructor param

static const light = CustomColors(warning: AppColors.red700, /* ... */);
static const dark  = CustomColors(warning: AppColors.red300, /* ... */);

// 3. copyWith
warning: warning ?? this.warning,

// 4. lerp — required, or the color snaps instead of animating on theme change
warning: Color.lerp(warning, other.warning, t)!,
```

Forgetting `lerp` is the common mistake: it compiles, but the color jumps during theme transitions. Reference an existing `AppColors` shade rather than a new literal — that's what the palette is for.

## Adding a text style

`AppTextStyles` ships as **parameterized functions**, not fixed per-size getters — call `AppTextStyles.extraBold(16)` directly in a widget, for any size the design calls for:

```dart
Text('Total', style: AppTextStyles.bold(18))
Text(hint, style: AppTextStyles.light(14).copyWith(color: AppColors.grey500))
```

This is what makes the scaffold reusable across projects with different type scales — a project using 15/18/22px sizes needs zero edits to this file, unlike a fixed-getter menu (`font16Bold`, `font18Bold`, ...) that would need a new getter added per project, per size.

**Adding a new weight** (not a new size) is the only reason to touch this file — e.g. a design needs `FontWeight.w900`:
```dart
static TextStyle black(double size) => _base(size, FontWeight.w900);
```

If a project settles on a fixed set of named presets it reuses everywhere (`button`, `hint`, `caption`), add those as project-specific getters built from the parameterized functions — don't bake them into the scaffold's generic core:
```dart
// project-specific addition, not part of the scaffold
static TextStyle get button => extraBold(16);
```

Never write a bare `TextStyle(...)` inside a widget.

## Component-level theming

Standard Material components are themed directly in `theme_data_light.dart`/`theme_data_dark.dart` — `elevatedButtonTheme`, `textButtonTheme`, `outlinedButtonTheme`, `inputDecorationTheme`, `cardTheme`, `dividerTheme`, `iconTheme`. To extend one, edit the field **in both files**, mirroring the light/dark pair so brightness support never regresses:

```dart
// theme_data_light.dart
chipTheme: ChipThemeData(
  backgroundColor: AppColors.grey100,
  labelStyle: AppTextStyles.medium(13),
),

// theme_data_dark.dart — same field, dark-appropriate shades
chipTheme: ChipThemeData(
  backgroundColor: AppColors.grey700,
  labelStyle: AppTextStyles.medium(13),
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

This is deliberate, not incidental: `lightTheme`/`darkTheme` are zero-argument getters with no `BuildContext`, so they have no way to know the current locale — only `app.dart`'s `build()` does. `AppTextStyles.bold(16)` etc. never set `fontFamily` themselves (it stays `null`); Flutter resolves a `null` field in a widget's `TextStyle` from the ambient `Theme.of(context).textTheme`, which is exactly what `.apply(fontFamily: ...)` sets. So both `AppTextStyles`-styled text and plain `Text('...')` pick up the right font automatically — nothing about `AppTextStyles` or the theme_data files needs to change when a language/font mapping changes.

**Adding a language/family pair:**
1. Add the entry to `AppFonts.byLanguage`.
2. Register the family in `pubspec.yaml`'s `fonts:` block (same shape the scaffold already wrote — `Regular` + `Bold` at minimum).
3. Add the locale to `supportedLocales` in **both** `main_dev.dart` and `main_prod.dart` (see [Localization](conventions.md#localization)).
4. Download the real `.ttf` files from [Google Fonts](https://fonts.google.com) and place them in `assets/fonts/` under the exact filenames just registered — the scaffold registers the pubspec entries but never fetches font binaries (no network access, and they're binary content).

## Accessing theme values in a widget

```dart
context.customColors.success   // semantic, non-Material-role color
AppTextStyles.bold(16)         // text style, size supplied per call
context.isDarkMode             // brightness check
Theme.of(context).cardTheme    // any standard component theme
```

`customColors` is already defined on `ContextExt` in `core/utils/extensions/context_ext.dart`. **Do not declare a second extension** with the same getter — two extensions exposing one member on `BuildContext` is an ambiguous-extension-member compile error wherever both are in scope.
