import 'dart:ui';

/// Parses an SVG path data string into a Flutter [Path].
///
/// Supports the following commands: M, C, H, V, L, Z (absolute only).
/// This is a minimal parser covering only the SVG commands used
/// by FaceHash face paths.
Path parseSvgPath(String d) {
  final path = Path();
  final tokens = _tokenize(d);
  var i = 0;
  var currentX = 0.0;
  var currentY = 0.0;

  while (i < tokens.length) {
    final token = tokens[i];

    switch (token) {
      case 'M':
        currentX = double.parse(tokens[++i]);
        currentY = double.parse(tokens[++i]);
        path.moveTo(currentX, currentY);
        i++;
      case 'L':
        currentX = double.parse(tokens[++i]);
        currentY = double.parse(tokens[++i]);
        path.lineTo(currentX, currentY);
        i++;
      case 'H':
        currentX = double.parse(tokens[++i]);
        path.lineTo(currentX, currentY);
        i++;
      case 'V':
        currentY = double.parse(tokens[++i]);
        path.lineTo(currentX, currentY);
        i++;
      case 'C':
        final x1 = double.parse(tokens[++i]);
        final y1 = double.parse(tokens[++i]);
        final x2 = double.parse(tokens[++i]);
        final y2 = double.parse(tokens[++i]);
        currentX = double.parse(tokens[++i]);
        currentY = double.parse(tokens[++i]);
        path.cubicTo(x1, y1, x2, y2, currentX, currentY);
        i++;
      case 'Z':
        path.close();
        i++;
      default:
        // Try to parse as implicit command continuation.
        // After M, subsequent coordinate pairs are treated as L.
        // After C, subsequent coordinate groups are treated as C.
        if (_isNumber(token)) {
          // Look back to find the last command for implicit continuation
          // This handles cases like "M x y x2 y2" (implicit L after M)
          // and "C ... x y x y x y" (implicit C continuation)
          i = _handleImplicitCommand(path, tokens, i, currentX, currentY);
          if (i < tokens.length && _isNumber(tokens[i])) {
            // Update current position - already handled
            // by _handleImplicitCommand
          }
        } else {
          i++; // Skip unknown tokens
        }
    }
  }

  return path;
}

int _handleImplicitCommand(
  Path path,
  List<String> tokens,
  int i,
  double currentX,
  double currentY,
) {
  // Default to lineTo for implicit coordinates after moveTo
  final x = double.parse(tokens[i]);
  if (i + 1 < tokens.length && _isNumber(tokens[i + 1])) {
    final y = double.parse(tokens[i + 1]);
    path.lineTo(x, y);
    return i + 2;
  }
  return i + 1;
}

bool _isNumber(String token) {
  if (token.isEmpty) return false;
  final c = token.codeUnitAt(0);
  return c == 0x2D || // '-'
      c == 0x2E || // '.'
      (c >= 0x30 && c <= 0x39); // '0'-'9'
}

/// Tokenizes an SVG path data string into commands and numbers.
List<String> _tokenize(String d) {
  final tokens = <String>[];
  final buffer = StringBuffer();

  for (var i = 0; i < d.length; i++) {
    final c = d[i];

    if (c == ',' || c == ' ' || c == '\n' || c == '\t' || c == '\r') {
      if (buffer.isNotEmpty) {
        tokens.add(buffer.toString());
        buffer.clear();
      }
    } else if (_isSvgCommand(c)) {
      if (buffer.isNotEmpty) {
        tokens.add(buffer.toString());
        buffer.clear();
      }
      tokens.add(c);
    } else if (c == '-' &&
        buffer.isNotEmpty &&
        !_isExponent(buffer.toString(), i, d)) {
      // Negative sign starts a new number (e.g., "3.5-2.1")
      tokens.add(buffer.toString());
      buffer
        ..clear()
        ..write(c);
    } else {
      buffer.write(c);
    }
  }

  if (buffer.isNotEmpty) {
    tokens.add(buffer.toString());
  }

  return tokens;
}

bool _isExponent(String buffer, int i, String d) {
  // Check if the '-' is part of scientific notation (e.g., "1.23e-4")
  return buffer.isNotEmpty && (buffer.endsWith('e') || buffer.endsWith('E'));
}

bool _isSvgCommand(String c) {
  return c == 'M' ||
      c == 'L' ||
      c == 'H' ||
      c == 'V' ||
      c == 'C' ||
      c == 'Z' ||
      c == 'm' ||
      c == 'l' ||
      c == 'h' ||
      c == 'v' ||
      c == 'c' ||
      c == 'z';
}
