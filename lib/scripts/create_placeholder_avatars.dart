import 'dart:io';
import 'package:logging/logging.dart';

Future<void> main() async {
  // קונפיגורציה בסיסית ללוגר
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // עיצוב קל לקריאות
    stdout.writeln('[${record.level.name}] ${record.time}: ${record.message}');
  });
  final log = Logger('AvatarGenerator');

  const basePath = 'assets/avatars';
  final avatarsDir = Directory(basePath);

  try {
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
      log.info('Created directory: $basePath');
    }

    final genders = {'male': 5, 'female': 5, 'other': 2};

    for (final entry in genders.entries) {
      final gender = entry.key;
      final count = entry.value;
      for (int i = 1; i <= count; i++) {
        final path = '$basePath/${gender}_$i.png';
        final file = File(path);
        if (!await file.exists()) {
          await file.create();
          log.info('Created: $path');
        } else {
          log.fine('Exists:  $path');
        }
      }
    }

    // default avatar
    final defaultAvatar = File('$basePath/default_avatar.png');
    if (!await defaultAvatar.exists()) {
      await defaultAvatar.create();
      log.info('Created: ${defaultAvatar.path}');
    }

    log.info('All avatar placeholders created successfully!');
  } on FileSystemException catch (e) {
    log.severe('File system error: ${e.message}');
    exit(1);
  } catch (e) {
    log.shout('Unknown error: $e');
    exit(1);
  }
}
