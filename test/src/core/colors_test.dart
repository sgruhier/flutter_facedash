import 'dart:ui';

import 'package:facehash/src/core/colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('defaultColors', () {
    test('has exactly 5 entries', () {
      expect(defaultColors, hasLength(5));
    });

    test('all colors have full opacity', () {
      for (final color in defaultColors) {
        expect(
          color.a,
          equals(1.0),
          reason:
              '${color.toARGB32().toRadixString(16)} should have full opacity',
        );
      }
    });

    test('contains expected hex values', () {
      expect(defaultColors[0], equals(const Color(0xFFEC4899))); // pink-500
      expect(defaultColors[1], equals(const Color(0xFFF59E0B))); // amber-500
      expect(defaultColors[2], equals(const Color(0xFF3B82F6))); // blue-500
      expect(defaultColors[3], equals(const Color(0xFFF97316))); // orange-500
      expect(defaultColors[4], equals(const Color(0xFF10B981))); // emerald-500
    });
  });

  group('defaultColorsLight', () {
    test('has exactly 5 entries', () {
      expect(defaultColorsLight, hasLength(5));
    });

    test('all colors have full opacity', () {
      for (final color in defaultColorsLight) {
        expect(
          color.a,
          equals(1.0),
          reason:
              '${color.toARGB32().toRadixString(16)} should have full opacity',
        );
      }
    });

    test('contains expected hex values', () {
      expect(
        defaultColorsLight[0],
        equals(const Color(0xFFFCE7F3)),
      ); // pink-100
      expect(
        defaultColorsLight[1],
        equals(const Color(0xFFFEF3C7)),
      ); // amber-100
      expect(
        defaultColorsLight[2],
        equals(const Color(0xFFDBEAFE)),
      ); // blue-100
      expect(
        defaultColorsLight[3],
        equals(const Color(0xFFFFEDD5)),
      ); // orange-100
      expect(
        defaultColorsLight[4],
        equals(const Color(0xFFD1FAE5)),
      ); // emerald-100
    });
  });

  group('defaultColorsDark', () {
    test('has exactly 5 entries', () {
      expect(defaultColorsDark, hasLength(5));
    });

    test('all colors have full opacity', () {
      for (final color in defaultColorsDark) {
        expect(
          color.a,
          equals(1.0),
          reason:
              '${color.toARGB32().toRadixString(16)} should have full opacity',
        );
      }
    });

    test('contains expected hex values', () {
      expect(defaultColorsDark[0], equals(const Color(0xFFDB2777))); // pink-600
      expect(
        defaultColorsDark[1],
        equals(const Color(0xFFD97706)),
      ); // amber-600
      expect(defaultColorsDark[2], equals(const Color(0xFF2563EB))); // blue-600
      expect(
        defaultColorsDark[3],
        equals(const Color(0xFFEA580C)),
      ); // orange-600
      expect(
        defaultColorsDark[4],
        equals(const Color(0xFF059669)),
      ); // emerald-600
    });
  });

  group('palette consistency', () {
    test('all three palettes have the same length', () {
      expect(defaultColors.length, equals(defaultColorsLight.length));
      expect(defaultColors.length, equals(defaultColorsDark.length));
    });

    test('light colors are lighter than default colors (higher value)', () {
      for (var i = 0; i < defaultColors.length; i++) {
        // Light variants should generally have higher RGB values
        // (closer to white). We check the sum of RGB components.
        final defaultSum =
            (defaultColors[i].r * 255.0).round() +
            (defaultColors[i].g * 255.0).round() +
            (defaultColors[i].b * 255.0).round();
        final lightSum =
            (defaultColorsLight[i].r * 255.0).round() +
            (defaultColorsLight[i].g * 255.0).round() +
            (defaultColorsLight[i].b * 255.0).round();

        expect(
          lightSum,
          greaterThan(defaultSum),
          reason:
              'Light color at index $i should be lighter than default color',
        );
      }
    });
  });
}
