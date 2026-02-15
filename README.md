# FaceHash

[![ci](https://github.com/sgruhier/flutter_facedash/actions/workflows/main.yaml/badge.svg)](https://github.com/sgruhier/flutter_facedash/actions/workflows/main.yaml)
[![coverage](https://raw.githubusercontent.com/sgruhier/flutter_facedash/main/coverage_badge.svg)](https://github.com/sgruhier/flutter_facedash/actions/workflows/main.yaml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

Deterministic avatar faces from any string. Same input always produces the same unique face.

[**Live Demo**](https://sgruhier.github.io/flutter_facedash/)

<p align="center">
  <img src="https://raw.githubusercontent.com/sgruhier/flutter_facedash/main/screenshot.png" alt="FaceHash screenshot" width="300" />
</p>

Zero additional dependencies. Works everywhere Flutter runs.

## Installation

```yaml
dependencies:
  facehash: ^0.1.0
```

## Usage

```dart
import 'package:facehash/facehash.dart';

// Simple usage
const Facehash(name: 'alice')

// Full customization
Facehash(
  name: 'bob@example.com',
  size: 64,
  shape: FacehashShape.squircle,
  variant: FacehashVariant.solid,
  intensity3d: Intensity3D.subtle,
  enableBlink: true,
  colors: [
    Color(0xFF264653),
    Color(0xFF2A9D8F),
    Color(0xFFE76F51),
  ],
)
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `String` | required | String to generate a face from |
| `size` | `double` | `40.0` | Avatar size in logical pixels |
| `variant` | `FacehashVariant` | `gradient` | `gradient` or `solid` background |
| `intensity3d` | `Intensity3D` | `dramatic` | 3D tilt: `none`, `subtle`, `medium`, `dramatic` |
| `interactive` | `bool` | `true` | Flatten on hover/tap |
| `showInitial` | `bool` | `true` | Show first letter below eyes |
| `enableBlink` | `bool` | `false` | Eye blink animation |
| `colors` | `List<Color>?` | 5 defaults | Custom color palette |
| `shape` | `FacehashShape` | `circle` | `circle`, `square`, `squircle` |
| `eyeColor` | `Color?` | white | Eye and initial color |
| `mouthBuilder` | `Widget Function(FacehashData)?` | `null` | Custom mouth widget |
| `onTap` | `VoidCallback?` | `null` | Tap callback |

## Face Types

FaceHash deterministically selects from 4 face types based on the input string hash:

- **Round** - Simple circular eyes
- **Cross** - Plus-shaped eyes
- **Line** - Horizontal line eyes
- **Curved** - Sleepy/happy curved eyes

## Advanced Usage

### Custom Mouth

Replace the initial letter with any widget:

```dart
Facehash(
  name: 'loading',
  mouthBuilder: (data) => const SizedBox(
    width: 16,
    height: 16,
    child: CircularProgressIndicator(strokeWidth: 2),
  ),
)
```

### Core Functions

Access the hash and face data directly:

```dart
// Get the hash value
final hash = stringHash('alice'); // 92903040

// Get full face data
final data = computeFacehash(name: 'alice');
print(data.faceType);   // FaceType.round
print(data.colorIndex);  // 0
print(data.initial);     // 'A'
```

## Cross-Platform Parity

FaceHash produces identical faces on all platforms. The same string generates the same face in both the Flutter package and the [React/npm package](https://www.npmjs.com/package/facehash).

This is a Flutter port of [facehash.dev](https://www.facehash.dev/), originally created by [Anthony Riera](https://github.com/Rieranthony) as part of the [Cossistant](https://github.com/cossistantcom/cossistant) project. Built with [Claude Code](https://claude.ai/code).

## License

MIT
