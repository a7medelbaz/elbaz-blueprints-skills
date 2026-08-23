# Theming

All files below are already written by `scaffold_project.dart`. This describes how to **extend** them — do not recreate them.

## Contents
- Layer roles (which file to touch)
- Adding a semantic color
- Adding a text style
- Accessing theme values in a widget

## Layer roles — which file to touch

| File | Holds | Referenced from |
|---|---|---|
| `core/theme/app_colors.dart` | Raw palette constants only | `custom_colors.dart`, `theme_data/*` — **never** from a widget |
| `core/theme/custom_colors.dart` | Semantic tokens that differ per brightness (`success`, `cardBackground`) | Widgets, via `context.customColors` |
| `core/theme/app_text_styles.dart` | Named `TextStyle` getters | Widgets, directly |
| `core/theme/theme_data/theme_data_light.dart` / `_dark.dart` | `ThemeData` wiring | `app.dart` (already wired) |

The scaffolded palette and type scale are placeholders marked `TODO` — replace the values with the project's real ones, keeping the structure.

## Adding a semantic color

A color that means the same thing but *looks* different in light vs dark belongs in `CustomColors`, not in a widget. Add the field in four places within `custom_colors.dart` — the constructor, `light`, `dark`, `copyWith`, and `lerp`:

```dart
final Color warning;                                    // 1. field + constructor param

static const light = CustomColors(warning: Color(0xFFF57C00), /* ... */);
static const dark  = CustomColors(warning: Color(0xFFFFB74D), /* ... */);

// 3. copyWith
warning: warning ?? this.warning,

// 4. lerp — required, or the color snaps instead of animating on theme change
warning: Color.lerp(warning, other.warning, t)!,
```

Forgetting `lerp` is the common mistake: it compiles, but the color jumps during theme transitions.

A color that is identical in both themes doesn't need `CustomColors` — put it in `AppColors` and reference it from `ThemeData`.

## Adding a text style

Add a getter to `AppTextStyles`. Use `.sp` so it scales with `flutter_screenutil`:

```dart
static TextStyle get subtitle => TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500);
```

Never write a bare `TextStyle(...)` inside a widget.

## Accessing theme values in a widget

```dart
context.customColors.success   // semantic color — getter already exists in ContextExt
AppTextStyles.heading1         // text style
context.isDarkMode             // brightness check
```

`customColors` is already defined on `ContextExt` in `core/utils/extensions/context_ext.dart`. **Do not declare a second extension** with the same getter — two extensions exposing one member on `BuildContext` is an ambiguous-extension-member compile error wherever both are in scope.
