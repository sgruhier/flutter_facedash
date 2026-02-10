import 'dart:ui';

import 'package:facehash/src/core/colors.dart';
import 'package:facehash/src/core/facehash_data.dart';
import 'package:facehash/src/faces/face_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeFacehash', () {
    group('cross-platform parity vectors', () {
      // Parity vectors computed from the JS reference implementation.
      //
      // Derivation formulas (with default colorsLength=5):
      //   faceIndex = hash % 4  (round=0, cross=1, line=2, curved=3)
      //   colorIndex = hash % 5
      //   positionIndex = hash % 9  (into spherePositions)
      //
      // spherePositions (0-indexed):
      //   0: (-1, 1)   1: (1, 1)    2: (1, 0)
      //   3: (0, 1)    4: (-1, 0)   5: (0, 0)
      //   6: (0, -1)   7: (-1, -1)  8: (1, -1)

      test('"" -> round, color 0, pos (-1,1), initial ""', () {
        final data = computeFacehash(name: '');

        expect(data.hash, equals(0));
        expect(data.faceType, equals(FaceType.round));
        expect(data.colorIndex, equals(0));
        expect(data.rotation, equals(const Offset(-1, 1)));
        expect(data.initial, equals(''));
      });

      test('"a" -> cross, color 2, pos (-1,-1), initial "A"', () {
        final data = computeFacehash(name: 'a');

        expect(data.hash, equals(97));
        expect(data.faceType, equals(FaceType.cross));
        expect(data.colorIndex, equals(2));
        expect(data.rotation, equals(const Offset(-1, -1)));
        expect(data.initial, equals('A'));
      });

      test('"hello" -> line, color 2, pos (-1,-1), initial "H"', () {
        final data = computeFacehash(name: 'hello');

        expect(data.hash, equals(99162322));
        expect(data.faceType, equals(FaceType.line));
        expect(data.colorIndex, equals(2));
        expect(data.rotation, equals(const Offset(-1, -1)));
        expect(data.initial, equals('H'));
      });

      test(
        '"john@example.com" -> round, color 1, pos (-1,-1), initial "J"',
        () {
          final data = computeFacehash(name: 'john@example.com');

          expect(data.hash, equals(326742856));
          expect(data.faceType, equals(FaceType.round));
          expect(data.colorIndex, equals(1));
          expect(data.rotation, equals(const Offset(-1, -1)));
          expect(data.initial, equals('J'));
        },
      );

      test('"alice" -> round, color 0, pos (-1,1), initial "A"', () {
        final data = computeFacehash(name: 'alice');

        expect(data.hash, equals(92903040));
        expect(data.faceType, equals(FaceType.round));
        expect(data.colorIndex, equals(0));
        expect(data.rotation, equals(const Offset(-1, 1)));
        expect(data.initial, equals('A'));
      });

      test('"bob" -> cross, color 2, pos (-1,0), initial "B"', () {
        final data = computeFacehash(name: 'bob');

        expect(data.hash, equals(97717));
        expect(data.faceType, equals(FaceType.cross));
        expect(data.colorIndex, equals(2));
        expect(data.rotation, equals(const Offset(-1, 0)));
        expect(data.initial, equals('B'));
      });
    });

    group('determinism', () {
      test('same name always produces the same FacehashData', () {
        final first = computeFacehash(name: 'stable-input');
        final second = computeFacehash(name: 'stable-input');

        expect(first.hash, equals(second.hash));
        expect(first.faceType, equals(second.faceType));
        expect(first.colorIndex, equals(second.colorIndex));
        expect(first.rotation, equals(second.rotation));
        expect(first.initial, equals(second.initial));
      });
    });

    group('colorsLength parameter', () {
      test('colorIndex respects custom colorsLength', () {
        // hash("alice") = 92903040
        // 92903040 % 3 = 0
        final data = computeFacehash(name: 'alice', colorsLength: 3);
        expect(data.colorIndex, equals(92903040 % 3));
      });

      test('colorIndex stays within bounds for any colorsLength', () {
        for (var len = 1; len <= 10; len++) {
          final data = computeFacehash(name: 'test', colorsLength: len);
          expect(
            data.colorIndex,
            lessThan(len),
            reason: 'colorIndex should be < $len',
          );
          expect(
            data.colorIndex,
            greaterThanOrEqualTo(0),
            reason: 'colorIndex should be >= 0',
          );
        }
      });
    });

    group('initial extraction', () {
      test('initial is uppercase first character', () {
        expect(computeFacehash(name: 'alice').initial, equals('A'));
        expect(computeFacehash(name: 'Bob').initial, equals('B'));
        expect(computeFacehash(name: '123').initial, equals('1'));
      });

      test('empty name produces empty initial', () {
        expect(computeFacehash(name: '').initial, equals(''));
      });
    });

    group('face type distribution', () {
      test('all four face types are reachable', () {
        // We know from parity vectors:
        // round: "alice" (hash=92903040, 0%4=0)
        // cross: "a" (hash=97, 1%4=1)
        // line: "hello" (hash=99162322, 2%4=2)
        // We need to find a curved (hash%4==3) - search programmatically.
        final faceTypes = <FaceType>{};
        const names = [
          'alice',
          'a',
          'hello',
          'john@example.com',
          'bob',
          'Charlie Brown',
          'test123',
          'dave',
          'eve',
          'frank',
          'grace',
          'heidi',
          'ivan',
          'judy',
          'mallory',
          'oscar',
          'peggy',
          'sybil',
          'trent',
          'victor',
          'walter',
        ];

        for (final name in names) {
          faceTypes.add(computeFacehash(name: name).faceType);
        }

        expect(faceTypes, containsAll(FaceType.values));
      });
    });
  });

  group('getColor', () {
    test('returns color from provided palette at given index', () {
      final palette = [
        const Color(0xFFFF0000),
        const Color(0xFF00FF00),
        const Color(0xFF0000FF),
      ];

      expect(getColor(palette, 0), equals(const Color(0xFFFF0000)));
      expect(getColor(palette, 1), equals(const Color(0xFF00FF00)));
      expect(getColor(palette, 2), equals(const Color(0xFF0000FF)));
    });

    test('wraps around when index exceeds palette length', () {
      final palette = [
        const Color(0xFFFF0000),
        const Color(0xFF00FF00),
      ];

      expect(getColor(palette, 2), equals(const Color(0xFFFF0000)));
      expect(getColor(palette, 3), equals(const Color(0xFF00FF00)));
    });

    test('falls back to defaultColors when palette is null', () {
      expect(getColor(null, 0), equals(defaultColors[0]));
      expect(getColor(null, 1), equals(defaultColors[1]));
      expect(getColor(null, 4), equals(defaultColors[4]));
    });

    test('falls back to defaultColors when palette is empty', () {
      expect(getColor(<Color>[], 0), equals(defaultColors[0]));
    });

    test('uses provided palette even if it has one color', () {
      final single = [const Color(0xFFABCDEF)];
      expect(getColor(single, 0), equals(const Color(0xFFABCDEF)));
      expect(getColor(single, 5), equals(const Color(0xFFABCDEF)));
    });
  });
}
