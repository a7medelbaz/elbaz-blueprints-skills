# Understanding Flavors in `bootstrapping-flutter-mvvm`

This explains how app flavors (dev vs. production) work in the scaffolded projects, why this skill builds them this way instead of a config-file-driven approach, and when you'd actually want the other way instead.

## Contents
- What a "flavor" actually is
- How this skill builds flavors
- Why this design, not a JSON/YAML config generator
- Pros and cons
- The alternative: JSON/YAML-driven flavors (e.g. `flutter_flavorizr`)
- Firebase App Distribution with each approach
- Shipping to the App Store / Play Store

## What a "flavor" actually is

A "flavor" isn't one thing — it's two separate mechanisms that have to be wired together:

1. **Android's own build variant system** (Gradle `productFlavors`) — controls the app's `applicationId`, display name, and other native-level config per variant.
2. **Which Dart code actually runs** — Flutter has no built-in concept of "flavor" for Dart itself; something has to decide which `main()` executes, and with what config (API URL, feature flags, app name).

Any flavor setup, regardless of tooling, is really "how do I keep these two in sync."

## How this skill builds flavors

**Android side** — `android/app/build.gradle.kts`:
```kotlin
productFlavors {
    create("development") {
        dimension = "default"
        applicationIdSuffix = ".development"
        resValue("string", "app_name", "${projectName}_dev")
    }
    create("production") {
        dimension = "default"
        resValue("string", "app_name", projectName)
    }
}
```
Development gets a suffixed `applicationId` (`com.example.myapp.development`) so it installs as a **separate app** next to the real one on your phone.

**Dart side** — two physically separate entry points, `lib/main_dev.dart` and `lib/main_prod.dart`, each hardcoding its own config at compile time:
```dart
FlavorConfig.instance = FlavorConfig(flavor: Flavor.development, appName: 'App Dev', baseUrl: ...);
```

**Tying them together** — you pass both flags together, every time:
```bash
flutter run --flavor development --target lib/main_dev.dart
```
The scaffolded `Makefile` bakes this pairing in (`make dev`, `make prod`, `make build-apk-dev`, ...) so the two flags never drift apart by accident.

## Why this design, not a JSON/YAML config generator

The obvious alternative — and the one you may have used before — is a config-file-driven generator like `flutter_flavorizr`: you write one `flavorizr.yaml` describing every flavor (name, app icon, `applicationId`, Firebase config, etc.), run a generator, and it produces the Gradle blocks, entry points, and platform config for you.

This skill deliberately doesn't do that, for a scaffold-specific reason: it has **no code-generation step and no extra dependency**. Everything it writes is plain, static Dart/Gradle/YAML you can read top to bottom with no indirection through a generator's own conventions. That fits a *scaffolding* tool's job — hand you a working, inspectable starting point — better than a tool that keeps regenerating files from a config source of truth.

## Pros and cons

**Pros of this skill's approach:**
- Zero extra package/dependency
- Compile-time safety — a typo in a flavor name is a build error, not a runtime surprise
- Fully readable — open `main_dev.dart`, see exactly what "dev" means, no config-file indirection
- Nothing to regenerate — edit the files directly, they stay edited

**Cons:**
- Adding a flavor means touching three places by hand: the Gradle block, a new `main_<flavor>.dart`, and a `Makefile` target — no single source of truth
- Doesn't scale gracefully past ~3–4 flavors (dev/staging/QA/demo/white-label...) — at that point a generator earns its keep
- No built-in per-flavor asset/icon swapping — config-file generators typically automate that; here, you wire it yourself

## The alternative: JSON/YAML-driven flavors

Tools like `flutter_flavorizr` invert the model: **one config file is the source of truth**, and Gradle config, entry points, `Info.plist` values, and sometimes even Firebase config are *generated* from it. Adding a fourth flavor is one new block in the YAML, not three hand-edited files.

Where this wins:
- Many flavors (4+), especially white-label apps with per-client branding
- Per-flavor asset/icon automation matters to you
- You want flavor definitions to double as documentation — one file *is* the list of environments

Where it costs you:
- A generator dependency your whole team now depends on
- An indirection layer — "why does dev look like that?" now means reading generator output, not just the file you're editing
- Regeneration risk — hand-edit a generated file and the next `flutter pub run flutter_flavorizr` can silently clobber it

## Firebase App Distribution with each approach

Firebase App Distribution doesn't care which flavor system you use — it just needs a built APK/IPA and a distribution command per flavor. The difference is *how much of that command is automated for you*:

**With this skill's flavors:** you write the distribution step yourself per flavor, same as any other CI step:
```bash
flutter build apk --flavor development --target lib/main_dev.dart
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-development-release.apk \
  --app <FIREBASE_APP_ID_DEV> --groups "internal-testers"
```
One job per flavor in your CI config — explicit, but you own every line.

**With a JSON/YAML-driven setup:** the config file often already includes each flavor's Firebase App ID, and a Fastlane lane or the generator's own tooling wires the build → distribute pipeline from that one file — less to write by hand, but the distribution step now depends on the generator's conventions matching what Firebase expects.

Neither is "wrong" for Firebase specifically — it's the same trade-off as the rest of this doc: explicit and dependency-free vs. automated and config-driven.

## Shipping to the App Store / Play Store

Regardless of which flavor system built the project: **only the `production` flavor ever gets uploaded to a store.** `development` (or `staging`, `qa`, etc.) exists purely for internal testing — different `applicationId`, never released publicly. A store submission is always:
```bash
flutter build appbundle --flavor production --target lib/main_prod.dart
```
That's true whether `production` was defined by hand in `build.gradle.kts` or generated from a YAML file — the store doesn't know or care which tooling produced it.
