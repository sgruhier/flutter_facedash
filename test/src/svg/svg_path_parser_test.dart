import 'dart:ui';

import 'package:facehash/src/faces/face_paths.dart';
import 'package:facehash/src/faces/face_type.dart';
import 'package:facehash/src/svg/svg_path_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseSvgPath', () {
    group('basic commands', () {
      test('parses a simple M L Z path', () {
        final path = parseSvgPath('M0 0 L10 10 Z');

        expect(path, isA<Path>());
        // The path should contain the triangle-like shape.
        final bounds = path.getBounds();
        expect(bounds.left, equals(0));
        expect(bounds.top, equals(0));
        expect(bounds.right, equals(10));
        expect(bounds.bottom, equals(10));
      });

      test('parses moveTo and lineTo with decimal coordinates', () {
        final path = parseSvgPath('M1.5 2.5 L3.5 4.5 Z');

        final bounds = path.getBounds();
        expect(bounds.left, closeTo(1.5, 0.01));
        expect(bounds.top, closeTo(2.5, 0.01));
        expect(bounds.right, closeTo(3.5, 0.01));
        expect(bounds.bottom, closeTo(4.5, 0.01));
      });
    });

    group('cubic bezier (C command)', () {
      test('parses a cubic bezier path', () {
        final path = parseSvgPath('M0 0 C1 2 3 4 5 6 Z');

        expect(path, isA<Path>());
        final bounds = path.getBounds();
        // The endpoint of the cubic bezier is (5, 6).
        expect(bounds.right, closeTo(5, 1));
        expect(bounds.bottom, closeTo(6, 1));
      });

      test('parses multiple cubic bezier segments', () {
        final path = parseSvgPath('M0 0 C1 2 3 4 5 6 C7 8 9 10 11 12 Z');

        final bounds = path.getBounds();
        // Final endpoint is (11, 12).
        expect(bounds.right, closeTo(11, 1));
        expect(bounds.bottom, closeTo(12, 1));
      });
    });

    group('H and V commands', () {
      test('parses horizontal line (H)', () {
        final path = parseSvgPath('M0 5 H10 Z');

        final bounds = path.getBounds();
        expect(bounds.left, equals(0));
        expect(bounds.right, equals(10));
        // Y should remain at 5 (horizontal line does not change Y).
        expect(bounds.top, equals(5));
        expect(bounds.bottom, equals(5));
      });

      test('parses vertical line (V)', () {
        final path = parseSvgPath('M5 0 V10 Z');

        final bounds = path.getBounds();
        expect(bounds.top, equals(0));
        expect(bounds.bottom, equals(10));
        // X should remain at 5 (vertical line does not change X).
        expect(bounds.left, equals(5));
        expect(bounds.right, equals(5));
      });

      test('parses combined H and V commands', () {
        final path = parseSvgPath('M0 0 H10 V10 H0 V0 Z');

        final bounds = path.getBounds();
        expect(bounds.left, equals(0));
        expect(bounds.top, equals(0));
        expect(bounds.right, equals(10));
        expect(bounds.bottom, equals(10));
      });
    });

    group('negative numbers and scientific notation', () {
      test('parses negative coordinates', () {
        final path = parseSvgPath('M-5 -10 L5 10 Z');

        final bounds = path.getBounds();
        expect(bounds.left, equals(-5));
        expect(bounds.top, equals(-10));
        expect(bounds.right, equals(5));
        expect(bounds.bottom, equals(10));
      });

      test('parses scientific notation (e.g., -5.88036e-08)', () {
        // This appears in the actual cross face path data.
        final path = parseSvgPath('M0 0 L-5.88036e-08 10 Z');

        final bounds = path.getBounds();
        // -5.88036e-08 is effectively 0
        expect(bounds.left, closeTo(0, 0.001));
        expect(bounds.bottom, equals(10));
      });

      test('parses adjacent negative numbers without separator', () {
        // "3.5-2.1" should tokenize as "3.5" and "-2.1"
        final path = parseSvgPath('M0 0 L3.5-2.1 Z');

        final bounds = path.getBounds();
        expect(bounds.right, closeTo(3.5, 0.01));
        expect(bounds.top, closeTo(-2.1, 0.01));
      });
    });

    group('real face paths', () {
      test('parses round face left eye path', () {
        final data = facePathDataFor(FaceType.round);
        final path = parseSvgPath(data.leftEyePaths.first);

        expect(path, isA<Path>());
        final bounds = path.getBounds();
        // Round face left eye is a circle with radius ~7.2 centered around
        // (7.2, 7.2).
        expect(bounds.width, greaterThan(0));
        expect(bounds.height, greaterThan(0));
      });

      test('parses round face right eye path', () {
        final data = facePathDataFor(FaceType.round);
        final path = parseSvgPath(data.rightEyePaths.first);

        final bounds = path.getBounds();
        expect(bounds.width, greaterThan(0));
        expect(bounds.height, greaterThan(0));
      });

      test('all face path strings parse without throwing', () {
        for (final faceType in FaceType.values) {
          final data = facePathDataFor(faceType);

          for (final pathStr in data.leftEyePaths) {
            expect(
              () => parseSvgPath(pathStr),
              returnsNormally,
              reason:
                  'Left eye path for ${faceType.name} should parse without '
                  'error',
            );
          }

          for (final pathStr in data.rightEyePaths) {
            expect(
              () => parseSvgPath(pathStr),
              returnsNormally,
              reason:
                  'Right eye path for ${faceType.name} should parse without '
                  'error',
            );
          }
        }
      });

      test('all face paths produce non-empty paths', () {
        for (final faceType in FaceType.values) {
          final data = facePathDataFor(faceType);
          final allPaths = [...data.leftEyePaths, ...data.rightEyePaths];

          for (final pathStr in allPaths) {
            final path = parseSvgPath(pathStr);
            final bounds = path.getBounds();

            expect(
              bounds.width,
              greaterThan(0),
              reason: 'Path for ${faceType.name} should have non-zero width',
            );
            expect(
              bounds.height,
              greaterThan(0),
              reason: 'Path for ${faceType.name} should have non-zero height',
            );
          }
        }
      });

      test('cross face path with scientific notation parses correctly', () {
        // The cross face left eye path contains "-5.88036e-08"
        final data = facePathDataFor(FaceType.cross);
        final path = parseSvgPath(data.leftEyePaths.first);

        final bounds = path.getBounds();
        expect(bounds.width, greaterThan(0));
        expect(bounds.height, greaterThan(0));
      });
    });

    group('edge cases', () {
      test('empty path string returns empty path', () {
        final path = parseSvgPath('');
        final bounds = path.getBounds();

        expect(bounds.width, equals(0));
        expect(bounds.height, equals(0));
      });

      test('comma-separated coordinates', () {
        final path = parseSvgPath('M0,0 L10,10 Z');

        final bounds = path.getBounds();
        expect(bounds.right, equals(10));
        expect(bounds.bottom, equals(10));
      });

      test('tab and newline separated coordinates', () {
        final path = parseSvgPath('M0\t0\nL10\t10\nZ');

        final bounds = path.getBounds();
        expect(bounds.right, equals(10));
        expect(bounds.bottom, equals(10));
      });
    });
  });
}
