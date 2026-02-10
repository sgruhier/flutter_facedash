/// The four face types available in FaceHash.
///
/// Each face type represents a different eye style. The face type
/// is deterministically selected from the hash of the input string.
enum FaceType {
  /// Two circles - simple round eyes.
  round,

  /// Two plus/cross shapes.
  cross,

  /// Horizontal line eyes (two rounded rectangles per eye).
  line,

  /// Curved eyelid shapes - sleepy/happy eyes.
  curved,
}
