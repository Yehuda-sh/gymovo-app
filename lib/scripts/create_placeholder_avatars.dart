// lib/scripts/create_placeholder_avatars.dart
import 'dart:io';
import 'package:logging/logging.dart';

Future<void> main() async {
  // לוג בסיסי – עוזר בזיהוי בעיות
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
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

    // הגדרת כמויות לכל מגדר
    final genders = {
      'male': 5,
      'female': 5,
      'other': 2,
    };

    for (final entry in genders.entries) {
      final gender = entry.key;
      final count = entry.value;
      for (int i = 1; i <= count; i++) {
        final path = '$basePath/${gender}_$i.png';
        final file = File(path);
        if (!await file.exists()) {
          await _createAvatarPlaceholder(file, gender: gender, number: i);
          log.info('Created: $path');
        } else {
          log.fine('Exists:  $path');
        }
      }
    }

    // אווטאר ברירת מחדל
    final defaultAvatar = File('$basePath/default_avatar.png');
    if (!await defaultAvatar.exists()) {
      await _createAvatarPlaceholder(defaultAvatar, gender: 'neutral');
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

/// יוצר קובץ PNG (או SVG) פשוט עם טקסט מזהה, במקום קובץ ריק
Future<void> _createAvatarPlaceholder(File file,
    {String gender = '', int? number}) async {
  // שים לב: כדי לייצר PNG אמיתי דרוש ספריית image. כרגע – יוצרים SVG טקסטואלי, קל ונגיש!
  final label =
      gender.isEmpty ? 'Avatar' : '$gender${number != null ? ' $number' : ''}';
  final svg = '''
<svg width="256" height="256" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="#eee"/>
  <text x="50%" y="50%" text-anchor="middle" alignment-baseline="middle" font-size="28" font-family="Arial" fill="#666">
    $label
  </text>
</svg>
''';
  final svgPath = file.path.replaceAll('.png', '.svg');
  await File(svgPath).writeAsString(svg);
}
