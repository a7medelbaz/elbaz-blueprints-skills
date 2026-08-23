# What `bootstrapping-flutter-mvvm` does

This is the human-readable version of what the skill at [`skills/flutter/bootstrapping-flutter-mvvm/`](../../../skills/flutter/bootstrapping-flutter-mvvm/) builds. The skill's own `SKILL.md` and `reference/` files are written for an AI agent to execute against — dense, instruction-shaped. This page explains the same thing for a person reading the repo.

## Contents
- What it is, in one sentence
- Two scripts, two jobs
- Everything it scaffolds
- What it deliberately does *not* do
- Design principles behind it
- Where to go for more depth

## What it is, in one sentence

A Dart script that turns an empty (or partially-built) Flutter project into a working MVVM + BLoC codebase — architecture, theming, routing, localization, error handling, and Android build flavors — in one command, safely re-runnable without ever overwriting your own edits.

## Two scripts, two jobs

| Script | Does | Run from |
|---|---|---|
| `scaffold_project.dart` | Builds the whole project skeleton, once | The folder that should *contain* the new project |
| `scaffold_feature.dart` | Adds an empty feature folder (`data/`, `logic/cubit/`, `ui/`) to an already-scaffolded project | The project's root |

`scaffold_feature.dart` is intentionally minimal — it never writes file *contents*, only folders, because a feature's actual code (does it need a repo? two repos? no repo at all?) depends on what that feature does, which isn't something a generic script should guess.

## Everything it scaffolds

**Architecture** — `core/` (config, dependency injection, router, error handling, theme, utils) + `features/<name>/` (data / logic / ui), the standard MVVM + BLoC split. Dependency injection via `get_it`, with a documented convention: singletons for repos/services, factories for cubits.

**Routing** — your choice at scaffold time: simple named routes, or `go_router` for deep linking / web / nested navigation. Whichever you pick, the router files and `app.dart`'s `MaterialApp` wiring are generated to match — switching later means touching three files by hand, so it's worth deciding up front.

**Theming** — not placeholders, a real structured system:
- `AppColors` — a full 50–900 shade-scale palette (primary, secondary, grey, red, green, amber, blue)
- `AppFontWeight` — named weights (`thin` through `black`) over raw `FontWeight`
- `AppTextStyles` — a fixed size × weight matrix (`font24ExtraBold`, `font16SemiBold`, ...) built from those weights
- `CustomColors` — a 17-field semantic color set (text, background, status colors) that animates smoothly between light and dark via Flutter's `ThemeExtension`
- `theme_data_light.dart` / `theme_data_dark.dart` — full `ThemeData` for both brightnesses: color scheme, text theme, and themed buttons/inputs/cards/dividers/icons

**Fonts** — locale-aware, not fixed. You tell it a language → font-family mapping (`--fonts=en:Manrope,ar:Tajawal` is the default) and the whole app's font switches automatically based on the user's active locale — no per-widget font logic anywhere. `AppFontFamily` constants are generated from whatever mapping you actually chose, so they never go stale if you pick different fonts.

**Assets** — `images/`, `svgs/`, `translations/` are registered folder-level in `pubspec.yaml` (drop a file in, it's bundled, nothing else to edit); fonts get real per-family entries with `Regular`/`Bold` file references. The actual font files aren't fetched for you — no network access at scaffold time — so downloading them from Google Fonts and placing them under the registered filenames is the one manual step left.

**Localization** — `easy_localization`, wired end-to-end: a seed `en.json`, both entry points initialize it, and `app.dart` passes locale/delegates into `MaterialApp`. Adding a language is edit two files and drop a JSON file, not a from-scratch integration.

**Error handling** — an `AppError` value type and an `ErrorHandler` interface you implement once per backend and register in DI. Every cubit routes through the same instance, so error handling is consistent instead of ad-hoc per feature.

**Android flavors** — separate `development`/`production` build variants (different app IDs, so both can be installed on one device at once) paired with separate Dart entry points (`main_dev.dart`/`main_prod.dart`). Full explanation, including the tradeoffs against a JSON/YAML-config-driven approach: [`flavors.md`](flavors.md) in this same folder.

**Everything else** — `.env`-based config (`flutter_dotenv`), a `Makefile` with shortcuts for the common commands (`make dev`, `make prod`, `make build-apk-prod`, ...), and `hydrated_bloc` wired up for persisted state.

## What it deliberately does *not* do

- **No CI/CD pipeline.** Earlier versions generated a generic GitHub Actions workflow; it was removed because a real pipeline (App Store vs. internal distribution, signing, per-flavor jobs) is project-specific enough that a one-size-fits-all default did more harm than good.
- **No font files.** It registers where they go, never fetches the binaries.
- **No overwriting.** Every file write checks "does this already exist?" first. Re-running the script on a project you've already customized never clobbers your edits — it just tells you what it skipped.
- **No feature code.** `scaffold_feature.dart` builds folders, not repo/cubit/screen implementations — those are written per-feature, sized to what that feature actually needs.

## Design principles behind it

- **Dry-run first, always.** Every scaffold run should be preceded by `--dry-run` — see exactly what would be created, what already exists, what packages are missing — before anything is written.
- **Idempotent by construction.** Running the script twice in a row produces byte-identical output. This isn't incidental — it's verified as part of testing every change to the skill.
- **Explicit over automatic, on purpose.** Flavors, fonts, and routing are all deliberately simple and dependency-free rather than config-generator-driven — see [`flavors.md`](flavors.md) for the fullest version of this argument, which applies to the rest of the skill's choices too.
- **Verified against a real Flutter SDK, not just read.** Every change to this skill gets tested by actually running `flutter analyze` on a real generated project — real bugs (a Windows-specific process-spawning issue, a `pubspec.yaml`-corruption bug from a line-matching mistake) were only ever found this way, never by reading the code.

## Where to go for more depth

- The skill's own instructions and rules: [`SKILL.md`](../../../skills/flutter/bootstrapping-flutter-mvvm/SKILL.md)
- Theming internals — how to add a color, a text style, extend `CustomColors`: [`reference/theming.md`](../../../skills/flutter/bootstrapping-flutter-mvvm/reference/theming.md)
- Routing internals — named vs. `go_router`, adding a route: [`reference/routing.md`](../../../skills/flutter/bootstrapping-flutter-mvvm/reference/routing.md)
- Error handling internals: [`reference/error-handling.md`](../../../skills/flutter/bootstrapping-flutter-mvvm/reference/error-handling.md)
- Naming, DI, sizing, localization conventions: [`reference/conventions.md`](../../../skills/flutter/bootstrapping-flutter-mvvm/reference/conventions.md)
- Flavors, in depth: [`flavors.md`](flavors.md)
