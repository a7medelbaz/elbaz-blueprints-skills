# Error handling

## Rule — never `catch (_)`

`catch (_)` discards the original error, including any server-provided message. Always:
```dart
catch (e) {
  emit(state.copyWith(status: FeatureStatus.failure, error: sl<ErrorHandler>().handle(e)));
}
```

`ErrorHandler` is always resolved from DI as `sl<ErrorHandler>()` — it is an abstract interface with no static members, so `ErrorHandler.handle(...)` and `ErrorHandler.instance` do not exist and will not compile.

## `AppError`

`core/error/app_error.dart` (already scaffolded by `scaffold_project.dart`):
```dart
class AppError {
  final String message;
  final String? serverMessage;

  const AppError._({required this.message, this.serverMessage});

  factory AppError.unknown([String? message]) =>
      AppError._(message: message ?? 'An unexpected error occurred');
  factory AppError.noInternet() =>
      AppError._(message: 'No internet connection');
  factory AppError.timeout() =>
      AppError._(message: 'Request timed out');
  factory AppError.unauthorized() =>
      AppError._(message: 'Unauthorized');
  factory AppError.serverError([String? serverMessage]) =>
      AppError._(message: 'Server error', serverMessage: serverMessage);
}
```

## `ErrorHandler`

`core/error/error_handler.dart` ships as an abstract interface — implement it once per backend, register the implementation in DI, and every cubit calls the same `sl<ErrorHandler>()` instance:
```dart
abstract class ErrorHandler {
  AppError handle(Object error);
}
```

Example implementation for a REST backend using `dio`:
```dart
import 'package:dio/dio.dart';
import 'app_error.dart';
import 'error_handler.dart';

class DioErrorHandler implements ErrorHandler {
  @override
  AppError handle(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return AppError.timeout();
        case DioExceptionType.connectionError:
          return AppError.noInternet();
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) return AppError.unauthorized();
          return AppError.serverError(error.response?.data?['message']?.toString());
        default:
          return AppError.unknown(error.message);
      }
    }
    return AppError.unknown(error.toString());
  }
}
```

Register it in `core/di/dependency_injection.dart`:
```dart
sl.registerLazySingleton<ErrorHandler>(() => DioErrorHandler());
```

## Standard cubit try/catch pattern

```dart
Future<void> fetchOrderStatus(String orderId) async {
  emit(state.copyWith(status: OrderTrackingStatus.loading));
  try {
    final result = await _repo.fetchStatus(orderId);
    emit(state.copyWith(status: OrderTrackingStatus.success, data: result));
  } catch (e) {
    emit(state.copyWith(
      status: OrderTrackingStatus.failure,
      error: sl<ErrorHandler>().handle(e),
    ));
  }
}
```
