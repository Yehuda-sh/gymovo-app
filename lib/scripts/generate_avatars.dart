import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Create avatars directory if it doesn't exist
  final appDir = await getApplicationDocumentsDirectory();
  final avatarsDir = Directory('${appDir.path}/../assets/avatars');
  if (!await avatarsDir.exists()) {
    await avatarsDir.create(recursive: true);
  }

  // Generate male avatars
  for (int i = 1; i <= 5; i++) {
    await _generateAvatar(
      'male_$i.png',
      Colors.blue[700]!,
      Icons.person,
    );
  }

  // Generate female avatars
  for (int i = 1; i <= 5; i++) {
    await _generateAvatar(
      'female_$i.png',
      Colors.pink[700]!,
      Icons.person,
    );
  }

  print('Avatar images generated successfully!');
}

Future<void> _generateAvatar(
  String filename,
  Color color,
  IconData icon,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(200, 200);
  final paint = Paint()..color = color;

  // Draw circle background
  canvas.drawCircle(
    Offset(size.width / 2, size.height / 2),
    size.width / 2,
    paint,
  );

  // Draw icon
  final iconPaint = Paint()..color = Colors.white;
  final iconSize = size.width * 0.6;
  final iconStyle = TextStyle(
    color: Colors.white,
    fontSize: iconSize,
  );
  final iconSpan = TextSpan(
    text: String.fromCharCode(icon.codePoint),
    style: iconStyle,
  );
  final iconPainter = TextPainter(
    text: iconSpan,
    textDirection: TextDirection.ltr,
  );
  iconPainter.layout();
  iconPainter.paint(
    canvas,
    Offset(
      (size.width - iconPainter.width) / 2,
      (size.height - iconPainter.height) / 2,
    ),
  );

  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(
    size.width.toInt(),
    size.height.toInt(),
  );
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // Save to file
  final file = File(
      '${(await getApplicationDocumentsDirectory()).path}/../assets/avatars/$filename');
  await file.writeAsBytes(buffer);
}
