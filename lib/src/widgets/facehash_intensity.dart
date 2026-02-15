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
    required this.offsetFraction,
  });

  /// Maximum rotation angle in degrees.
  final double rotateRange;

  /// Face offset as a fraction of widget size (e.g. 0.06 = 6%).
  final double offsetFraction;

  /// Maximum rotation angle in radians.
  double get rotateRangeRad => rotateRange * pi / 180;

  /// Lookup table for all intensity levels.
  static const Map<Intensity3D, IntensityPreset> presets = {
    Intensity3D.none:
        IntensityPreset(rotateRange: 0, offsetFraction: 0),
    Intensity3D.subtle:
        IntensityPreset(rotateRange: 3, offsetFraction: 0.03),
    Intensity3D.medium:
        IntensityPreset(rotateRange: 5, offsetFraction: 0.05),
    Intensity3D.dramatic:
        IntensityPreset(rotateRange: 8, offsetFraction: 0.08),
  };
}
