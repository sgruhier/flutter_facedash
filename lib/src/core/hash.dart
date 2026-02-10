/// Generates a consistent numeric hash from a string.
///
/// This implementation matches the JavaScript version exactly by using
/// 32-bit signed integer arithmetic. The bitwise AND with `0xFFFFFFFF`
/// and conversion via `.toSigned(32)` ensures cross-platform parity
/// with JavaScript's `hash &= hash`.
///
/// Same string always produces the same hash on all platforms.
int stringHash(String str) {
  var hash = 0;
  for (var i = 0; i < str.length; i++) {
    final char = str.codeUnitAt(i);
    hash = ((hash << 5) - hash + char) & 0xFFFFFFFF;
    hash = hash.toSigned(32);
  }
  return hash.abs();
}
