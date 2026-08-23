---
name: bootstrapping-flutter-mvvm
description: Scaffolds Flutter projects with MVVM + BLoC (Cubit) architecture — core infrastructure, feature skeletons, Android dev/production flavors, DI with get_it, routing, error handling, and theming. Use when starting a new Flutter project, setting up Flutter MVVM/BLoC architecture from scratch, or adding a new feature to an existing MVVM Flutter project.
---

# Flutter MVVM + BLoC Scaffolding

## Decide first

- **New project or existing?** Both go through `scaffold_project.dart` — it detects which and adapts (see script docs below).
- **Routing:** named routes (simple, no deep links) or `go_router` (deep linking, web, nested nav)? Ask the user if unclear. See [reference/routing.md](reference/routing.md).
- **New feature on an already-scaffolded project?** Use `scaffold_feature.dart`, then write the feature's content yourself (see "Scaffolding a feature" below) — the script only builds folders.

## Scaffolding a new project

Run:
```bash
dart run scripts/scaffold_project.dart <project_name> --routing=named|go_router
```

This is a **rigid, deterministic** script — it always produces the same infrastructure. Do not hand-write these files yourself; run the script and read its summary output (created / skipped / packages added / failures). If a file was skipped because it already existed, do not overwrite it — tell the user what was skipped and why.

After it runs, the project has: `core/config`, `core/di`, `core/router`, `core/error`, `core/theme`, `core/utils`, `lib/app.dart`, `lib/main_dev.dart`, `lib/main_prod.dart`, Android flavors, CI workflow, Makefile, `.env.example`. Full target tree: [reference/conventions.md](reference/conventions.md#target-project-structure).

## Scaffolding a feature

Run:
```bash
dart run scripts/scaffold_feature.dart <feature_name>
```

This script is **intentionally minimal** — it creates only the folder skeleton (`data/`, `logic/cubit/`, `ui/`, `ui/widgets/.gitkeep`) and prints a DI-registration reminder. It does **not** write repo/cubit/state/screen file contents.

After running it, **you write those files yourself**, sized to what the feature actually needs:
- A feature with no backend call doesn't need a repo file at all.
- A feature needing two data sources can get two repos.
- Follow the naming, DI, and code patterns in [reference/conventions.md](reference/conventions.md) exactly (class naming, `rw/rh/rr/rf` sizing, DI registration style, `copyWith` pattern, `cubit.close()` cleanup).
- Follow [reference/error-handling.md](reference/error-handling.md) for any try/catch in a repo or cubit method — never `catch (_)`.
- Never write raw `Navigator.push*` — use the `context_ext.dart` helpers described in conventions.md.

After writing the files, remind the user (do not do this yourself):
1. Register the new repo/cubit in `core/di/dependency_injection.dart`
2. Add the route in `core/router/` (named) or the `GoRoute` list (go_router)

## Rules — always apply these

- Every new cubit/repo → registered in `core/di/dependency_injection.dart` (singleton for repos/services, factory for cubits)
- Every new route → added to the router files, never left unregistered
- Never raw pixel values in UI code — always `rw`/`rh`/`rr`/`rf` from `core/utils/spacing.dart`
- Never `catch (_)` — always `catch (e)` → `ErrorHandler.handle(e)`, so the underlying error is never silently discarded
- Never raw `Navigator.push`/`Navigator.pop` — always the `context_ext.dart` helpers

## Reference files

- Routing patterns (named vs go_router, full code, decision guide) → [reference/routing.md](reference/routing.md)
- Error handling (`AppError`, `ErrorHandler`, catch pattern) → [reference/error-handling.md](reference/error-handling.md)
- Theming (`AppColors`, `CustomColors` extension, `AppTextStyles`, `ThemeData` wiring) → [reference/theming.md](reference/theming.md)
- Naming, sizing, DI, localization, and other conventions → [reference/conventions.md](reference/conventions.md)

## Required packages

`flutter_bloc`, `hydrated_bloc`, `path_provider`, `get_it`, `equatable`, `flutter_screenutil`, `easy_localization`, `flutter_dotenv` — installed automatically by `scaffold_project.dart` via `flutter pub add`. `path_provider` backs `hydrated_bloc`'s storage directory; `flutter_dotenv` backs `AppConfig.baseUrl`.
