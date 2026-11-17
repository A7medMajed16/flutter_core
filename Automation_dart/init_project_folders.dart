// ignore_for_file: unused_local_variable

import 'dart:io';

// ============================================================================
//  OPTIONAL FEATURES — not every project needs these.
//  Set a feature to `true` (or pass its name as an argument, e.g.
//  `dart run init_project_folders.dart location hijri`) to:
//    1. add its packages to pubspec.yaml
//    2. uncomment its code in lib/core (blocks marked //#optional:<name>)
//  Left `false`, the code stays commented out and nothing fails to compile.
// ============================================================================
const optionalFeatures = <String, bool>{
  'location': false,
  'video': false,
  'hijri': false,
  'firebase_extras': false,
  'extras': false,
};

const optionalPackages = <String, List<String>>{
  // core/helper/system/location_helper.dart
  // core/common/widgets/sheets/map_chooser_bottom_sheet.dart
  'location': ['geolocator', 'geocoding', 'latlong2', 'map_launcher'],
  // core/common/widgets/display/normal_video_player.dart
  'video': ['chewie', 'video_player'],
  // DateTimeHelper.formatToHijriAndGregorian
  'hijri': ['hijri'],
  // No core code — common app packages
  'firebase_extras': [
    'firebase_analytics',
    'firebase_auth',
    'firebase_crashlytics',
    'firebase_storage',
  ],
  // No core code — packages many (not all) apps use
  'extras': [
    'file_picker',
    'image_picker',
    'image_cropper',
    'lottie',
    'pinput',
    'uuid',
    'flutter_dotenv',
  ],
};

// Packages used by live (uncommented) code in core/ and main/.
// Every project gets these. If you add a package import to core,
// add it here too, or new projects will fail to analyze.
const coreDependencies = [
  // Flutter 3.50+: Material & Cupertino live in standalone packages
  'material_ui',
  'cupertino_ui',
  'auto_route',
  'bloc',
  'cached_network_image',
  'dartz',
  'dio',
  'easy_localization',
  'equatable',
  'flutter_bloc',
  'flutter_cache_manager',
  'flutter_screenutil',
  'flutter_secure_storage',
  'flutter_svg',
  'freezed_annotation',
  'get_it',
  'image',
  'injectable',
  'just_audio',
  'liquid_pull_to_refresh',
  'ntp',
  'package_info_plus',
  'path',
  'path_provider',
  'pretty_dio_logger',
  'shared_preferences',
  'shimmer',
  'sliver_tools',
  'toastification',
  'url_launcher',
  'vector_graphics',
  'vibration',
  // core/helper/system/firebase_notifications.dart.
  // Firebase itself stays disabled until you uncomment the init in main.dart.
  'firebase_core',
  'firebase_messaging',
  'flutter_local_notifications',
  'permission_handler',
];

const sdkDependencies = ['flutter_web_plugins'];

const devDependencies = [
  'auto_route_generator',
  'build_runner',
  'flutter_launcher_icons',
  'flutter_native_splash',
  'freezed',
  'injectable_generator',
];

void log(String message) => stdout.writeln(message);

/// Uncomments every `//#optional:<feature>` ... `//#end-optional:<feature>`
/// block under [dir] by removing one leading `// ` from each line.
void enableOptionalCode(Directory dir, String feature) {
  final start = '//#optional:$feature';
  final end = '//#end-optional:$feature';
  final commentPrefix = RegExp(r'^(\s*)// ?');

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final content = entity.readAsStringSync();
    if (!content.contains(start)) continue;

    var inside = false;
    final lines = content.split('\n').map((line) {
      final trimmed = line.trim();
      if (trimmed == start) {
        inside = true;
        // Renamed so a second run never double-uncomments
        return line.replaceFirst('#optional:', '#optional-enabled:');
      }
      if (trimmed == end) {
        inside = false;
        return line;
      }
      return inside
          ? line.replaceFirstMapped(commentPrefix, (m) => m[1]!)
          : line;
    });
    entity.writeAsStringSync(lines.join('\n'));
    log('Enabled "$feature" in ${entity.path} ✓');
  }
}

Future<bool> runCommand(String executable, List<String> args) async {
  log('Running: $executable ${args.join(' ')}');
  final result = await Process.run(
    executable,
    args,
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  if (result.exitCode == 0) {
    log('Done ✓');
    return true;
  }
  log('Failed ✗\n${result.stdout}\n${result.stderr}');
  return false;
}

Future<bool> runFlutter(List<String> args) => runCommand('flutter', args);

void main(List<String> args) async {
  final enabledFeatures = {
    ...optionalFeatures.entries.where((e) => e.value).map((e) => e.key),
    ...args,
  };
  final unknown = enabledFeatures.difference(optionalFeatures.keys.toSet());
  if (unknown.isNotEmpty) {
    log('Unknown optional feature(s): ${unknown.join(', ')}');
    log('Available: ${optionalFeatures.keys.join(', ')}');
    return;
  }
  log('Optional features: ${enabledFeatures.isEmpty ? 'none' : enabledFeatures.join(', ')}');

  final mainCorePath = "/Users/ahmedmajed/Desktop/Projects/core";
  final corePath = "$mainCorePath/core";

  final projectPath = "${Directory.current.path}/lib";
  final destinationPath = "$projectPath/core";

  log('Source path: $corePath');
  log('Destination path: $destinationPath');

  final sourceDir = Directory(corePath);
  if (!sourceDir.existsSync()) {
    log('ERROR: Source directory does not exist: $corePath');
    return;
  }

  final coreDirectory = Directory(destinationPath);
  if (!coreDirectory.existsSync()) {
    coreDirectory.createSync(recursive: true);
    log('Created destination directory: $destinationPath ✓');
  }

  void copyDirectory(String source, String destination) {
    final sourceDir = Directory(source);
    final destDir = Directory(destination);

    if (!sourceDir.existsSync()) {
      log('Source directory does not exist: $source ✗');
      return;
    }

    if (!destDir.existsSync()) {
      destDir.createSync(recursive: true);
    }

    for (var entity in sourceDir.listSync()) {
      final fileName = entity.path.split(Platform.pathSeparator).last;
      final newPath =
          '${destDir.path}${Platform.pathSeparator}$fileName';

      if (fileName == '.DS_Store') continue;

      if (entity is File) {
        entity.copySync(newPath);
        log('Copied file: $newPath ✓');
      } else if (entity is Directory) {
        copyDirectory(entity.path, newPath);
      }
    }
  }

  try {
    copyDirectory(corePath, destinationPath);
    log('Core folders copied successfully from: $corePath');
    log('To: $destinationPath');

    final featuresPath = "$projectPath/features";
    final featuresDir = Directory(featuresPath);
    if (!featuresDir.existsSync()) {
      featuresDir.createSync(recursive: true);
      log('Created empty features directory: $featuresPath ✓');
    } else {
      log('Features directory already exists: $featuresPath');
    }

    // Copy files from main folder to lib folder
    final mainFolderPath = "$mainCorePath/main";
    final libPath = "${Directory.current.path}/lib";

    log('Copying files from main folder...');
    log('Source: $mainFolderPath');
    log('Destination: $libPath');

    copyDirectory(mainFolderPath, libPath);
    log('Main folder files copied successfully ✓');

    // Copy files from yaml_files folder to project root
    final yamlFilesPath = "$mainCorePath/yaml_files";
    final projectRoot = Directory.current.path;

    log('Copying files from yaml_files folder...');
    log('Source: $yamlFilesPath');
    log('Destination: $projectRoot');

    copyDirectory(yamlFilesPath, projectRoot);
    log('YAML files copied successfully ✓');

    // Remove the default counter test that references the deleted MyApp
    final defaultTest = File('$projectRoot/test/widget_test.dart');
    if (defaultTest.existsSync()) {
      defaultTest.deleteSync();
      log('Removed default test/widget_test.dart ✓');
    }

    log('\n=== Adding Dependencies ===');
    await runFlutter(['pub', 'add', ...coreDependencies]);
    for (final sdkDep in sdkDependencies) {
      await runFlutter(['pub', 'add', sdkDep, '--sdk=flutter']);
    }
    await runFlutter([
      'pub',
      'add',
      ...devDependencies.map((d) => 'dev:$d'),
    ]);

    for (final feature in enabledFeatures) {
      log('\n=== Enabling optional feature: $feature ===');
      await runFlutter(['pub', 'add', ...optionalPackages[feature]!]);
      enableOptionalCode(Directory(destinationPath), feature);
    }

    // Regenerate injectable / auto_route / freezed outputs for this project
    log('\n=== Running build_runner ===');
    await runCommand('dart', [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);

    log('\n=== All operations completed successfully! ===');
  } catch (e) {
    log('Error copying folders: $e ✗');
  }
}
// Run with: dart run <path>/init_project_folders.dart [location] [video] [hijri] [firebase_extras] [extras]