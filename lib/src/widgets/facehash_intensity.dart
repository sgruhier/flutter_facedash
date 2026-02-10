import 'dart:math';

/// Controls the strength of the 3D perspective rotation effect.
enum Intensity3D {
  /// No 3D effect.
  none,

  /// Subtle tilt (5 deg rotate).
  subtle,

  /// Moderate tilt (10 deg rotate).
  medium,

  /// Strong tilt (15 deg rotate).
  dramatic,
}

/// Preset values for each [Intensity3D] level.
class IntensityPreset {
  /// Creates an [IntensityPreset].
  const IntensityPreset({
    required this.rotateRange,
    required this.perspective,
  });

  /// Maximum rotation angle in degrees.
  final double rotateRange;

  /// Perspective distance. 0 means no perspective.
  final double perspective;

  /// Maximum rotation angle in radians.
  double get rotateRangeRad => rotateRange * pi / 180;

  /// Lookup table for all intensity levels.
  static const Map<Intensity3D, IntensityPreset> presets = {
    Intensity3D.none: IntensityPreset(rotateRange: 0, perspective: 0),
    Intensity3D.subtle: IntensityPreset(rotateRange: 5, perspective: 800),
    Intensity3D.medium: IntensityPreset(rotateRange: 10, perspective: 500),
    Intensity3D.dramatic: IntensityPreset(rotateRange: 15, perspective: 300),
  };
}
