// ignore_for_file: unused_local_variable

import 'dart:developer';
import 'dart:io';

Future<void> runVSCodeCommand(
  String command,
  List<String> packages,
) async {
  try {
    log('Running VS Code command: $command');
    log('Adding packages: ${packages.join(', ')}');

    // Create a temporary file with package names for the command
    final tempFile = File(
      '${Directory.current.path}/.temp_packages.txt',
    );
    await tempFile.writeAsString(packages.join(','));

    // Run VS Code command using code CLI
    final result = await Process.run('code', [
      '--command',
      command,
      '--args',
      packages.join(','),
    ], workingDirectory: Directory.current.path);

    if (result.exitCode == 0) {
      log('VS Code command executed successfully ✓');
    } else {
      log('VS Code command failed: ${result.stderr} ✗');
      // Fallback: Try using osascript for macOS
      await runVSCodeCommandMacOS(command, packages);
    }

    // Clean up temp file
    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }
  } catch (e) {
    log('Error running VS Code command: $e');
    // Fallback to macOS AppleScript approach
    await runVSCodeCommandMacOS(command, packages);
  }
}

Future<void> runVSCodeCommandMacOS(
  String command,
  List<String> packages,
) async {
  try {
    log('Trying macOS AppleScript approach...');

    // Use AppleScript to send commands to VS Code
    final script =
        '''
      tell application "Visual Studio Code"
        activate
        delay 1
      end tell
      
      tell application "System Events"
        keystroke "p" using {command down, shift down}
        delay 0.5
        keystroke "$command"
        delay 0.5
        key code 36
        delay 1
        keystroke "${packages.join(',')}"
        delay 0.5
        key code 36
      end tell
    ''';

    final result = await Process.run('osascript', ['-e', script]);

    if (result.exitCode == 0) {
      log('VS Code command executed via AppleScript ✓');
    } else {
      log('AppleScript execution failed: ${result.stderr} ✗');
      log(
        'Please manually run: $command with packages: ${packages.join(', ')}',
      );
    }
  } catch (e) {
    log('Error with AppleScript: $e');
    log('Please manually run VS Code command: $command');
    log('With packages: ${packages.join(', ')}');
  }
}

void main() async {
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

    // Add dependencies using VS Code Pubspec Assist
    log('\n=== Adding Dependencies via VS Code ===');

    final mainDependencies = [
      'bloc',
      'cached_network_image',
      'dartz',
      'dio',
      'equatable',
      'file_picker',
      'flutter_bloc',
      'flutter_launcher_icons',
      'flutter_local_notifications',
      'flutter_svg',
      'get_it',
      'go_router',
      'lottie',
      'permission_handler',
      'shared_preferences',
      'shimmer',
      'url_launcher',
      'uuid',
      'flutter_dotenv',
      'flutter_secure_storage',
      'flutter_native_splash',
      'flutter_screenutil',
      'image_picker',
      'image_cropper',
      'pretty_dio_logger',
      'flutter_cache_manager',
      'easy_localization',
      'pinput',
      'toastification',
      'chewie',
      'video_player',
      'injectable',
    ];

    final devDependencies = ['build_runner', 'injectable_generator'];

    final firebaseDependencies = [
      'firebase_analytics',
      'firebase_auth',
      'firebase_core',
      'firebase_crashlytics',
      'firebase_messaging',
      'firebase_storage',
    ];

    // Add main dependencies
    await runVSCodeCommand(
      'Pubspec Assist: Add/update dependencies',
      mainDependencies,
    );

    // Add dev dependencies
    await runVSCodeCommand(
      'Pubspec Assist: Add/update dev dependencies',
      devDependencies,
    );
    //!==========================REMOVE COMMENT TO ADD FIREBASE DEPENDENCIES==========================
    // log('Adding Firebase dependencies...');
    // await runVSCodeCommand(
    //   'Pubspec Assist: Add/update dependencies',
    //   firebaseDependencies,
    // );
    log('\n=== All operations completed successfully! ===');
  } catch (e) {
    log('Error copying folders: $e ✗');
  }
}
// Run with: dart run lib/init_project_folders.dart