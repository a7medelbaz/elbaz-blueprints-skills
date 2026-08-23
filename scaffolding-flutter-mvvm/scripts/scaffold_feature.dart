// Creates the folder skeleton for a new MVVM feature. Intentionally minimal:
// it does NOT write repo/cubit/state/screen file contents — Claude writes
// those afterward, sized to what the feature actually needs (see SKILL.md).
// Usage: dart run scripts/scaffold_feature.dart <feature_name>
import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run scripts/scaffold_feature.dart <feature_name>');
    exit(1);
  }

  final featureName = args.first;
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(featureName)) {
    stderr.writeln(
      "Error: '$featureName' is not valid snake_case. "
      'Use lowercase letters, digits, and underscores, starting with a letter.',
    );
    exit(1);
  }

  final featureDir = Directory('lib/features/$featureName');

  if (await featureDir.exists()) {
    stderr.writeln("Error: feature '$featureName' already exists at ${featureDir.path} — not overwriting.");
    exit(0);
  }

  final dirsToCreate = [
    '${featureDir.path}/data',
    '${featureDir.path}/logic/cubit',
    '${featureDir.path}/ui',
    '${featureDir.path}/ui/widgets',
  ];

  for (final path in dirsToCreate) {
    await Directory(path).create(recursive: true);
  }

  final gitkeep = File('${featureDir.path}/ui/widgets/.gitkeep');
  await gitkeep.create();

  final className = _toPascalCase(featureName);

  print("✅ Feature '$featureName' scaffolded (folders only — no file content).");
  print('   ${featureDir.path}/data/');
  print('   ${featureDir.path}/logic/cubit/');
  print('   ${featureDir.path}/ui/');
  print('   ${featureDir.path}/ui/widgets/');
  print('');
  print('Now write (sized to what this feature actually needs, see reference/conventions.md):');
  print('   - data/${featureName}_repo.dart + ${featureName}_repo_impl.dart (skip if no data layer needed)');
  print('   - logic/cubit/${featureName}_cubit.dart + ${featureName}_state.dart');
  print('   - ui/${featureName}_screen.dart');
  print('');
  print('Next — do these manually after the files are written:');
  print('  1. Register in core/di/dependency_injection.dart:');
  print('       sl.registerLazySingleton<${className}Repo>(() => ${className}RepoImpl(sl()));');
  print('       sl.registerFactory<${className}Cubit>(() => ${className}Cubit(sl()));');
  print('  2. Add the route in core/router/ (routes.dart + app_router.dart, or the GoRoute list)');
}

String _toPascalCase(String snakeCase) {
  return snakeCase
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join();
}
