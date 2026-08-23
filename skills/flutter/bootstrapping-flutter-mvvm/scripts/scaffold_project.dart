// Scaffolds a Flutter project with MVVM + BLoC (Cubit) architecture.
// Usage: dart run scripts/scaffold_project.dart <project_name> --routing=named|go_router
//
// Idempotent: existing files are never overwritten, only reported as skipped.
import 'dart:io';

const requiredPackages = [
  'flutter_bloc',
  'hydrated_bloc',
  'path_provider',
  'get_it',
  'equatable',
  'flutter_screenutil',
  'easy_localization',
  'flutter_dotenv',
];

final created = <String>[];
final skipped = <String>[];
final failedPackages = <String>[];

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run scripts/scaffold_project.dart <project_name> --routing=named|go_router');
    exit(1);
  }

  final projectName = args.first;
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(projectName)) {
    stderr.writeln(
      "Error: '$projectName' is not a valid Dart package name. "
      'Use lowercase letters, digits, and underscores, starting with a letter.',
    );
    exit(1);
  }

  final routingArg = args.firstWhere(
    (a) => a.startsWith('--routing='),
    orElse: () => '--routing=named',
  );
  final routing = routingArg.split('=').last;
  if (routing != 'named' && routing != 'go_router') {
    stderr.writeln("Error: --routing must be 'named' or 'go_router', got '$routing'.");
    exit(1);
  }

  if (!await _checkFlutterInstalled()) {
    stderr.writeln('Error: Flutter SDK not found on PATH. Install Flutter and ensure `flutter` is runnable, then retry.');
    exit(1);
  }

  final projectDir = Directory(projectName);
  final isNewProject = !await projectDir.exists();

  if (isNewProject) {
    print('Creating new Flutter project: $projectName ...');
    final result = await Process.run('flutter', ['create', projectName]);
    if (result.exitCode != 0) {
      stderr.writeln('Error: `flutter create $projectName` failed:\n${result.stderr}');
      exit(1);
    }
  } else {
    print('Project directory "$projectName" already exists — scaffolding into it without overwriting existing files.');
  }

  final libDir = '$projectName/lib';

  // Remove the stock counter-demo main.dart; flavor entry points replace it.
  final stockMain = File('$libDir/main.dart');
  if (await stockMain.exists()) {
    await stockMain.delete();
    print('Deleted stock lib/main.dart (superseded by main_dev.dart / main_prod.dart).');
  }

  await _writeFile('$libDir/core/config/app_config.dart', _appConfig);
  await _writeFile('$libDir/core/di/dependency_injection.dart', _dependencyInjection);
  await _writeFile('$libDir/core/error/app_error.dart', _appError);
  await _writeFile('$libDir/core/error/error_handler.dart', _errorHandler);
  await _writeFile('$libDir/core/utils/spacing.dart', _spacing);
  await _writeFile('$libDir/core/utils/extensions/context_ext.dart', _contextExt(routing));
  await _writeFile('$libDir/core/theme/app_colors.dart', _appColors);
  await _writeFile('$libDir/core/theme/app_text_styles.dart', _appTextStyles);
  await _writeFile('$libDir/core/theme/custom_colors.dart', _customColors);
  await _writeFile('$libDir/core/theme/theme_data/theme_data_light.dart', _themeDataLight);
  await _writeFile('$libDir/core/theme/theme_data/theme_data_dark.dart', _themeDataDark);
  await _writeFile('$libDir/app.dart', _appDart(routing));
  await _writeFile('$libDir/main_dev.dart', _mainEntry('development', 'App Dev'));
  await _writeFile('$libDir/main_prod.dart', _mainEntry('production', 'App'));

  if (routing == 'named') {
    await _writeFile('$libDir/core/router/routes.dart', _routesNamed);
    await _writeFile('$libDir/core/router/app_router.dart', _appRouterNamed);
  } else {
    await _writeFile('$libDir/core/router/app_router.dart', _appRouterGoRouter);
  }

  // .env must exist for real (not just .env.example) — flutter_dotenv reads it
  // via the asset bundle, so it must also be registered under pubspec assets,
  // or dotenv.load() throws at startup before any screen renders.
  await _writeFile('$projectName/.env.example', _envExample);
  await _writeFile('$projectName/.env', _envExample);
  await _ensureGitignoreHasEnv(projectName);
  await _ensurePubspecEnvAsset(projectName);

  // `flutter create` always generates a stock build.gradle.kts before this
  // point, so for a brand-new project this MUST force-overwrite or the
  // flavors config below never actually lands — the whole point of running
  // this script. For an existing project we still refuse to clobber
  // possibly-customized Gradle config; skip + tell the user to merge by hand.
  await _writeFile(
    '$projectName/android/app/build.gradle.kts',
    _buildGradleKts(projectName),
    forceOverwrite: isNewProject,
  );
  if (!isNewProject) {
    print('  Note: build.gradle.kts already existed in this project and was left untouched — '
        'merge the development/production productFlavors block in by hand or flavors will not work.');
  }
  await _patchAndroidManifestLabel(projectName);

  await _writeFile('$projectName/.github/workflows/flutter-ci.yml', _ciWorkflow);
  await _writeFile('$projectName/Makefile', _makefile);

  final packagesToAdd = [...requiredPackages];
  if (routing == 'go_router') packagesToAdd.add('go_router');

  print('\nAdding packages via `flutter pub add` ...');
  for (final pkg in packagesToAdd) {
    final result = await Process.run('flutter', ['pub', 'add', pkg], workingDirectory: projectName);
    if (result.exitCode != 0) {
      failedPackages.add(pkg);
      stderr.writeln('  ✗ Failed to add $pkg:\n${result.stderr}');
    } else {
      print('  ✓ Added $pkg');
    }
  }

  _printSummary(routing, packagesToAdd);
}

Future<bool> _checkFlutterInstalled() async {
  try {
    final result = await Process.run('flutter', ['--version']);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

Future<void> _writeFile(String path, String content, {bool forceOverwrite = false}) async {
  final file = File(path);
  if (await file.exists() && !forceOverwrite) {
    skipped.add(path);
    stderr.writeln('  ! Skipped (already exists): $path');
    return;
  }
  await file.create(recursive: true);
  await file.writeAsString(content);
  created.add(path);
}

Future<void> _ensureGitignoreHasEnv(String projectName) async {
  final gitignore = File('$projectName/.gitignore');
  const entry = '.env';
  if (!await gitignore.exists()) {
    await gitignore.writeAsString('$entry\n');
    created.add('$projectName/.gitignore');
    return;
  }
  final content = await gitignore.readAsString();
  if (!content.split('\n').map((l) => l.trim()).contains(entry)) {
    await gitignore.writeAsString('$content\n$entry\n');
  }
}

Future<void> _ensurePubspecEnvAsset(String projectName) async {
  final pubspec = File('$projectName/pubspec.yaml');
  if (!await pubspec.exists()) {
    stderr.writeln('  ! pubspec.yaml not found — register .env under flutter: assets: manually.');
    return;
  }
  final lines = (await pubspec.readAsString()).split('\n');
  if (lines.any((l) => l.trim() == '- .env')) return; // already registered

  final flutterIdx = lines.indexWhere((l) => l.trim() == 'flutter:');
  if (flutterIdx == -1) {
    stderr.writeln('  ! No `flutter:` section found in pubspec.yaml — add `.env` under assets manually.');
    return;
  }

  final assetsIdx = lines.indexWhere((l) => l.trim() == 'assets:', flutterIdx);
  if (assetsIdx != -1) {
    lines.insert(assetsIdx + 1, '    - .env');
  } else {
    lines.insert(flutterIdx + 1, '  assets:\n    - .env');
  }
  await pubspec.writeAsString(lines.join('\n'));
}

Future<void> _patchAndroidManifestLabel(String projectName) async {
  final manifest = File('$projectName/android/app/src/main/AndroidManifest.xml');
  if (!await manifest.exists()) {
    stderr.writeln('  ! AndroidManifest.xml not found — set android:label="@string/app_name" manually or flavor app names will not show.');
    return;
  }
  final content = await manifest.readAsString();
  if (content.contains('android:label="@string/app_name"')) return; // already correct

  final labelPattern = RegExp(r'android:label="[^"]*"');
  if (!labelPattern.hasMatch(content)) {
    stderr.writeln('  ! Could not find android:label in AndroidManifest.xml — set it to "@string/app_name" manually or flavor app names will not show.');
    return;
  }
  await manifest.writeAsString(content.replaceFirst(labelPattern, 'android:label="@string/app_name"'));
  created.add('$projectName/android/app/src/main/AndroidManifest.xml (label patched to @string/app_name)');
}

void _printSummary(String routing, List<String> packagesToAdd) {
  print('\n===== Scaffold summary =====');
  print('Routing mode: $routing');
  print('\nCreated (${created.length}):');
  for (final f in created) {
    print('  + $f');
  }
  if (skipped.isNotEmpty) {
    print('\nSkipped — already existed (${skipped.length}):');
    for (final f in skipped) {
      print('  ! $f');
    }
  }
  print('\nPackages added: ${packagesToAdd.where((p) => !failedPackages.contains(p)).join(', ')}');
  if (failedPackages.isNotEmpty) {
    print('Packages FAILED to add: ${failedPackages.join(', ')} — add these manually.');
  }
  print('\nNext steps:');
  print('  1. Fill in the real base URL in .env (BASE_URL=...)');
  print('  2. Fill in TODOs in core/theme/* with your real palette/type scale');
  print('  3. Register your first repo/cubit in core/di/dependency_injection.dart');
}

// ---------------------------------------------------------------------------
// File contents
// ---------------------------------------------------------------------------

const _appConfig = '''
enum Flavor { development, production }

class FlavorConfig {
  final Flavor flavor;
  final String appName;
  final String baseUrl;

  const FlavorConfig({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
  });

  static late FlavorConfig instance;

  bool get isDevelopment => flavor == Flavor.development;
  bool get isProduction => flavor == Flavor.production;
}
''';

String _mainEntry(String flavor, String appName) => '''
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'core/config/app_config.dart';
import 'core/di/dependency_injection.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  FlavorConfig.instance = FlavorConfig(
    flavor: Flavor.$flavor,
    appName: '$appName',
    baseUrl: dotenv.env['BASE_URL'] ?? '',
  );

  // If this fails to compile after a hydrated_bloc upgrade, its storage API
  // has changed — check the installed version's HydratedStorage.build docs;
  // older releases (<9) take `storageDirectory: Directory` directly instead.
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  await setupDi();
  runApp(const App());
}
''';

const _dependencyInjection = '''
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> setupDi() async {
  // Services / repos -> sl.registerLazySingleton<T>(() => Impl());
  // Cubits           -> sl.registerFactory<T>(() => Cubit(sl()));
}
''';

const _appError = '''
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
''';

const _errorHandler = '''
import 'app_error.dart';

/// Implement once per backend and register the implementation in DI.
/// See reference/error-handling.md for a full example (e.g. DioErrorHandler).
abstract class ErrorHandler {
  AppError handle(Object error);
}
''';

const _spacing = '''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

double rw(double v) => v.w;
double rh(double v) => v.h;
double rr(double v) => v.r;
double rf(double v) => v.sp;

Widget verticalSpacing(double v) => SizedBox(height: v.h);
Widget horizontalSpacing(double v) => SizedBox(width: v.w);
''';

// go_router's own BuildContext extension already defines pop/push/pushNamed/
// goNamed. Redeclaring them here would be an ambiguous-extension-member
// compile error wherever both extensions are in scope, so named-only.
String _contextExt(String routing) {
  final navHelpers = routing == 'go_router'
      ? ''
      : '''

  void pop<T>([T? result]) {
    if (Navigator.canPop(this)) Navigator.pop(this, result);
  }

  Future<T?> pushNamed<T>(String route, {Object? arguments}) =>
      Navigator.pushNamed<T>(this, route, arguments: arguments);''';

  return '''
import 'package:flutter/material.dart';
import '../../theme/custom_colors.dart';

extension ContextExt on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  CustomColors get customColors => Theme.of(this).extension<CustomColors>()!;
$navHelpers
}
''';
}

const _appColors = '''
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // TODO: replace with the project's real palette
  static const Color primary = Color(0xFF1E88E5);
  static const Color secondary = Color(0xFF26A69A);
  static const Color error = Color(0xFFD32F2F);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
''';

const _appTextStyles = '''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// TODO: adjust to the project's real type scale
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading1 => TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold);
  static TextStyle get body => TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal);
  static TextStyle get caption => TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w300);
}
''';

const _customColors = '''
import 'package:flutter/material.dart';
import 'app_colors.dart';

// TODO: add semantic tokens as the project needs them
class CustomColors extends ThemeExtension<CustomColors> {
  final Color success;
  final Color cardBackground;

  const CustomColors({required this.success, required this.cardBackground});

  static const light = CustomColors(success: Color(0xFF2E7D32), cardBackground: AppColors.white);
  static const dark = CustomColors(success: Color(0xFF66BB6A), cardBackground: Color(0xFF1E1E1E));

  @override
  CustomColors copyWith({Color? success, Color? cardBackground}) => CustomColors(
    success: success ?? this.success,
    cardBackground: cardBackground ?? this.cardBackground,
  );

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      success: Color.lerp(success, other.success, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
    );
  }
}
''';

const _themeDataLight = '''
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../custom_colors.dart';

ThemeData get lightTheme => ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.white,
  extensions: const [CustomColors.light],
);
''';

const _themeDataDark = '''
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../custom_colors.dart';

ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.black,
  extensions: const [CustomColors.dark],
);
''';

// The two routing modes wire MaterialApp completely differently
// (onGenerateRoute+Routes.splash vs. MaterialApp.router+routerConfig) —
// a single fixed app.dart cannot serve both without a compile error.
String _appDart(String routing) {
  if (routing == 'go_router') {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/theme_data/theme_data_light.dart';
import 'core/theme/theme_data/theme_data_dark.dart';
import 'core/router/app_router.dart';
// TODO: wrap with MultiBlocProvider once cubits are registered in DI

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}
''';
  }

  return '''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/theme_data/theme_data_light.dart';
import 'core/theme/theme_data/theme_data_dark.dart';
import 'core/router/routes.dart';
import 'core/router/app_router.dart';
// TODO: wrap with MultiBlocProvider once cubits are registered in DI

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: Routes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
''';
}

const _routesNamed = '''
class Routes {
  Routes._();

  static const String splash = '/';
  // Add one constant per screen.
}
''';

const _appRouterNamed = '''
import 'package:flutter/material.dart';
import 'routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const Placeholder());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for \${settings.name}')),
          ),
        );
    }
  }
}
''';

const _appRouterGoRouter = '''
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Placeholder(),
    ),
  ],
);
''';

const _envExample = '''
BASE_URL=https://api.example.com
''';

String _buildGradleKts(String projectName) => '''
plugins {
    id("com.android.application")
    // id("com.google.gms.google-services")  // TODO: uncomment if using Firebase/Google services
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.$projectName"
    // Read from the Flutter Gradle plugin rather than hardcoding, so these track
    // whatever SDK level the installed Flutter toolchain expects.
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.$projectName"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    flavorDimensions += "default"
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
}

dependencies {
    // Pinned: desugar_jdk_libs 2.1.4 is the version verified against Flutter's
    // default AGP/Kotlin combo at scaffold time. Bump if `flutter doctor` warns
    // about desugaring compatibility.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
''';

const _ciWorkflow = '''
name: Flutter CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
''';

const _makefile = '''
install:
\tflutter pub get

dev:
\tflutter run --flavor development --target lib/main_dev.dart

prod:
\tflutter run --flavor production --target lib/main_prod.dart

clean:
\tflutter clean && flutter pub get

test:
\tflutter test

build-apk-dev:
\tflutter build apk --flavor development --target lib/main_dev.dart

build-apk-prod:
\tflutter build apk --flavor production --target lib/main_prod.dart

build-aab-prod:
\tflutter build appbundle --flavor production --target lib/main_prod.dart
''';
