# Routing patterns

## Which to choose

| | Named routes | go_router |
|---|---|---|
| Deep linking / web URLs | No | Yes |
| Nested navigation (bottom-nav tabs each with their own stack) | Awkward | Native support |
| Route count | Small (<15) | Any |
| Setup complexity | Minimal | More boilerplate up front |

Default to **named routes** unless the user needs deep linking, web support, or nested navigators — then use `go_router`.

---

## Named routes

`core/router/routes.dart`:
```dart
class Routes {
  Routes._();

  static const String splash = '/';
  static const String home = '/home';
  // Add one constant per screen.
}
```

`core/router/app_router.dart`:
```dart
import 'package:flutter/material.dart';
import 'routes.dart';
// import '../../features/home/ui/home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const Placeholder());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
```

Wire into `MaterialApp` in `app.dart`:
```dart
MaterialApp(
  initialRoute: Routes.splash,
  onGenerateRoute: AppRouter.generateRoute,
)
```

Navigate with the `context_ext.dart` helper: `context.pushNamed(Routes.home)`.

---

## go_router

`core/router/app_router.dart`:
```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
// import '../../features/home/ui/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Placeholder(),
    ),
    // Add one GoRoute per screen. Use `routes: [...]` nested inside
    // a GoRoute for sub-navigation under that path.
  ],
);
```

Wire into the app with `MaterialApp.router`:
```dart
MaterialApp.router(
  routerConfig: appRouter,
)
```

Navigate with `context.go('/home')`, `context.push('/home')`, or `context.pop()` — these come from `go_router`'s own `BuildContext` extension. `scaffold_project.dart --routing=go_router` deliberately omits `pop`/`pushNamed` from `context_ext.dart` in this mode (see conventions.md) — redeclaring them would collide with go_router's extension and fail to compile.

`scaffold_project.dart --routing=go_router` adds the `go_router` package automatically via `flutter pub add`. Only run `flutter pub add go_router` manually if you're converting an existing named-routes project by hand.
