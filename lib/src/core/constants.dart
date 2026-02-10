import 'package:flutter/painting.dart';

/// 9 possible rotation positions for the 3D effect.
///
/// Each position is an (x, y) pair where each axis is -1, 0, or 1.
/// Selected deterministically via `hash % 9`.
const List<Offset> spherePositions = [
  Offset(-1, 1), // down-right
  Offset(1, 1), // up-right
  Offset(1, 0), // up
  Offset(0, 1), // right
  Offset(-1, 0), // down
  Offset.zero, // center
  Offset(0, -1), // left
  Offset(-1, -1), // down-left
  Offset(1, -1), // up-left
];
