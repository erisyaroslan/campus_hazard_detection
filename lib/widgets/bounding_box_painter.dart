import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List boxes;

  final double imageWidth;
  final double imageHeight;

  BoundingBoxPainter({
    required this.boxes,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    double scaleX = size.width / imageWidth;
    double scaleY = size.height / imageHeight;

    for (var box in boxes) {
      final bbox = box["bbox"];

      double cx = bbox[0].toDouble();
      double cy = bbox[1].toDouble();
      double w = bbox[2].toDouble();
      double h = bbox[3].toDouble();

      double left = (cx - w / 2) * scaleX;
      double top = (cy - h / 2) * scaleY;
      double right = (cx + w / 2) * scaleX;
      double bottom = (cy + h / 2) * scaleY;

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );

      textPainter.text = TextSpan(
        text:
            "${box["class"]} ${(box["confidence"] * 100).toStringAsFixed(1)}%",
        style: const TextStyle(
          color: Colors.red,
          fontSize: 14,
          backgroundColor: Colors.white,
        ),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(left, top - 18),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}