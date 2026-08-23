---
name: bootstrapping-flutter-mvvm
description: Scaffolds Flutter projects with MVVM + BLoC (Cubit) architecture — core infrastructure, feature skeletons, Android dev/production flavors, DI with get_it, routing, assets, localization, error handling, and theming. Use when starting a new Flutter project, setting up Flutter MVVM/BLoC architecture from scratch, or adding a new feature to an existing MVVM Flutter project.
---

# Flutter MVVM + BLoC Scaffolding

## Running the scripts — read this first

The scripts live in **this skill's** `scripts/` folder, not in the user's project. Always invoke them through `${CLAUDE_SKILL_DIR}`, which expands to this skill's directory regardless of the current working directory. A bare `scripts/scaffold_project.dart` resolves against the user's project and fails.

Each script expects a different working directory:

| Script | Run from | Creates |
|---|---|---|
| `scaffold_project.dart` | the folder that should **contain** the project | `<project_name>/...` |
| `scaffold_feature.dart` | the **project root** | `lib/features/<feature_name>/` |

## Scaffolding a project — always dry-run first

Both new and existing projects go through the same script; it detects which by whether `<project_name>/` exists, and never overwrites an existing file.

**Step 1 — audit.** Never scaffold blind. Run with `--dry-run` to report what exists and what is missing, writing nothing:
```bash
dart run ${CLAUDE_SKILL_DIR}/scripts/scaffold_project.dart <project_name> --routing=named|go_router --fonts=lang:Family,... --dry-run
```

**Step 2 — show the user** the dry-run summary (would create / already present / packages missing) and **ask whether to proceed.** Do not apply without their answer.

**Step 3 — apply**, once they confirm, by re-running the identical command without `--dry-run`.

This is a **rigid, deterministic** script — do not hand-write these files yourself. Read its summary and report skipped files to the user rather than overwriting them.

Two things to ask about before step 1, if unclear:
- **Routing:** named routes (simple, no deep links) or `go_router` (deep linking, web, nested nav)? See [reference/routing.md](reference/routing.md).
- **Fonts:** which font family per language, for locale-aware font switching? Default: Tajawal (`ar`) / Manrope (`en`) — omit `--fonts` entirely to use this default, or pass `--fonts=ar:Tajawal,en:Manrope,fr:SomeFont` for a different mapping. See [reference/theming.md](reference/theming.md#fonts).

After applying, the project has `core/config`, `core/di`, `core/router`, `core/error`, `core/theme` (a full shade-scale palette, a fixed size × weight text-style matrix, and fully themed light/dark `ThemeData` — not placeholders), `core/utils`, `lib/app.dart`, `lib/main_dev.dart`, `lib/main_prod.dart`, Android flavors, CI workflow, Makefile, `.env`, and a wired `assets/` tree. Full tree: [reference/conventions.md](reference/conventions.md#target-project-structure).

## Scaffolding a feature

From the project root:
```bash
dart run ${CLAUDE_SKILL_DIR}/scripts/scaffold_feature.dart <feature_name>
```

This script is **intentionally minimal** — it creates only the folder skeleton (`data/`, `logic/cubit/`, `ui/`, `ui/widgets/`) and prints a DI reminder. It writes **no** file contents.

You then write those files yourself, sized to what the feature actually needs:
- A feature with no backend call doesn't need a repo file at all.
- A feature needing two data sources can get two repos.
- Follow [reference/conventions.md](reference/conventions.md) for naming, DI, `rw/rh/rr/rf` sizing, `copyWith`, and `cubit.close()` cleanup.
- Follow [reference/error-handling.md](reference/error-handling.md) for any try/catch.

Afterwards, remind the user to register the repo/cubit in `core/di/dependency_injection.dart` and add the route — do not do it for them.

## Rules — always apply these

- Every new cubit/repo → registered in `core/di/dependency_injection.dart` (`registerLazySingleton` for repos/services, `registerFactory` for cubits)
- Every new route → added to the router files, never left unregistered
- Never raw pixel values in UI code — always `rw`/`rh`/`rr`/`rf` from `core/utils/spacing.dart`
- Never `catch (_)` — always `catch (e)` → `sl<ErrorHandler>().handle(e)`, so the underlying error is never silently discarded
- Never raw `Navigator.push`/`Navigator.pop` — always the `context_ext.dart` helpers

## Reference files

- Routing — choosing named vs go_router, adding routes → [reference/routing.md](reference/routing.md)
- Error handling — `AppError`, implementing `ErrorHandler`, catch pattern → [reference/error-handling.md](reference/error-handling.md)
- Theming — extending `AppColors`, `CustomColors`, `AppTextStyles`, locale-aware `AppFonts` → [reference/theming.md](reference/theming.md)
- Naming, sizing, DI, assets, localization → [reference/conventions.md](reference/conventions.md)

These describe how to **extend** what the script writes; the scaffolded code itself is in `scripts/scaffold_project.dart`. Read a reference file only when working on that area.

## Required packages

`flutter_bloc`, `hydrated_bloc`, `path_provider`, `get_it`, `equatable`, `flutter_screenutil`, `easy_localization`, `flutter_dotenv`, `flutter_svg` (plus `go_router` in that routing mode) — added automatically via `flutter pub add`. `path_provider` backs `hydrated_bloc` storage; `flutter_dotenv` backs `AppConfig.baseUrl`; `flutter_svg` renders `assets/svgs/`.

## Assets, fonts, and localization

The script creates `assets/images/`, `assets/svgs/`, `assets/fonts/`, `assets/translations/` and registers images/svgs/translations **folder-level** in `pubspec.yaml` — drop a file in and it is bundled, no pubspec edit needed.

`assets/fonts/` is registered differently: based on the `--fonts` mapping (default `ar:Tajawal, en:Manrope`), the script writes a **real, uncommented** `fonts:` block in `pubspec.yaml` — one entry per distinct family, with `Regular`/`Bold` file references — plus a locale-aware `AppFonts` class (`core/theme/app_fonts.dart`) that `app.dart` uses to swap the whole app's font automatically based on `context.locale`. The actual `.ttf` files are never fetched (no network access, and they're binary) — downloading them from Google Fonts and placing them under the exact filenames just registered is a manual last step. See [reference/theming.md#fonts](reference/theming.md#fonts).

Localization is wired end-to-end: `en.json` is seeded, both entry points call `EasyLocalization.ensureInitialized()` and wrap `App()`, and `app.dart` passes the delegates/locale into `MaterialApp`. To add a locale, create `assets/translations/<locale>.json`, add it to `supportedLocales` in **both** `main_dev.dart` and `main_prod.dart`, and — if it needs a font other than `AppFonts.fallback` — map it in `AppFonts.byLanguage`. Key namespacing: [reference/conventions.md](reference/conventions.md#localization).
