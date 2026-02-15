import 'dart:async';
import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:facehash/src/core/colors.dart';
import 'package:facehash/src/core/facehash_data.dart';
import 'package:facehash/src/faces/face_painter.dart';
import 'package:facehash/src/faces/face_paths.dart';
import 'package:facehash/src/widgets/blink_controller.dart';
import 'package:facehash/src/widgets/facehash_intensity.dart';
import 'package:facehash/src/widgets/facehash_shape.dart';
import 'package:facehash/src/widgets/facehash_variant.dart';
import 'package:facehash/src/widgets/gradient_overlay.dart';
import 'package:flutter/widgets.dart';

/// A deterministic avatar widget that generates a unique face from a string.
///
/// Given a [name], Facehash produces a consistent, visually distinct avatar
/// with eyes, a background color, an optional initial letter, and a 3D
/// perspective tilt -- all derived from the hash of the input string.
///
/// {@tool snippet}
/// Minimal usage with just a name:
///
/// ```dart
/// const Facehash(name: 'Alice')
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// Full customization with all options:
///
/// ```dart
/// Facehash(
///   name: 'Bob',
///   size: 64,
///   variant: FacehashVariant.solid,
///   shape: FacehashShape.squircle,
///   intensity3d: Intensity3D.subtle,
///   enableBlink: true,
/// )
/// ```
/// {@end-tool}
class Facehash extends StatefulWidget {
  /// Creates a [Facehash] widget.
  ///
  /// The [name] parameter is required and used to deterministically generate
  /// the face, color, rotation, and initial letter.
  const Facehash({
    required this.name,
    this.size = 40.0,
    this.variant = FacehashVariant.gradient,
    this.intensity3d = Intensity3D.dramatic,
    this.interactive = true,
    this.showInitial = true,
    this.enableBlink = false,
    this.colors,
    this.shape = FacehashShape.circle,
    this.eyeColor,
    this.initialStyle,
    this.mouthBuilder,
    this.onTap,
    super.key,
  });

  /// The string to hash. Determines the face type, color, rotation, and
  /// initial letter.
  final String name;

  /// The size of the avatar in logical pixels.
  ///
  /// Defaults to `40.0`.
  final double size;

  /// The background style variant.
  ///
  /// [FacehashVariant.gradient] adds a radial white glow over the
  /// background color. [FacehashVariant.solid] uses a plain fill.
  ///
  /// Defaults to [FacehashVariant.gradient].
  final FacehashVariant variant;

  /// Controls the strength of the 3D perspective tilt effect.
  ///
  /// Defaults to [Intensity3D.dramatic].
  final Intensity3D intensity3d;

  /// Whether the avatar responds to hover (desktop) and tap (mobile)
  /// interactions by flattening the 3D rotation.
  ///
  /// Defaults to `true`.
  final bool interactive;

  /// Whether to display the first letter of [name] below the eyes.
  ///
  /// Ignored when [mouthBuilder] is non-null.
  ///
  /// Defaults to `true`.
  final bool showInitial;

  /// Whether to enable the eye blink animation.
  ///
  /// Blink timing is deterministically derived from the hash so each
  /// avatar blinks at a unique rate and delay.
  ///
  /// Defaults to `false`.
  final bool enableBlink;

  /// Custom color palette for background selection.
  ///
  /// When `null`, [defaultColors] is used.
  final List<Color>? colors;

  /// The shape of the avatar container.
  ///
  /// Defaults to [FacehashShape.circle].
  final FacehashShape shape;

  /// Color of the eye shapes.
  ///
  /// Defaults to white (`Color(0xFFFFFFFF)`).
  final Color? eyeColor;

  /// Text style for the initial letter.
  ///
  /// When `null`, a default bold style sized proportionally to [size] is
  /// used, colored to match [eyeColor].
  final TextStyle? initialStyle;

  /// Builder for a custom mouth widget, replacing the initial letter.
  ///
  /// Receives the computed [FacehashData] for full access to the hash,
  /// face type, and color index.
  final Widget Function(FacehashData data)? mouthBuilder;

  /// Callback invoked when the avatar is tapped.
  final VoidCallback? onTap;

  @override
  State<Facehash> createState() => _FacehashState();
}

class _FacehashState extends State<Facehash> with TickerProviderStateMixin {
  /// The computed face data derived from the current [widget.name].
  late FacehashData _data;

  /// The resolved color palette (custom or default).
  late List<Color> _effectiveColors;

  // -- Interaction animation (3D rotation) -----------------------------------

  /// Controls the 0-to-1 progress of the hover/tap interaction.
  late final AnimationController _interactionController;

  /// Curved animation for smooth easing on hover enter/exit.
  late final CurvedAnimation _interactionCurve;

  // -- Blink animation -------------------------------------------------------

  /// Controls the repeating blink cycle. Created only when
  /// [widget.enableBlink] is `true`.
  AnimationController? _blinkController;

  /// The animated scaleY value for the blink effect.
  Animation<double>? _blinkAnimation;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _effectiveColors = widget.colors ?? defaultColors;
    _data = _computeData();

    // Interaction animation (hover/tap flattening).
    _interactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _interactionCurve = CurvedAnimation(
      parent: _interactionController,
      curve: Curves.easeOutCubic,
    );

    // Blink animation (optional).
    if (widget.enableBlink) {
      _initBlinkController();
    }
  }

  @override
  void didUpdateWidget(covariant Facehash oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recompute data when inputs change.
    if (oldWidget.name != widget.name || oldWidget.colors != widget.colors) {
      _effectiveColors = widget.colors ?? defaultColors;
      _data = _computeData();

      // Re-initialise blink controller with new timing if still enabled.
      if (widget.enableBlink) {
        _disposeBlinkController();
        _initBlinkController();
      }
    }

    // Handle blink toggle.
    if (oldWidget.enableBlink != widget.enableBlink) {
      if (widget.enableBlink) {
        _initBlinkController();
      } else {
        _disposeBlinkController();
      }
    }
  }

  @override
  void dispose() {
    _interactionCurve.dispose();
    _interactionController.dispose();
    _disposeBlinkController();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  FacehashData _computeData() => computeFacehash(
    name: widget.name,
    colorsLength: _effectiveColors.length,
  );

  void _initBlinkController() {
    final timing = blinkTimingFromHash(_data.hash);
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (timing.duration * 1000).round()),
    );

    _blinkAnimation = blinkTweenSequence.animate(controller);
    _blinkController = controller;

    // Delay the start so each avatar blinks at a unique offset.
    unawaited(
      Future<void>.delayed(
        Duration(milliseconds: (timing.delay * 1000).round()),
        () {
          if (mounted && _blinkController == controller) {
            unawaited(controller.repeat());
          }
        },
      ),
    );
  }

  void _disposeBlinkController() {
    _blinkController?.dispose();
    _blinkController = null;
    _blinkAnimation = null;
  }

  // -- Interaction callbacks --------------------------------------------------

  void _onInteractionStart() {
    if (!widget.interactive) return;
    unawaited(_interactionController.forward());
  }

  void _onInteractionEnd() {
    if (!widget.interactive) return;
    unawaited(_interactionController.reverse());
  }

  // -- 3D transform -----------------------------------------------------------

  /// Builds the perspective [Matrix4] for the current animation frame.
  ///
  /// The [animationValue] ranges from 0.0 (hash-based rotation) to
  /// 1.0 (flat / no rotation), controlled by the interaction animation.
  /// Computes the face feature offset for the 3D tilt effect.
  ///
  /// Instead of relying on Matrix4 3D perspective (which renders
  /// differently on Flutter web vs CSS), we compute the visual offset
  /// that CSS perspective produces and apply it as a 2D translation
  /// combined with a subtle rotation.
  ///
  /// The [animationValue] ranges from 0.0 (hash-based tilt) to
  /// 1.0 (flat / centered), controlled by the interaction animation.
  Offset _computeOffset(double animationValue) {
    final preset = IntensityPreset.presets[widget.intensity3d]!;
    if (preset.rotateRange == 0) return Offset.zero;

    // Offset matches CSS perspective projection direction:
    // rotateY maps to horizontal shift, rotateX to vertical shift.
    final maxOffset = widget.size * preset.offsetFraction;
    final dx = lerpDouble(
      _data.rotation.dy * maxOffset,
      0,
      animationValue,
    )!;
    final dy = lerpDouble(
      -_data.rotation.dx * maxOffset,
      0,
      animationValue,
    )!;

    return Offset(dx, dy);
  }

  /// Builds a subtle rotation matrix for the 3D tilt effect.
  Matrix4 _buildTransform(double animationValue) {
    final preset = IntensityPreset.presets[widget.intensity3d]!;
    if (preset.rotateRange == 0) return Matrix4.identity();

    final rotateXDeg =
        lerpDouble(_data.rotation.dx * preset.rotateRange, 0, animationValue)!;
    final rotateYDeg =
        lerpDouble(_data.rotation.dy * preset.rotateRange, 0, animationValue)!;

    return Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(rotateXDeg * pi / 180)
      ..rotateY(rotateYDeg * pi / 180);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final backgroundColor = getColor(_effectiveColors, _data.colorIndex);
    final resolvedEyeColor = widget.eyeColor ?? const Color(0xFF000000);

    // Face paint dimensions. Width is 60 % of the avatar; height preserves
    // the SVG viewBox aspect ratio.
    final pathData = facePathDataFor(_data.faceType);
    final faceWidth = widget.size * 0.6;
    final faceHeight =
        faceWidth * (pathData.viewBoxHeight / pathData.viewBoxWidth);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _onInteractionStart(),
      onTapUp: (_) => _onInteractionEnd(),
      onTapCancel: _onInteractionEnd,
      child: MouseRegion(
        onEnter: (_) => _onInteractionStart(),
        onExit: (_) => _onInteractionEnd(),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: _buildClippedContent(
            backgroundColor: backgroundColor,
            resolvedEyeColor: resolvedEyeColor,
            faceWidth: faceWidth,
            faceHeight: faceHeight,
          ),
        ),
      ),
    );
  }

  /// Wraps the content with the appropriate shape clip based on
  /// [Facehash.shape].
  Widget _buildClippedContent({
    required Color backgroundColor,
    required Color resolvedEyeColor,
    required double faceWidth,
    required double faceHeight,
  }) {
    final content = _buildContent(
      backgroundColor: backgroundColor,
      resolvedEyeColor: resolvedEyeColor,
      faceWidth: faceWidth,
      faceHeight: faceHeight,
    );

    final clipper = clipperForShape(widget.shape);
    if (clipper == null) {
      // Square -- no clipping needed.
      return content;
    }

    return ClipPath(clipper: clipper, child: content);
  }

  /// Builds the colored background, optional gradient overlay, face eyes,
  /// and initial letter / mouth area.
  Widget _buildContent({
    required Color backgroundColor,
    required Color resolvedEyeColor,
    required double faceWidth,
    required double faceHeight,
  }) {
    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        children: [
          // Gradient overlay.
          if (widget.variant == FacehashVariant.gradient)
            const Positioned.fill(
              child: CustomPaint(
                painter: GradientOverlayPainter(),
              ),
            ),

          // Face with 3D transform (full-size like React's inset:0 div).
          Positioned.fill(
            child: _buildAnimatedFace(
              resolvedEyeColor: resolvedEyeColor,
              faceWidth: faceWidth,
              faceHeight: faceHeight,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the face column wrapped in an animated 3D perspective transform.
  ///
  /// Listens to both the interaction animation and the blink animation
  /// (if active) to rebuild when either ticks.
  Widget _buildAnimatedFace({
    required Color resolvedEyeColor,
    required double faceWidth,
    required double faceHeight,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _interactionCurve,
        ?_blinkController,
      ]),
      builder: (context, child) {
        final animValue = _interactionCurve.value;
        final offset = _computeOffset(animValue);
        final matrix = _buildTransform(animValue);
        final blinkProgress = _blinkAnimation?.value ?? 1.0;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.translationValues(offset.dx, offset.dy, 0)
            ..multiply(matrix),
          child: Center(
            child: _buildFaceColumn(
              resolvedEyeColor: resolvedEyeColor,
              faceWidth: faceWidth,
              faceHeight: faceHeight,
              blinkProgress: blinkProgress,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaceColumn({
    required Color resolvedEyeColor,
    required double faceWidth,
    required double faceHeight,
    required double blinkProgress,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Eyes.
        CustomPaint(
          size: Size(faceWidth, faceHeight),
          painter: FacePainter(
            faceType: _data.faceType,
            eyeColor: resolvedEyeColor,
            blinkProgress: blinkProgress,
          ),
        ),

        // Mouth area: custom builder takes priority over initial letter.
        if (widget.mouthBuilder != null)
          widget.mouthBuilder!(_data)
        else if (widget.showInitial)
          _buildInitial(resolvedEyeColor),
      ],
    );
  }

  /// Builds the initial letter text widget.
  Widget _buildInitial(Color resolvedEyeColor) {
    final defaultStyle = TextStyle(
      fontSize: widget.size * 0.26,
      fontWeight: FontWeight.bold,
      color: resolvedEyeColor,
    );

    return Text(
      _data.initial,
      style: widget.initialStyle ?? defaultStyle,
    );
  }
}
