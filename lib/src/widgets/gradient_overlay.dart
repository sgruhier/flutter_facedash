import 'package:flutter/rendering.dart';

/// Paints a radial gradient overlay matching the React FaceHash style.
///
/// Creates a white center glow: `rgba(255,255,255,0.15)` at center
/// fading to transparent at 60%.
class GradientOverlayPainter extends CustomPainter {
  /// Creates a [GradientOverlayPainter].
  const GradientOverlayPainter();

  static const _gradient = RadialGradient(
    colors: [
      Color(0x26FFFFFF), // white at 15% opacity
      Color(0x00FFFFFF), // transparent
    ],
    stops: [0.0, 1.0],
    radius: 0.6,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..shader = _gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
