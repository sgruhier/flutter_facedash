import 'dart:math';

import 'package:facehash/facehash.dart';
import 'package:facehash/src/widgets/facehash_intensity.dart';
import 'package:facehash/src/widgets/gradient_overlay.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a widget in the minimal tree required for rendering.
///
/// [Facehash] only uses basic Flutter widgets (no Material/Cupertino),
/// so [Directionality] is sufficient for [Text] to render.
Widget buildTestWidget(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  );
}

void main() {
  group('Facehash widget', () {
    group('rendering', () {
      testWidgets('renders without error with just a name', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const Facehash(name: 'alice')),
        );

        expect(find.byType(Facehash), findsOneWidget);
      });

      testWidgets('renders with all parameters specified', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(
              name: 'bob',
              size: 64,
              variant: FacehashVariant.solid,
              shape: FacehashShape.squircle,
              intensity3d: Intensity3D.subtle,
              interactive: false,
              showInitial: false,
              eyeColor: Color(0xFF000000),
            ),
          ),
        );

        expect(find.byType(Facehash), findsOneWidget);
      });
    });

    group('size', () {
      testWidgets('respects default size of 40', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const Facehash(name: 'alice')),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(Facehash),
            matching: find.byType(SizedBox),
          ),
        );

        expect(sizedBox.width, equals(40));
        expect(sizedBox.height, equals(40));
      });

      testWidgets('respects custom size parameter', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const Facehash(name: 'alice', size: 80)),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(Facehash),
            matching: find.byType(SizedBox),
          ),
        );

        expect(sizedBox.width, equals(80));
        expect(sizedBox.height, equals(80));
      });
    });

    group('initial letter', () {
      testWidgets('shows initial letter when showInitial is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice'),
          ),
        );

        // "alice" -> initial "A"
        expect(find.text('A'), findsOneWidget);
      });

      testWidgets('hides initial letter when showInitial is false', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice', showInitial: false),
          ),
        );

        expect(find.text('A'), findsNothing);
      });

      testWidgets('shows correct initial for different names', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const Facehash(name: 'bob')),
        );

        expect(find.text('B'), findsOneWidget);
      });

      testWidgets('shows no text for empty name', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const Facehash(name: '')),
        );

        // Empty name -> empty initial -> no visible text widget with content
        expect(find.text('A'), findsNothing);
      });
    });

    group('mouthBuilder', () {
      testWidgets('shows mouthBuilder content when provided', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            Facehash(
              name: 'alice',
              size: 120,
              mouthBuilder: (data) => const Text('custom-mouth'),
            ),
          ),
        );

        expect(find.text('custom-mouth'), findsOneWidget);
        // The initial should NOT appear when mouthBuilder is set.
        expect(find.text('A'), findsNothing);
      });

      testWidgets('mouthBuilder receives correct FacehashData', (tester) async {
        late FacehashData receivedData;

        await tester.pumpWidget(
          buildTestWidget(
            Facehash(
              name: 'alice',
              mouthBuilder: (data) {
                receivedData = data;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(receivedData.faceType, equals(FaceType.round));
        expect(receivedData.initial, equals('A'));
        expect(receivedData.hash, equals(92903040));
      });
    });

    group('variant', () {
      testWidgets(
        'contains GradientOverlayPainter when variant is gradient',
        (tester) async {
          await tester.pumpWidget(
            buildTestWidget(
              const Facehash(name: 'alice'),
            ),
          );

          // Find a CustomPaint that uses GradientOverlayPainter.
          final customPaints = find.byType(CustomPaint);
          var foundGradient = false;

          for (var i = 0; i < customPaints.evaluate().length; i++) {
            final widget = tester.widget<CustomPaint>(customPaints.at(i));
            if (widget.painter is GradientOverlayPainter) {
              foundGradient = true;
              break;
            }
          }

          expect(foundGradient, isTrue);
        },
      );

      testWidgets(
        'does NOT contain GradientOverlayPainter when variant is solid',
        (tester) async {
          await tester.pumpWidget(
            buildTestWidget(
              const Facehash(name: 'alice', variant: FacehashVariant.solid),
            ),
          );

          final customPaints = find.byType(CustomPaint);
          var foundGradient = false;

          for (var i = 0; i < customPaints.evaluate().length; i++) {
            final widget = tester.widget<CustomPaint>(customPaints.at(i));
            if (widget.painter is GradientOverlayPainter) {
              foundGradient = true;
              break;
            }
          }

          expect(foundGradient, isFalse);
        },
      );
    });

    group('shape', () {
      testWidgets('contains ClipPath for circle shape', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice'),
          ),
        );

        expect(
          find.descendant(
            of: find.byType(Facehash),
            matching: find.byType(ClipPath),
          ),
          findsOneWidget,
        );
      });

      testWidgets('contains ClipPath for squircle shape', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice', shape: FacehashShape.squircle),
          ),
        );

        expect(
          find.descendant(
            of: find.byType(Facehash),
            matching: find.byType(ClipPath),
          ),
          findsOneWidget,
        );
      });

      testWidgets('does NOT contain ClipPath for square shape', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice', shape: FacehashShape.square),
          ),
        );

        expect(
          find.descendant(
            of: find.byType(Facehash),
            matching: find.byType(ClipPath),
          ),
          findsNothing,
        );
      });
    });

    group('onTap', () {
      testWidgets('fires onTap callback when tapped', (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          buildTestWidget(
            Facehash(
              name: 'alice',
              onTap: () => tapped = true,
            ),
          ),
        );

        await tester.tap(find.byType(Facehash));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('does not crash when onTap is null', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const Facehash(name: 'alice')),
        );

        await tester.tap(find.byType(Facehash));
        await tester.pumpAndSettle();

        // No crash means success.
        expect(find.byType(Facehash), findsOneWidget);
      });
    });

    group('face types', () {
      // Each name deterministically produces a specific face type:
      //   "alice"  -> hash=92903040  -> 92903040 % 4 = 0 -> round
      //   "a"      -> hash=97        -> 97 % 4 = 1       -> cross
      //   "hello"  -> hash=99162322  -> 99162322 % 4 = 2  -> line
      //   "sybil"  -> hash=109907167 -> 109907167 % 4 = 3 -> curved

      testWidgets('renders round face type (name: "alice")', (tester) async {
        late FacehashData capturedData;

        await tester.pumpWidget(
          buildTestWidget(
            Facehash(
              name: 'alice',
              mouthBuilder: (data) {
                capturedData = data;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(capturedData.faceType, equals(FaceType.round));
      });

      testWidgets('renders cross face type (name: "a")', (tester) async {
        late FacehashData capturedData;

        await tester.pumpWidget(
          buildTestWidget(
            Facehash(
              name: 'a',
              mouthBuilder: (data) {
                capturedData = data;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(capturedData.faceType, equals(FaceType.cross));
      });

      testWidgets('renders line face type (name: "hello")', (tester) async {
        late FacehashData capturedData;

        await tester.pumpWidget(
          buildTestWidget(
            Facehash(
              name: 'hello',
              mouthBuilder: (data) {
                capturedData = data;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(capturedData.faceType, equals(FaceType.line));
      });

      testWidgets('renders curved face type (name: "sybil")', (tester) async {
        late FacehashData capturedData;

        await tester.pumpWidget(
          buildTestWidget(
            Facehash(
              name: 'sybil',
              mouthBuilder: (data) {
                capturedData = data;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(capturedData.faceType, equals(FaceType.curved));
      });
    });

    group('widget updates', () {
      testWidgets('updates face when name changes', (tester) async {
        late FacehashData capturedData;

        await tester.pumpWidget(
          buildTestWidget(
            Facehash(
              name: 'alice',
              mouthBuilder: (data) {
                capturedData = data;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(capturedData.faceType, equals(FaceType.round));

        await tester.pumpWidget(
          buildTestWidget(
            Facehash(
              name: 'a',
              mouthBuilder: (data) {
                capturedData = data;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(capturedData.faceType, equals(FaceType.cross));
      });

      testWidgets('updates initial when name changes', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const Facehash(name: 'alice')),
        );
        expect(find.text('A'), findsOneWidget);

        await tester.pumpWidget(
          buildTestWidget(const Facehash(name: 'bob')),
        );
        expect(find.text('B'), findsOneWidget);
        expect(find.text('A'), findsNothing);
      });
    });

    group('custom colors', () {
      testWidgets('accepts custom color palette', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(
              name: 'alice',
              colors: [
                Color(0xFFFF0000),
                Color(0xFF00FF00),
                Color(0xFF0000FF),
              ],
            ),
          ),
        );

        expect(find.byType(Facehash), findsOneWidget);
      });
    });

    group('blink animation', () {
      testWidgets('renders with blink enabled without error', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice', enableBlink: true),
          ),
        );

        expect(find.byType(Facehash), findsOneWidget);

        // Pump enough time to let the blink delay timer fire and the
        // animation start, preventing pending timer assertions.
        await tester.pump(const Duration(seconds: 10));
      });

      testWidgets('can toggle blink on and off', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice'),
          ),
        );

        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice', enableBlink: true),
          ),
        );

        // Pump enough time to let the blink delay timer fire.
        await tester.pump(const Duration(seconds: 10));

        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice'),
          ),
        );

        expect(find.byType(Facehash), findsOneWidget);
      });

      testWidgets('re-initialises blink when name changes with blink enabled', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice', enableBlink: true),
          ),
        );
        await tester.pump(const Duration(seconds: 5));

        // Change name while blink stays enabled
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'bob', enableBlink: true),
          ),
        );
        await tester.pump(const Duration(seconds: 5));

        expect(find.byType(Facehash), findsOneWidget);
      });

      testWidgets('renders during blink animation mid-progress', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice', enableBlink: true),
          ),
        );

        // Advance past the blink delay to start the animation
        await tester.pump(const Duration(seconds: 8));
        // Pump a small frame so blink progress is between 0 and 1
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(Facehash), findsOneWidget);
      });
    });

    group('mouse interaction', () {
      testWidgets('handles mouse enter and exit', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice'),
          ),
        );

        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        // Move into the widget
        await gesture.moveTo(tester.getCenter(find.byType(Facehash)));
        await tester.pumpAndSettle();

        // Move out
        await gesture.moveTo(Offset.zero);
        await tester.pumpAndSettle();

        expect(find.byType(Facehash), findsOneWidget);
      });
    });

    group('shape shouldReclip', () {
      testWidgets('circle clipper does not reclip on rebuild', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const Facehash(name: 'alice')),
        );

        // Pump again with same shape to trigger shouldReclip
        await tester.pumpWidget(
          buildTestWidget(const Facehash(name: 'alice')),
        );

        expect(
          find.descendant(
            of: find.byType(Facehash),
            matching: find.byType(ClipPath),
          ),
          findsOneWidget,
        );
      });

      testWidgets('squircle clipper does not reclip on rebuild', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice', shape: FacehashShape.squircle),
          ),
        );

        // Pump again with same shape to trigger shouldReclip
        await tester.pumpWidget(
          buildTestWidget(
            const Facehash(name: 'alice', shape: FacehashShape.squircle),
          ),
        );

        expect(
          find.descendant(
            of: find.byType(Facehash),
            matching: find.byType(ClipPath),
          ),
          findsOneWidget,
        );
      });
    });

    group('gradient shouldRepaint', () {
      testWidgets('GradientOverlayPainter does not repaint on rebuild', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(const Facehash(name: 'alice')),
        );

        // Pump again to trigger shouldRepaint check
        await tester.pumpWidget(
          buildTestWidget(const Facehash(name: 'alice')),
        );

        final customPaints = find.byType(CustomPaint);
        var foundGradient = false;

        for (var i = 0; i < customPaints.evaluate().length; i++) {
          final widget = tester.widget<CustomPaint>(customPaints.at(i));
          if (widget.painter is GradientOverlayPainter) {
            foundGradient = true;
            break;
          }
        }

        expect(foundGradient, isTrue);
      });
    });

    group('intensity', () {
      test('rotateRangeRad computes correctly', () {
        const preset = IntensityPreset(
          rotateRange: 180,
          offsetFraction: 0.08,
        );
        expect(preset.rotateRangeRad, closeTo(pi, 0.001));
      });

      test('all presets have entries', () {
        for (final level in Intensity3D.values) {
          expect(IntensityPreset.presets[level], isNotNull);
        }
      });
    });
  });
}
