# Routing

`scaffold_project.dart` writes the router for the mode chosen at scaffold time and wires it into `app.dart`. This describes how to **choose** the mode and **add routes** — the base files already exist.

## Contents
- Choosing a mode
- Adding a route (named)
- Adding a route (go_router)
- Navigation helpers per mode

## Choosing a mode

| | Named routes | go_router |
|---|---|---|
| Deep linking / web URLs | No | Yes |
| Nested navigation (tabs with their own stacks) | Awkward | Native |
| Route count | Small (<15) | Any |
| Setup complexity | Minimal | More boilerplate |

Default to **named routes** unless the project needs deep linking, web support, or nested navigators.

Switching modes later means rewriting `core/router/` **and** `app.dart` (`MaterialApp` vs `MaterialApp.router`) **and** `context_ext.dart` — so confirm with the user before scaffolding rather than converting afterward.

## Adding a route — named

Two edits, both required:

1. A constant in `core/router/routes.dart`:
   ```dart
   static const String home = '/home';
   ```
2. A case in `core/router/app_router.dart`'s switch, above `default`:
   ```dart
   case Routes.home:
     return MaterialPageRoute(builder: (_) => const HomeScreen());
   ```

If the screen needs a cubit, provide it at the route so it is scoped to that screen:
```dart
case Routes.home:
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => sl<HomeCubit>(),
      child: const HomeScreen(),
    ),
  );
```

Passing arguments: read `settings.arguments` and cast it in the `case`.

## Adding a route — go_router

One edit — a `GoRoute` in the `routes:` list in `core/router/app_router.dart`:
```dart
GoRoute(
  path: '/home',
  builder: (context, state) => const HomeScreen(),
),
```
Nest sub-navigation with a `routes: [...]` list inside a parent `GoRoute`. Path parameters come from `state.pathParameters['id']`.

## Navigation helpers per mode

**Named:** use the `context_ext.dart` helpers — `context.pushNamed(Routes.home)`, `context.pop()`.

**go_router:** use go_router's own extension — `context.go('/home')`, `context.push('/home')`, `context.pop()`. In this mode `context_ext.dart` deliberately omits `pop`/`pushNamed`, because redeclaring them alongside go_router's extension is an ambiguous-extension-member compile error.

Either way, never call `Navigator.push`/`Navigator.pop` directly.
