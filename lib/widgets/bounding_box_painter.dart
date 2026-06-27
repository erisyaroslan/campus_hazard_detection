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
    final boxPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final labelPaint = Paint()..color = Colors.red;

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

      // Draw bounding box
      canvas.drawRect(rect, boxPaint);

      final label =
          "${box["class"]} ${(box["confidence"] * 100).toStringAsFixed(0)}%";

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      double labelTop = rect.top - textPainter.height - 6;

      // Prevent label from going above the image
      if (labelTop < 0) {
        labelTop = rect.top;
      }

      final labelRect = Rect.fromLTWH(
        rect.left,
        labelTop,
        textPainter.width + 8,
        textPainter.height + 6,
      );

      // Draw label background
      canvas.drawRect(labelRect, labelPaint);

      // Draw label text
      textPainter.paint(canvas, Offset(rect.left + 4, labelTop + 3));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
