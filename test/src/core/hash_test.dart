// ignore_for_file: prefer_const_constructors

import 'package:facehash/src/core/hash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stringHash', () {
    group('cross-platform parity vectors', () {
      // These expected values were computed from the JavaScript reference
      // implementation to guarantee cross-platform determinism.
      final vectors = <String, int>{
        '': 0,
        'a': 97,
        'hello': 99162322,
        'john@example.com': 326742856,
        'alice': 92903040,
        'bob': 97717,
        'Charlie Brown': 22298312,
        '\u{1F389}': 1773261, // "🎉"
        'test123': 1422501792,
      };

      for (final entry in vectors.entries) {
        test('stringHash("${entry.key}") == ${entry.value}', () {
          expect(stringHash(entry.key), equals(entry.value));
        });
      }
    });

    group('determinism', () {
      test('same string always returns the same hash', () {
        const input = 'deterministic-test-string';
        final first = stringHash(input);
        final second = stringHash(input);
        final third = stringHash(input);

        expect(first, equals(second));
        expect(second, equals(third));
      });

      test('hash is deterministic across multiple calls with various inputs',
          () {
        const inputs = [
          'short',
          'a much longer string with spaces and punctuation!',
          '12345',
          'UPPERCASE',
          'mixedCase123',
        ];

        for (final input in inputs) {
          expect(
            stringHash(input),
            equals(stringHash(input)),
            reason: 'Hash should be deterministic for "$input"',
          );
        }
      });
    });

    group('uniqueness', () {
      test('different strings produce different hashes', () {
        final hashes = <int>{};
        const inputs = [
          'alice',
          'bob',
          'charlie',
          'dave',
          'eve',
          'frank',
          'grace',
          'hello',
          'world',
          'test',
        ];

        for (final input in inputs) {
          hashes.add(stringHash(input));
        }

        expect(
          hashes.length,
          equals(inputs.length),
          reason: 'All distinct inputs should produce distinct hashes',
        );
      });

      test('"a" and "b" produce different hashes', () {
        expect(stringHash('a'), isNot(equals(stringHash('b'))));
      });

      test('"abc" and "cba" produce different hashes', () {
        expect(stringHash('abc'), isNot(equals(stringHash('cba'))));
      });
    });

    group('edge cases', () {
      test('empty string returns 0', () {
        expect(stringHash(''), equals(0));
      });

      test('single character returns its code unit', () {
        // For a single character, hash = ((0 << 5) - 0 + code) = code
        expect(stringHash('a'), equals(97));
        expect(stringHash('A'), equals(65));
        expect(stringHash('0'), equals(48));
      });

      test('hash is always non-negative', () {
        // Test strings that might produce negative intermediate values.
        const inputs = [
          'negative-test',
          'zzzzzzzzzz',
          '\u{FFFF}',
          'a very long string that might overflow',
        ];

        for (final input in inputs) {
          expect(
            stringHash(input),
            greaterThanOrEqualTo(0),
            reason: 'Hash for "$input" should be non-negative',
          );
        }
      });
    });
  });
}
