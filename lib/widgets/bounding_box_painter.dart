import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> boxes;
  final double imageWidth;
  final double imageHeight;

  BoundingBoxPainter({
    required this.boxes,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;

    for (final box in boxes) {
      final bbox = List<double>.from(box["bbox"]);
      final cX = bbox[0];
      final cY = bbox[1];
      final w = bbox[2];
      final h = bbox[3];

      final left = (cX - w / 2) * scaleX;
      final top = (cY - h / 2) * scaleY;

      final rect = Rect.fromLTWH(left, top, w * scaleX, h * scaleY);

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
