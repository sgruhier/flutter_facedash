import 'dart:ui';

import 'package:facehash/src/core/colors.dart';
import 'package:facehash/src/core/constants.dart';
import 'package:facehash/src/core/hash.dart';
import 'package:facehash/src/faces/face_type.dart';

/// Immutable data holding the deterministic face properties
/// computed from a name string.
class FacehashData {
  /// Creates a [FacehashData] instance.
  const FacehashData({
    required this.faceType,
    required this.colorIndex,
    required this.rotation,
    required this.initial,
    required this.hash,
  });

  /// The face type to render.
  final FaceType faceType;

  /// Index into the colors array.
  final int colorIndex;

  /// Rotation position for 3D effect. Each axis is -1, 0, or 1.
  final Offset rotation;

  /// First letter of the name, uppercase.
  final String initial;

  /// The raw hash value (useful for blink timing derivation).
  final int hash;
}

/// Computes deterministic face properties from a [name] string.
///
/// The [colorsLength] parameter controls how many colors are available
/// for selection (defaults to the length of [defaultColors]).
///
/// This is a pure function with no side effects.
FacehashData computeFacehash({
  required String name,
  int colorsLength = 5,
}) {
  final hash = stringHash(name);
  final faceIndex = hash % FaceType.values.length;
  final colorIndex = hash % colorsLength;
  final positionIndex = hash % spherePositions.length;
  final position = spherePositions[positionIndex];

  return FacehashData(
    faceType: FaceType.values[faceIndex],
    colorIndex: colorIndex,
    rotation: position,
    initial: name.isEmpty ? '' : name[0].toUpperCase(),
    hash: hash,
  );
}

/// Gets a color from a palette by index, with fallback to [defaultColors].
Color getColor(List<Color>? colors, int index) {
  final palette =
      colors != null && colors.isNotEmpty ? colors : defaultColors;
  return palette[index % palette.length];
}
