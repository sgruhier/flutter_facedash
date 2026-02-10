/// Deterministic avatar faces from any string.
///
/// FaceHash generates unique, consistent avatar faces based on string hashing.
/// Same input always produces the same face, color, and rotation.
///
/// ```dart
/// import 'package:facehash/facehash.dart';
///
/// // Simple usage
/// const Facehash(name: 'alice')
///
/// // Full customization
/// Facehash(
///   name: 'bob@example.com',
///   size: 64,
///   shape: FacehashShape.squircle,
///   variant: FacehashVariant.solid,
///   enableBlink: true,
/// )
/// ```
library;

// Core
export 'src/core/colors.dart';
export 'src/core/facehash_data.dart';
export 'src/core/hash.dart';

// Faces
export 'src/faces/face_type.dart';

// Widgets
export 'src/widgets/facehash_intensity.dart' show Intensity3D;
export 'src/widgets/facehash_shape.dart' show FacehashShape;
export 'src/widgets/facehash_variant.dart';
export 'src/widgets/facehash_widget.dart';
