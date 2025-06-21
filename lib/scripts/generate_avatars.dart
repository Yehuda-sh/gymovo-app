import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// הפעל ע"י `dart run lib/scripts/generate_avatars.dart`
/// חובה להריץ מתוך flutter project אמיתי (ולא רק Dart CLI)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // קבע את נתיב התיקייה
  final Directory appDir = await getApplicationDocumentsDirectory();
  final avatarsDir = Directory('${appDir.path}/../assets/avatars');
  if (!await avatarsDir.exists()) {
    await avatarsDir.create(recursive: true);
    print('יצרתי תיקייה: ${avatarsDir.path}');
  }

  // תצורה לכל מגדר
  final avatarConfigs = [
    {'gender': 'male', 'color': Colors.blue[700]!, 'count': 5},
    {'gender': 'female', 'color': Colors.pink[600]!, 'count': 5},
    {'gender': 'other', 'color': Colors.grey[700]!, 'count': 2},
    {'gender': 'neutral', 'color': Colors.teal[400]!, 'count': 1},
  ];

  for (final config in avatarConfigs) {
    final gender = config['gender'] as String;
    final color = config['color'] as Color;
    final count = config['count'] as int;

    for (int i = 1; i <= count; i++) {
      final isNeutral = gender == 'neutral';
      final filename = isNeutral ? 'default_avatar.png' : '${gender}_$i.png';

      await _generateAvatar(
        filePath: '${avatarsDir.path}/$filename',
        color: color,
        label: isNeutral ? '🙂' : gender[0].toUpperCase(),
      );
      print('Created: $filename');
    }
  }

  print('--- Avatar images generated successfully! ---');
}

/// פונקציה ליצירת PNG צבעוני עגול, עם אייקון/אות מגדרית במרכז
Future<void> _generateAvatar({
  required String filePath,
  required Color color,
  String label = 'U',
}) async {
  const double size = 200;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // רקע עגול
  final paint = Paint()..color = color;
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

  // טקסט מרכזי (אות מגדר או אייקון)
  final textStyle = TextStyle(
    color: Colors.white,
    fontSize: 80,
    fontWeight: FontWeight.bold,
    fontFamily: 'Arial',
    letterSpacing: 2,
  );
  final textSpan = TextSpan(text: label, style: textStyle);
  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
  );

  // המרה ל־PNG
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // כתיבה לקובץ
  await File(filePath).writeAsBytes(buffer);
}
