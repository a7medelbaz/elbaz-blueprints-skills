# Conventions

## Contents
- Target project structure
- Naming
- DI registration rules
- Sizing — never raw pixels
- Sentinel-object `copyWith` for nullable fields
- Stream/subscription cleanup in `cubit.close()`
- Context extensions — navigation
- Localization

## Target project structure

```
assets/
├── images/            # raster images — registered folder-level in pubspec.yaml
├── svgs/               # SVGs, rendered via flutter_svg — registered folder-level
├── fonts/              # empty until a real font is added — see pubspec.yaml's `# fonts:` template
└── translations/       # one JSON per locale (en.json seeded) — registered folder-level
lib/
├── core/
│   ├── config/app_config.dart
│   ├── di/dependency_injection.dart
│   ├── router/            # named: routes.dart + app_router.dart | go_router: app_router.dart only
│   ├── error/app_error.dart, error_handler.dart
│   ├── theme/app_colors.dart, app_text_styles.dart, custom_colors.dart, theme_data/theme_data_light.dart, theme_data/theme_data_dark.dart
│   ├── utils/spacing.dart, extensions/context_ext.dart
│   └── shared/models/, widgets/
├── features/
│   └── <feature_name>/
│       ├── data/<feature_name>_repo.dart, <feature_name>_repo_impl.dart
│       ├── logic/cubit/<feature_name>_cubit.dart (+ part <feature_name>_state.dart)
│       └── ui/<feature_name>_screen.dart, widgets/
├── app.dart
├── main_dev.dart
└── main_prod.dart
```

## Naming

| Item | Convention | Example |
|---|---|---|
| Feature folder | snake_case | `order_tracking/` |
| Class names | PascalCase from feature name | `OrderTrackingCubit`, `OrderTrackingRepo` |
| File names | snake_case matching class | `order_tracking_cubit.dart` |
| Cubit state file | `part of` the cubit file | `order_tracking_state.dart` |
| Route constant | camelCase | `Routes.orderTracking` |

## DI registration rules

In `core/di/dependency_injection.dart`:
- Services and repos → `sl.registerLazySingleton<T>(() => Impl())` — one instance, created on first use.
- Cubits → `sl.registerFactory<T>(() => Cubit(sl()))` — a new instance every time (cubits are screen-scoped, must not be reused across navigations).

```dart
sl.registerLazySingleton<OrderTrackingRepo>(() => OrderTrackingRepoImpl(sl()));
sl.registerFactory<OrderTrackingCubit>(() => OrderTrackingCubit(sl()));
```

## Sizing — never raw pixels

Always use the helpers in `core/utils/spacing.dart` (`flutter_screenutil`-backed), never a literal pixel number in a widget:
```dart
// Wrong
const SizedBox(height: 16)
Container(width: 200)

// Right
verticalSpacing(16)
Container(width: rw(200))
```
`rw`/`rh` scale by screen width/height, `rr` for radii, `rf` for font sizes not already covered by `AppTextStyles`.

## Sentinel-object `copyWith` for nullable fields

A plain `field ?? this.field` `copyWith` cannot set a field back to `null` — passing `null` is indistinguishable from "not provided." Use a sentinel:
```dart
const _unset = Object();

class OrderTrackingState extends Equatable {
  final AppError? error;
  const OrderTrackingState({this.error});

  OrderTrackingState copyWith({Object? error = _unset}) => OrderTrackingState(
    error: identical(error, _unset) ? this.error : error as AppError?,
  );

  @override
  List<Object?> get props => [error];
}
```
Only needed for fields that must be explicitly clearable (commonly `error`). Skip this for fields that never need to be reset to `null`.

## Stream/subscription cleanup in `cubit.close()`

Any `StreamSubscription` or `Timer` a cubit creates must be cancelled in `close()`, or it leaks after the cubit is disposed:
```dart
class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  StreamSubscription? _pollSub;

  OrderTrackingCubit(this._repo) : super(const OrderTrackingState());

  @override
  Future<void> close() {
    _pollSub?.cancel();
    return super.close();
  }
}
```

## Context extensions — navigation

Never call `Navigator.push`/`Navigator.pop` directly — always the helpers in `core/utils/extensions/context_ext.dart`:
```dart
// Wrong
Navigator.pushNamed(context, Routes.home);
Navigator.pop(context);

// Right
context.pushNamed(Routes.home);
context.pop();
```

**go_router projects only:** `context_ext.dart` does not define `pop`/`pushNamed` in this mode — go_router's own `BuildContext` extension already provides `context.pop()`, `context.push()`, `context.go()`, `context.goNamed()`. Use those directly; see [routing.md](routing.md).

## Localization

Already wired by `scaffold_project.dart` — `en.json` is seeded, `EasyLocalization` wraps `App()` in both `main_dev.dart`/`main_prod.dart`, and `app.dart`'s `MaterialApp` already reads `context.localizationDelegates`/`context.supportedLocales`/`context.locale`. Adding a locale is just: create the JSON file, add it to `supportedLocales` in both `main_*.dart` files.

`easy_localization`, one JSON file per locale under `assets/translations/` (`en.json`, `ar.json`), keys namespaced by feature to avoid collisions:
```json
{
  "order_tracking": {
    "title": "Order Tracking",
    "eta_label": "Arriving in {minutes} min"
  }
}
```
Named-argument interpolation:
```dart
Text('order_tracking.eta_label'.tr(namedArgs: {'minutes': '12'}))
```

## Standard cubit try/catch

See [error-handling.md](error-handling.md) — every repo/cubit method that can throw uses `catch (e)` and routes through `ErrorHandler`, never `catch (_)`.
