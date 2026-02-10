import 'dart:typed_data';

import 'package:facehash/src/faces/face_paths.dart';
import 'package:facehash/src/faces/face_type.dart';
import 'package:facehash/src/svg/svg_path_parser.dart';
import 'package:flutter/rendering.dart';

/// Paints face eyes for a given [FaceType] using SVG path data.
///
/// The painter scales the SVG paths from their viewBox coordinate system
/// to the actual widget size, and supports a [blinkProgress] value
/// that controls the vertical scale of the eyes (for blink animation).
class FacePainter extends CustomPainter {
  /// Creates a [FacePainter].
  FacePainter({
    required this.faceType,
    required this.eyeColor,
    this.blinkProgress = 1.0,
  });

  /// The face type to render.
  final FaceType faceType;

  /// Color of the eyes.
  final Color eyeColor;

  /// Blink progress from 0.0 (fully closed) to 1.0 (fully open).
  final double blinkProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final data = facePathDataFor(faceType);
    final scaleX = size.width / data.viewBoxWidth;
    final scaleY = size.height / data.viewBoxHeight;

    final paint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final scaleMatrix = Float64List.fromList(
      Matrix4.diagonal3Values(scaleX, scaleY, 1).storage,
    );

    // Apply blink transform (scaleY around vertical center)
    if (blinkProgress < 1.0) {
      final centerY = size.height / 2;
      canvas
        ..save()
        ..translate(0, centerY)
        ..scale(1, blinkProgress.clamp(0.05, 1.0))
        ..translate(0, -centerY);
    }

    // Draw all eye paths
    final allPaths = [...data.leftEyePaths, ...data.rightEyePaths];
    for (final pathStr in allPaths) {
      final path = parseSvgPath(pathStr);
      final scaledPath = path.transform(scaleMatrix);
      canvas.drawPath(scaledPath, paint);
    }

    if (blinkProgress < 1.0) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) =>
      faceType != oldDelegate.faceType ||
      eyeColor != oldDelegate.eyeColor ||
      blinkProgress != oldDelegate.blinkProgress;
}
