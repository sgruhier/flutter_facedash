import 'package:flutter/widgets.dart';

/// Shape of the FaceHash avatar container.
enum FacehashShape {
  /// Circular (default).
  circle,

  /// Square with no border radius.
  square,

  /// Superellipse / continuous corners (iOS-style squircle).
  squircle,
}

/// Returns a [CustomClipper] for the given [shape], or null for square.
CustomClipper<Path>? clipperForShape(FacehashShape shape) {
  switch (shape) {
    case FacehashShape.circle:
      return const _CircleClipper();
    case FacehashShape.square:
      return null;
    case FacehashShape.squircle:
      return const _SquircleClipper();
  }
}

class _CircleClipper extends CustomClipper<Path> {
  const _CircleClipper();

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SquircleClipper extends CustomClipper<Path> {
  const _SquircleClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    // Squircle radius factor (controls how rounded the corners are)
    final r = w * 0.22;

    return Path()
      ..moveTo(r, 0)
      ..lineTo(w - r, 0)
      ..cubicTo(w, 0, w, 0, w, r)
      ..lineTo(w, h - r)
      ..cubicTo(w, h, w, h, w - r, h)
      ..lineTo(r, h)
      ..cubicTo(0, h, 0, h, 0, h - r)
      ..lineTo(0, r)
      ..cubicTo(0, 0, 0, 0, r, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
