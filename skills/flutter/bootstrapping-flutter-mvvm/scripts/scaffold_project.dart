// Scaffolds a Flutter project with MVVM + BLoC (Cubit) architecture.
// Usage: dart run <path-to-skill>/scripts/scaffold_project.dart <project_name>
//          --routing=named|go_router [--dry-run]
//
// Run from the directory that should CONTAIN the project folder (the project's
// parent), not from inside the project. Contrast scaffold_feature.dart, which
// runs from the project root.
//
// Idempotent: existing files are never overwritten, only reported as skipped.
// --dry-run reports exactly what would be created/skipped and which packages
// are missing, without writing anything or running flutter create/pub add.
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
  'flutter_svg',
];

const _usage =
    'Usage: dart run <path-to-skill>/scripts/scaffold_project.dart <project_name> '
    '--routing=named|go_router [--fonts=lang:Family,...] [--dry-run]';

// Language code -> font family. Order matters: the first entry becomes
// AppFonts.fallback (used for any language not explicitly listed) — 'en'
// listed first so unlisted languages (mostly Latin-script) fall back to
// Manrope, not Tajawal.
const _defaultFonts = {'en': 'Manrope', 'ar': 'Tajawal'};

/// When true, nothing is written and no external command runs — every action
/// is only recorded and reported. Set once from --dry-run in main().
bool dryRun = false;

final created = <String>[];
final skipped = <String>[];
final failedPackages = <String>[];

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(_usage);
    exit(1);
  }

  dryRun = args.contains('--dry-run');

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

  final fontsArg = args.firstWhere((a) => a.startsWith('--fonts='), orElse: () => '');
  final fonts = fontsArg.isEmpty ? _defaultFonts : _parseFonts(fontsArg.substring('--fonts='.length));

  // A dry run only reads the filesystem, so it stays useful without the SDK —
  // warn rather than exit, or you can't inspect a project until Flutter is set up.
  if (!await _checkFlutterInstalled()) {
    if (!dryRun) {
      stderr.writeln('Error: Flutter SDK not found on PATH. Install Flutter and ensure `flutter` is runnable, then retry.');
      exit(1);
    }
    print('Warning: Flutter SDK not found on PATH — reporting from the filesystem only.\n');
  }

  final projectDir = Directory(projectName);
  final isNewProject = !await projectDir.exists();

  if (dryRun) {
    print('===== DRY RUN — nothing will be written =====\n');
  }

  if (isNewProject) {
    if (dryRun) {
      // Without a real `flutter create`, none of the generated files exist to
      // probe, so every scaffolded path below is reported as "would create".
      print('Project "$projectName" does not exist yet.');
      print('Would run: flutter create $projectName');
    } else {
      print('Creating new Flutter project: $projectName ...');
      final result = await _flutter(['create', projectName]);
      if (result.exitCode != 0) {
        stderr.writeln('Error: `flutter create $projectName` failed:\n${result.stderr}');
        exit(1);
      }
    }
  } else {
    print('Project directory "$projectName" already exists — '
        '${dryRun ? 'checking' : 'scaffolding into it without overwriting existing files'}.');
  }

  final libDir = '$projectName/lib';

  // Remove the stock counter-demo main.dart; flavor entry points replace it.
  final stockMain = File('$libDir/main.dart');
  if (await stockMain.exists()) {
    if (dryRun) {
      print('Would delete stock lib/main.dart (superseded by main_dev.dart / main_prod.dart).');
    } else {
      await stockMain.delete();
      print('Deleted stock lib/main.dart (superseded by main_dev.dart / main_prod.dart).');
    }
  }

  await _writeFile('$libDir/core/config/app_config.dart', _appConfig);
  await _writeFile('$libDir/core/di/dependency_injection.dart', _dependencyInjection);
  await _writeFile('$libDir/core/error/app_error.dart', _appError);
  await _writeFile('$libDir/core/error/error_handler.dart', _errorHandler);
  await _writeFile('$libDir/core/utils/spacing.dart', _spacing);
  await _writeFile('$libDir/core/utils/extensions/context_ext.dart', _contextExt(routing));
  await _writeFile('$libDir/core/theme/app_colors.dart', _appColors);
  await _writeFile('$libDir/core/theme/app_font_weight.dart', _appFontWeight);
  await _writeFile('$libDir/core/theme/app_text_styles.dart', _appTextStyles);
  await _writeFile('$libDir/core/theme/app_fonts.dart', _appFonts(fonts));
  await _writeFile('$libDir/core/theme/app_font_family.dart', _appFontFamily(fonts));
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

  // Asset folders: images/svgs get a .gitkeep so the (empty) folder survives
  // git and is still safe to register in pubspec before any real file exists.
  // translations/en.json is real content — easy_localization needs at least
  // one locale file present or EasyLocalization.ensureInitialized() throws.
  await _writeFile('$projectName/assets/images/.gitkeep', '');
  await _writeFile('$projectName/assets/svgs/.gitkeep', '');
  await _writeFile('$projectName/assets/fonts/.gitkeep', '');
  await _writeFile('$projectName/assets/translations/en.json', _translationsEn);
  await _ensurePubspecAssets(projectName);
  await _ensurePubspecFonts(projectName, fonts);

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

  if (dryRun) {
    _printSummary(routing, await _missingPackages(projectName, packagesToAdd), fonts);
    return;
  }

  print('\nAdding packages via `flutter pub add` ...');
  for (final pkg in packagesToAdd) {
    final result = await _flutter(['pub', 'add', pkg], workingDirectory: projectName);
    if (result.exitCode != 0) {
      failedPackages.add(pkg);
      stderr.writeln('  ✗ Failed to add $pkg:\n${result.stderr}');
    } else {
      print('  ✓ Added $pkg');
    }
  }

  _printSummary(routing, packagesToAdd, fonts);
}

/// Dry-run only: which required packages are not already in pubspec.yaml.
/// Matches on the dependency key at any indentation, so a package pinned with
/// a version, a git ref, or a path override all count as already present.
Future<List<String>> _missingPackages(String projectName, List<String> required) async {
  final pubspec = File('$projectName/pubspec.yaml');
  if (!await pubspec.exists()) return required; // nothing installed yet
  final lines = (await pubspec.readAsString()).split('\n');
  return required
      .where((pkg) => !lines.any((l) => l.trimLeft().startsWith('$pkg:')))
      .toList();
}

// runInShell is REQUIRED on Windows: Flutter ships as `flutter.bat`, and Dart's
// Process.run uses CreateProcess, which does not resolve PATHEXT — so a bare
// 'flutter' throws ProcessException even on a correct install. Going through
// the shell applies PATHEXT. Harmless on macOS/Linux. Every `flutter` call in
// this script must pass it.
Future<ProcessResult> _flutter(List<String> args, {String? workingDirectory}) =>
    Process.run('flutter', args, runInShell: true, workingDirectory: workingDirectory);

// Parses "ar:Tajawal,en:Manrope" into {'ar': 'Tajawal', 'en': 'Manrope'}.
// Map insertion order is preserved, so the first pair becomes AppFonts.fallback.
Map<String, String> _parseFonts(String arg) {
  final result = <String, String>{};
  for (final pair in arg.split(',')) {
    final parts = pair.split(':');
    if (parts.length != 2 ||
        !RegExp(r'^[a-z]{2,3}$').hasMatch(parts[0]) ||
        !RegExp(r'^[A-Za-z][A-Za-z0-9 ]*$').hasMatch(parts[1])) {
      stderr.writeln(
        "Error: --fonts entry '$pair' is invalid. "
        'Use lang:FamilyName, e.g. --fonts=ar:Tajawal,en:Manrope '
        '(lang = 2-3 lowercase letters, FamilyName = letters/digits/spaces starting with a letter).',
      );
      exit(1);
    }
    result[parts[0]] = parts[1];
  }
  if (result.isEmpty) {
    stderr.writeln('Error: --fonts was given but no valid lang:Family pairs were found.');
    exit(1);
  }
  return result;
}

Future<bool> _checkFlutterInstalled() async {
  try {
    final result = await _flutter(['--version']);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

Future<void> _writeFile(String path, String content, {bool forceOverwrite = false}) async {
  final file = File(path);
  if (await file.exists() && !forceOverwrite) {
    skipped.add(path);
    if (!dryRun) stderr.writeln('  ! Skipped (already exists): $path');
    return;
  }
  created.add(path);
  if (dryRun) return;
  await file.create(recursive: true);
  await file.writeAsString(content);
}

Future<void> _ensureGitignoreHasEnv(String projectName) async {
  final gitignore = File('$projectName/.gitignore');
  const entry = '.env';
  if (!await gitignore.exists()) {
    created.add('$projectName/.gitignore');
    if (dryRun) return;
    await gitignore.writeAsString('$entry\n');
    return;
  }
  final content = await gitignore.readAsString();
  if (!content.split('\n').map((l) => l.trim()).contains(entry)) {
    created.add('$projectName/.gitignore (append `.env`)');
    if (dryRun) return;
    await gitignore.writeAsString('$content\n$entry\n');
  }
}

// Match unindented 'flutter:' only — a stock pubspec.yaml also has an
// INDENTED 'flutter:' under dependencies: (the SDK dependency declaration).
// Matching on l.trim() finds that one first and corrupts the dependencies
// block, which crashes `flutter pub add` on the resulting malformed YAML.
// Top-level YAML keys are always at column 0, so no leading whitespace is
// correct — but trimRight (not trim) is required: pubspec.yaml has CRLF
// line endings, and split('\n') leaves a trailing '\r' on every line that
// a bare `==` comparison would otherwise fail to match.
// Shared by _ensurePubspecAssets and _ensurePubspecFonts so this fix lives
// in exactly one place.
int _findFlutterSectionIndex(List<String> lines) =>
    lines.indexWhere((l) => l.trimRight() == 'flutter:');

// Registers every scaffolded asset folder under `flutter: assets:` in one
// pass, folder-level (trailing slash) rather than file-by-file, so pubspec.yaml
// stays a fixed 5-line block no matter how many images/svgs get dropped in
// later. Flutter only bundles files *directly* inside a folder-level entry
// (not nested subfolders), which matches this flat images/svgs/translations
// layout. Fonts are handled separately by _ensurePubspecFonts — `fonts:` is
// keyed by family name, not by folder, so it can't share this entry list.
Future<void> _ensurePubspecAssets(String projectName) async {
  const assetEntries = [
    '.env',
    'assets/images/',
    'assets/svgs/',
    'assets/translations/',
  ];

  final pubspec = File('$projectName/pubspec.yaml');
  if (!await pubspec.exists()) {
    // Expected in a dry run on a not-yet-created project: `flutter create`
    // hasn't generated pubspec.yaml, so there is nothing to inspect or patch.
    if (dryRun) {
      created.add('$projectName/pubspec.yaml (register assets: ${assetEntries.join(', ')})');
      return;
    }
    stderr.writeln('  ! pubspec.yaml not found — register ${assetEntries.join(', ')} under flutter: assets: manually.');
    return;
  }
  final lines = (await pubspec.readAsString()).split('\n');

  final flutterIdx = _findFlutterSectionIndex(lines);
  if (flutterIdx == -1) {
    stderr.writeln('  ! No `flutter:` section found in pubspec.yaml — add ${assetEntries.join(', ')} under assets manually.');
    return;
  }

  final missing = assetEntries.where((e) => !lines.any((l) => l.trim() == '- $e')).toList();
  if (missing.isEmpty) {
    skipped.add('$projectName/pubspec.yaml (assets already registered)');
    return;
  }
  if (dryRun) {
    created.add('$projectName/pubspec.yaml (register assets: ${missing.join(', ')})');
    return;
  }

  var assetsIdx = lines.indexWhere((l) => l.trim() == 'assets:', flutterIdx);
  if (assetsIdx == -1) {
    lines.insert(flutterIdx + 1, '  assets:');
    assetsIdx = flutterIdx + 1;
  }

  for (final entry in missing) {
    lines.insert(assetsIdx + 1, '    - $entry');
  }

  await pubspec.writeAsString(lines.join('\n'));
}

// Registers a real (uncommented) `fonts:` entry per DISTINCT family in the
// language->family map — Tajawal only appears once even if two languages
// mapped to it. Idempotent per family, not as one blanket flag, so scaffolding
// with a newly added language later inserts only the new family's entry.
// The .ttf files themselves are never fetched (binary, no network) — this
// only registers the filenames the project is expected to provide.
Future<void> _ensurePubspecFonts(String projectName, Map<String, String> fonts) async {
  final families = fonts.values.toSet().toList()..sort();

  final pubspec = File('$projectName/pubspec.yaml');
  if (!await pubspec.exists()) {
    if (dryRun) {
      created.add('$projectName/pubspec.yaml (register fonts: ${families.join(', ')})');
      return;
    }
    stderr.writeln('  ! pubspec.yaml not found — register fonts: ${families.join(', ')} manually.');
    return;
  }
  final lines = (await pubspec.readAsString()).split('\n');

  final flutterIdx = _findFlutterSectionIndex(lines);
  if (flutterIdx == -1) {
    stderr.writeln('  ! No `flutter:` section found in pubspec.yaml — add fonts: ${families.join(', ')} manually.');
    return;
  }

  final missing = families.where((f) => !lines.any((l) => l.trim() == '- family: $f')).toList();
  if (missing.isEmpty) {
    skipped.add('$projectName/pubspec.yaml (fonts already registered)');
    return;
  }
  if (dryRun) {
    created.add('$projectName/pubspec.yaml (register fonts: ${missing.join(', ')})');
    return;
  }

  var fontsIdx = lines.indexWhere((l) => l.trim() == 'fonts:', flutterIdx);
  if (fontsIdx == -1) {
    lines.insert(flutterIdx + 1, '  fonts:');
    fontsIdx = flutterIdx + 1;
  }

  // Insert each missing family right after `fonts:` — order among families
  // doesn't matter to Flutter, only that each appears exactly once.
  for (final family in missing) {
    lines.insertAll(fontsIdx + 1, [
      '    - family: $family',
      '      fonts:',
      '        - asset: assets/fonts/$family-Regular.ttf',
      '        - asset: assets/fonts/$family-Bold.ttf',
      '          weight: 700',
    ]);
  }

  await pubspec.writeAsString(lines.join('\n'));
}

Future<void> _patchAndroidManifestLabel(String projectName) async {
  const label = 'android:label="@string/app_name"';
  final path = '$projectName/android/app/src/main/AndroidManifest.xml';
  final manifest = File(path);
  if (!await manifest.exists()) {
    // Expected in a dry run before `flutter create` has generated it.
    if (dryRun) {
      created.add('$path (patch label to @string/app_name)');
      return;
    }
    stderr.writeln('  ! AndroidManifest.xml not found — set $label manually or flavor app names will not show.');
    return;
  }
  final content = await manifest.readAsString();
  if (content.contains(label)) {
    skipped.add('$path (label already @string/app_name)');
    return;
  }

  final labelPattern = RegExp(r'android:label="[^"]*"');
  if (!labelPattern.hasMatch(content)) {
    stderr.writeln('  ! Could not find android:label in AndroidManifest.xml — set it to "@string/app_name" manually or flavor app names will not show.');
    return;
  }
  created.add('$path (label patched to @string/app_name)');
  if (dryRun) return;
  await manifest.writeAsString(content.replaceFirst(labelPattern, label));
}

void _printSummary(String routing, List<String> packages, Map<String, String> fonts) {
  print(dryRun ? '\n===== Dry run — nothing was written =====' : '\n===== Scaffold summary =====');
  print('Routing mode: $routing');

  print('\n${dryRun ? 'Would create' : 'Created'} (${created.length}):');
  for (final f in created) {
    print('  + $f');
  }

  if (skipped.isNotEmpty) {
    print('\nAlready present, ${dryRun ? 'would skip' : 'skipped'} (${skipped.length}):');
    for (final f in skipped) {
      print('  ! $f');
    }
  }

  if (dryRun) {
    print('\nPackages missing: ${packages.isEmpty ? '(none — all already in pubspec.yaml)' : packages.join(', ')}');
    print('\nRe-run without --dry-run to apply.');
    return;
  }

  print('\nPackages added: ${packages.where((p) => !failedPackages.contains(p)).join(', ')}');
  if (failedPackages.isNotEmpty) {
    print('Packages FAILED to add: ${failedPackages.join(', ')} — add these manually.');
  }
  print('\nNext steps:');
  print('  1. Fill in the real base URL in .env (BASE_URL=...)');
  print('  2. Fill in TODOs in core/theme/* with your real palette/type scale');
  print('  3. Register your first repo/cubit in core/di/dependency_injection.dart');
  print('  4. Drop real files into assets/images/, assets/svgs/ — already registered in pubspec.yaml');
  final exampleFamily = fonts.values.first;
  print('  5. Download the registered font families from fonts.google.com and place them in '
      'assets/fonts/ — filenames must match what pubspec.yaml now lists under fonts: '
      '(e.g. $exampleFamily-Regular.ttf, $exampleFamily-Bold.ttf)');
  print('  6. Add more locales by creating assets/translations/<locale>.json, adding it to '
      'supportedLocales in main_dev.dart / main_prod.dart, and mapping it in AppFonts.byLanguage '
      'if it needs a font other than AppFonts.fallback');
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
import 'package:easy_localization/easy_localization.dart';
import 'core/config/app_config.dart';
import 'core/di/dependency_injection.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await EasyLocalization.ensureInitialized();

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
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const App(),
    ),
  );
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

// TODO: replace every shade below with the project's real palette. The scale
// shape (50 lightest -> 900 darkest) is the reusable part; the values are not.
class AppColors {
  AppColors._();

  static const Color primary50 = Color(0xFFE3F2FD);
  static const Color primary100 = Color(0xFFBBDEFB);
  static const Color primary200 = Color(0xFF90CAF9);
  static const Color primary300 = Color(0xFF64B5F6);
  static const Color primary400 = Color(0xFF42A5F5);
  static const Color primary500 = Color(0xFF2196F3);
  static const Color primary600 = Color(0xFF1E88E5);
  static const Color primary700 = Color(0xFF1976D2);
  static const Color primary800 = Color(0xFF1565C0);
  static const Color primary900 = Color(0xFF0D47A1);

  static const Color secondary50 = Color(0xFFE0F2F1);
  static const Color secondary100 = Color(0xFFB2DFDB);
  static const Color secondary200 = Color(0xFF80CBC4);
  static const Color secondary300 = Color(0xFF4DB6AC);
  static const Color secondary400 = Color(0xFF26A69A);
  static const Color secondary500 = Color(0xFF009688);
  static const Color secondary600 = Color(0xFF00897B);
  static const Color secondary700 = Color(0xFF00796B);
  static const Color secondary800 = Color(0xFF00695C);
  static const Color secondary900 = Color(0xFF004D40);

  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  static const Color red50 = Color(0xFFFFEBEE);
  static const Color red100 = Color(0xFFFFCDD2);
  static const Color red200 = Color(0xFFEF9A9A);
  static const Color red300 = Color(0xFFE57373);
  static const Color red400 = Color(0xFFEF5350);
  static const Color red500 = Color(0xFFF44336);
  static const Color red600 = Color(0xFFE53935);
  static const Color red700 = Color(0xFFD32F2F);
  static const Color red800 = Color(0xFFC62828);
  static const Color red900 = Color(0xFFB71C1C);

  static const Color green50 = Color(0xFFE8F5E9);
  static const Color green100 = Color(0xFFC8E6C9);
  static const Color green200 = Color(0xFFA5D6A7);
  static const Color green300 = Color(0xFF81C784);
  static const Color green400 = Color(0xFF66BB6A);
  static const Color green500 = Color(0xFF4CAF50);
  static const Color green600 = Color(0xFF43A047);
  static const Color green700 = Color(0xFF388E3C);
  static const Color green800 = Color(0xFF2E7D32);
  static const Color green900 = Color(0xFF1B5E20);

  static const Color amber50 = Color(0xFFFFF8E1);
  static const Color amber100 = Color(0xFFFFECB3);
  static const Color amber200 = Color(0xFFFFE082);
  static const Color amber300 = Color(0xFFFFD54F);
  static const Color amber400 = Color(0xFFFFCA28);
  static const Color amber500 = Color(0xFFFFC107);
  static const Color amber600 = Color(0xFFFFB300);
  static const Color amber700 = Color(0xFFFFA000);
  static const Color amber800 = Color(0xFFFF8F00);
  static const Color amber900 = Color(0xFFFF6F00);

  // A distinct family from `primary` (also blue by default) so "info" status
  // colors don't silently equal the brand color — swap both independently.
  static const Color blue50 = Color(0xFFE1F5FE);
  static const Color blue100 = Color(0xFFB3E5FC);
  static const Color blue200 = Color(0xFF81D4FA);
  static const Color blue300 = Color(0xFF4FC3F7);
  static const Color blue400 = Color(0xFF29B6F6);
  static const Color blue500 = Color(0xFF03A9F4);
  static const Color blue600 = Color(0xFF039BE5);
  static const Color blue700 = Color(0xFF0288D1);
  static const Color blue800 = Color(0xFF0277BD);
  static const Color blue900 = Color(0xFF01579B);

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
''';

const _appFontWeight = '''
import 'package:flutter/material.dart';

class AppFontWeight {
  const AppFontWeight._();
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
}
''';

// Fixed size x weight matrix, not parameterized functions — deliberately not
// screen-adaptive (no flutter_screenutil .sp; these are `const`, and .sp is a
// runtime call that can't be const). Extend by adding another named constant,
// not a new parameter — see reference/theming.md.
const _appTextStyles = '''
import 'package:flutter/material.dart';

import 'app_font_weight.dart';

class AppTextStyles {
  const AppTextStyles._();

  // Font Size 24
  static const TextStyle font24ExtraBold = TextStyle(
    fontSize: 24,
    fontWeight: AppFontWeight.extraBold,
  );
  static const TextStyle font24SemiBold = TextStyle(
    fontSize: 24,
    fontWeight: AppFontWeight.semiBold,
  );
  static const TextStyle font24Light = TextStyle(
    fontSize: 24,
    fontWeight: AppFontWeight.light,
  );

  // Font Size 22
  static const TextStyle font22ExtraBold = TextStyle(
    fontSize: 22,
    fontWeight: AppFontWeight.extraBold,
  );
  static const TextStyle font22SemiBold = TextStyle(
    fontSize: 22,
    fontWeight: AppFontWeight.semiBold,
  );
  static const TextStyle font22Light = TextStyle(
    fontSize: 22,
    fontWeight: AppFontWeight.light,
  );

  // Font Size 20
  static const TextStyle font20ExtraBold = TextStyle(
    fontSize: 20,
    fontWeight: AppFontWeight.extraBold,
  );
  static const TextStyle font20SemiBold = TextStyle(
    fontSize: 20,
    fontWeight: AppFontWeight.semiBold,
  );
  static const TextStyle font20Light = TextStyle(
    fontSize: 20,
    fontWeight: AppFontWeight.light,
  );

  // Font Size 18
  static const TextStyle font18ExtraBold = TextStyle(
    fontSize: 18,
    fontWeight: AppFontWeight.extraBold,
  );
  static const TextStyle font18SemiBold = TextStyle(
    fontSize: 18,
    fontWeight: AppFontWeight.semiBold,
  );
  static const TextStyle font18Light = TextStyle(
    fontSize: 18,
    fontWeight: AppFontWeight.light,
  );

  // Font Size 16
  static const TextStyle font16ExtraBold = TextStyle(
    fontSize: 16,
    fontWeight: AppFontWeight.extraBold,
  );
  static const TextStyle font16SemiBold = TextStyle(
    fontSize: 16,
    fontWeight: AppFontWeight.semiBold,
  );
  static const TextStyle font16Light = TextStyle(
    fontSize: 16,
    fontWeight: AppFontWeight.light,
  );

  // Font Size 14
  static const TextStyle font14ExtraBold = TextStyle(
    fontSize: 14,
    fontWeight: AppFontWeight.extraBold,
  );
  static const TextStyle font14SemiBold = TextStyle(
    fontSize: 14,
    fontWeight: AppFontWeight.semiBold,
  );
  static const TextStyle font14Light = TextStyle(
    fontSize: 14,
    fontWeight: AppFontWeight.light,
  );

  // Font Size 12
  static const TextStyle font12ExtraBold = TextStyle(
    fontSize: 12,
    fontWeight: AppFontWeight.extraBold,
  );
  static const TextStyle font12SemiBold = TextStyle(
    fontSize: 12,
    fontWeight: AppFontWeight.semiBold,
  );
  static const TextStyle font12Light = TextStyle(
    fontSize: 12,
    fontWeight: AppFontWeight.light,
  );
}
''';

// Generated from the --fonts flag (default ar:Tajawal,en:Manrope) — the
// map below is real content baked in at scaffold time, not a placeholder.
// AppTextStyles never sets fontFamily itself; app.dart applies this map's
// result to the whole TextTheme so it swaps automatically on locale change
// — see reference/theming.md#fonts for why that's the right layer for it.
String _appFonts(Map<String, String> fonts) {
  final entries = fonts.entries.map((e) => "    '${e.key}': '${e.value}',").join('\n');
  final fallback = fonts.values.first;
  return '''
import 'package:flutter/material.dart';

class AppFonts {
  AppFonts._();

  static const Map<String, String> byLanguage = {
$entries
  };

  // Used for any language not listed in byLanguage.
  static const String fallback = '$fallback';

  static String forLocale(Locale locale) =>
      byLanguage[locale.languageCode] ?? fallback;
}
''';
}

// One constant per DISTINCT family actually chosen via --fonts, named by
// lowerCamelCasing the family — never hardcoded, or a project scaffolded with
// a different --fonts mapping would ship dead constants for fonts it never
// picked, alongside a correct AppFonts.byLanguage that contradicts them.
String _appFontFamily(Map<String, String> fonts) {
  final families = fonts.values.toSet().toList()..sort();
  final constants = families
      .map((f) => "  static const String ${_toCamelCase(f)} = '$f';")
      .join('\n');
  return '''
class AppFontFamily {
  const AppFontFamily._();
$constants
}
''';
}

// 'Noto Sans Arabic' -> 'notoSansArabic'. Family names are already validated
// by _parseFonts to be letters/digits/spaces starting with a letter.
String _toCamelCase(String family) {
  final words = family.split(' ').where((w) => w.isNotEmpty).toList();
  final first = words.first[0].toLowerCase() + words.first.substring(1);
  final rest = words.skip(1).map((w) => w[0].toUpperCase() + w.substring(1));
  return ([first, ...rest]).join();
}

// For colors with no Material component role (no cardTheme/dividerTheme/
// colorScheme.surface/iconTheme field to hold them). A color a standard
// component theme or ColorScheme already covers — surface, border, divider,
// the primary icon color — belongs in ThemeData directly (theme_data_light/
// dark.dart), not here, or there'd be two conflicting sources of truth for
// the same visual property. Stays a ThemeExtension (not a plain class) so
// light/dark transitions animate via lerp, same as every other Material
// theme property.
const _customColors = '''
import 'package:flutter/material.dart';

import 'app_colors.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color textDisabled;
  final Color textInverse;
  final Color background;
  final Color backgroundSecondary;
  final Color backgroundInverse;
  final Color iconSecondary;
  final Color success;
  final Color successBackground;
  final Color warning;
  final Color warningBackground;
  final Color error;
  final Color errorBackground;
  final Color info;
  final Color infoBackground;

  const CustomColors({
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textDisabled,
    required this.textInverse,
    required this.background,
    required this.backgroundSecondary,
    required this.backgroundInverse,
    required this.iconSecondary,
    required this.success,
    required this.successBackground,
    required this.warning,
    required this.warningBackground,
    required this.error,
    required this.errorBackground,
    required this.info,
    required this.infoBackground,
  });

  static const light = CustomColors(
    textPrimary: AppColors.black,
    textSecondary: AppColors.grey600,
    textHint: AppColors.grey400,
    textDisabled: AppColors.grey300,
    textInverse: AppColors.white,
    background: AppColors.backgroundLight,
    backgroundSecondary: AppColors.grey50,
    backgroundInverse: AppColors.black,
    iconSecondary: AppColors.grey400,
    success: AppColors.green700,
    successBackground: AppColors.green50,
    warning: AppColors.amber700,
    warningBackground: AppColors.amber50,
    error: AppColors.red700,
    errorBackground: AppColors.red50,
    info: AppColors.blue700,
    infoBackground: AppColors.blue50,
  );

  static const dark = CustomColors(
    textPrimary: AppColors.white,
    textSecondary: AppColors.grey300,
    textHint: AppColors.grey500,
    textDisabled: AppColors.grey600,
    textInverse: AppColors.black,
    background: AppColors.backgroundDark,
    backgroundSecondary: AppColors.grey800,
    backgroundInverse: AppColors.white,
    iconSecondary: AppColors.grey500,
    success: AppColors.green200,
    successBackground: AppColors.green800,
    warning: AppColors.amber200,
    warningBackground: AppColors.amber800,
    error: AppColors.red200,
    errorBackground: AppColors.red800,
    info: AppColors.blue200,
    infoBackground: AppColors.blue800,
  );

  @override
  CustomColors copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? textDisabled,
    Color? textInverse,
    Color? background,
    Color? backgroundSecondary,
    Color? backgroundInverse,
    Color? iconSecondary,
    Color? success,
    Color? successBackground,
    Color? warning,
    Color? warningBackground,
    Color? error,
    Color? errorBackground,
    Color? info,
    Color? infoBackground,
  }) => CustomColors(
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textHint: textHint ?? this.textHint,
    textDisabled: textDisabled ?? this.textDisabled,
    textInverse: textInverse ?? this.textInverse,
    background: background ?? this.background,
    backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
    backgroundInverse: backgroundInverse ?? this.backgroundInverse,
    iconSecondary: iconSecondary ?? this.iconSecondary,
    success: success ?? this.success,
    successBackground: successBackground ?? this.successBackground,
    warning: warning ?? this.warning,
    warningBackground: warningBackground ?? this.warningBackground,
    error: error ?? this.error,
    errorBackground: errorBackground ?? this.errorBackground,
    info: info ?? this.info,
    infoBackground: infoBackground ?? this.infoBackground,
  );

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      backgroundInverse: Color.lerp(backgroundInverse, other.backgroundInverse, t)!,
      iconSecondary: Color.lerp(iconSecondary, other.iconSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBackground: Color.lerp(successBackground, other.successBackground, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBackground: Color.lerp(warningBackground, other.warningBackground, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBackground: Color.lerp(infoBackground, other.infoBackground, t)!,
    );
  }
}
''';

const _themeDataLight = '''
import 'package:flutter/material.dart';

import '../../utils/spacing.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';
import '../custom_colors.dart';

ThemeData get lightTheme => ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  extensions: const [CustomColors.light],

  // ─── Color Scheme ─────────────────────────────────────────────────────
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary200,
    brightness: Brightness.light,
    primary: AppColors.primary200,
    onPrimary: AppColors.white,
    secondary: AppColors.secondary200,
    onSecondary: AppColors.white,
    surface: AppColors.backgroundLight,
    onSurface: AppColors.black,
    error: AppColors.red200,
    onError: AppColors.white,
  ),

  // ─── Text ─────────────────────────────────────────────────────────────
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: AppColors.black,
    displayColor: AppColors.black,
  ),

  // ─── Elevated Button ──────────────────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary200,
      foregroundColor: AppColors.white,
      disabledBackgroundColor: AppColors.grey100,
      disabledForegroundColor: AppColors.grey400,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rr(12)),
      ),
      textStyle: AppTextStyles.font16ExtraBold,
    ),
  ),

  // ─── Text Button ──────────────────────────────────────────────────────
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary200,
      textStyle: AppTextStyles.font16ExtraBold,
    ),
  ),

  // ─── Outlined Button ──────────────────────────────────────────────────
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary200,
      side: const BorderSide(color: AppColors.primary200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rr(12)),
      ),
      textStyle: AppTextStyles.font16ExtraBold,
    ),
  ),

  // ─── Input Decoration ─────────────────────────────────────────────────
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.focused)) return AppColors.primary50;
      return AppColors.white;
    }),
    hintStyle: AppTextStyles.font16Light.copyWith(color: AppColors.grey400),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rr(10)),
      borderSide: const BorderSide(color: AppColors.grey200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rr(10)),
      borderSide: const BorderSide(color: AppColors.grey200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rr(10)),
      borderSide: const BorderSide(color: AppColors.primary200),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rr(10)),
      borderSide: const BorderSide(color: AppColors.red200),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rr(10)),
      borderSide: const BorderSide(color: AppColors.red300),
    ),
  ),

  // ─── Card ─────────────────────────────────────────────────────────────
  cardTheme: CardThemeData(
    color: AppColors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(rr(12)),
      side: const BorderSide(color: AppColors.grey100),
    ),
  ),

  // ─── Divider ──────────────────────────────────────────────────────────
  dividerTheme: const DividerThemeData(
    color: AppColors.grey100,
    thickness: 1,
  ),

  // ─── Icon ─────────────────────────────────────────────────────────────
  iconTheme: const IconThemeData(color: AppColors.grey700),
);
''';

const _themeDataDark = '''
import 'package:flutter/material.dart';

import '../../utils/spacing.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';
import '../custom_colors.dart';

ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  extensions: const [CustomColors.dark],

  // ─── Color Scheme ─────────────────────────────────────────────────────
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary200,
    brightness: Brightness.dark,
    primary: AppColors.primary200,
    onPrimary: AppColors.white,
    secondary: AppColors.secondary200,
    onSecondary: AppColors.white,
    surface: AppColors.backgroundDark,
    onSurface: AppColors.white,
    error: AppColors.red200,
    onError: AppColors.white,
  ),

  // ─── Text ─────────────────────────────────────────────────────────────
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: AppColors.white,
    displayColor: AppColors.white,
  ),

  // ─── Elevated Button ──────────────────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary200,
      foregroundColor: AppColors.white,
      disabledBackgroundColor: AppColors.grey700,
      disabledForegroundColor: AppColors.grey500,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rr(12)),
      ),
      textStyle: AppTextStyles.font16ExtraBold,
    ),
  ),

  // ─── Text Button ──────────────────────────────────────────────────────
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary200,
      textStyle: AppTextStyles.font16ExtraBold,
    ),
  ),

  // ─── Outlined Button ──────────────────────────────────────────────────
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary200,
      side: const BorderSide(color: AppColors.primary200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rr(12)),
      ),
      textStyle: AppTextStyles.font16ExtraBold,
    ),
  ),

  // ─── Input Decoration ─────────────────────────────────────────────────
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.focused)) return AppColors.grey700;
      return AppColors.grey800;
    }),
    hintStyle: AppTextStyles.font16Light.copyWith(color: AppColors.grey500),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rr(10)),
      borderSide: const BorderSide(color: AppColors.grey600),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rr(10)),
      borderSide: const BorderSide(color: AppColors.grey600),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rr(10)),
      borderSide: const BorderSide(color: AppColors.primary200),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rr(10)),
      borderSide: const BorderSide(color: AppColors.red200),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rr(10)),
      borderSide: const BorderSide(color: AppColors.red300),
    ),
  ),

  // ─── Card ─────────────────────────────────────────────────────────────
  cardTheme: CardThemeData(
    color: AppColors.grey800,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(rr(12)),
      side: const BorderSide(color: AppColors.grey700),
    ),
  ),

  // ─── Divider ──────────────────────────────────────────────────────────
  dividerTheme: const DividerThemeData(
    color: AppColors.grey700,
    thickness: 1,
  ),

  // ─── Icon ─────────────────────────────────────────────────────────────
  iconTheme: const IconThemeData(color: AppColors.grey200),
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
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/app_fonts.dart';
import 'core/theme/theme_data/theme_data_light.dart';
import 'core/theme/theme_data/theme_data_dark.dart';
import 'core/router/app_router.dart';
// TODO: wrap with MultiBlocProvider once cubits are registered in DI

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // fontFamily is applied to the whole TextTheme, not baked into AppTextStyles,
    // so it swaps automatically whenever context.locale changes — see
    // reference/theming.md#fonts.
    final fontFamily = AppFonts.forLocale(context.locale);
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: lightTheme.copyWith(
          textTheme: lightTheme.textTheme.apply(fontFamily: fontFamily),
        ),
        darkTheme: darkTheme.copyWith(
          textTheme: darkTheme.textTheme.apply(fontFamily: fontFamily),
        ),
        themeMode: ThemeMode.system,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
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
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/app_fonts.dart';
import 'core/theme/theme_data/theme_data_light.dart';
import 'core/theme/theme_data/theme_data_dark.dart';
import 'core/router/routes.dart';
import 'core/router/app_router.dart';
// TODO: wrap with MultiBlocProvider once cubits are registered in DI

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // fontFamily is applied to the whole TextTheme, not baked into AppTextStyles,
    // so it swaps automatically whenever context.locale changes — see
    // reference/theming.md#fonts.
    final fontFamily = AppFonts.forLocale(context.locale);
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme.copyWith(
          textTheme: lightTheme.textTheme.apply(fontFamily: fontFamily),
        ),
        darkTheme: darkTheme.copyWith(
          textTheme: darkTheme.textTheme.apply(fontFamily: fontFamily),
        ),
        themeMode: ThemeMode.system,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
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

// Seed locale so EasyLocalization has at least one valid file to load at
// startup. Namespace new keys by feature (see reference/conventions.md
// under Localization) rather than adding top-level keys here.
const _translationsEn = '''
{
  "app_name": "App"
}
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
