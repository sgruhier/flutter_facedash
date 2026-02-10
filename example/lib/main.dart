// No need in example
// ignore_for_file: public_member_api_docs

import 'package:facehash/facehash.dart';
import 'package:flutter/material.dart';

void main() => runApp(const FacehashExample());

class FacehashExample extends StatelessWidget {
  const FacehashExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaceHash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorSchemeSeed: Colors.blueGrey,
        brightness: Brightness.light,
      ),
      home: const FacehashDemo(),
    );
  }
}

class FacehashDemo extends StatefulWidget {
  const FacehashDemo({super.key});

  @override
  State<FacehashDemo> createState() => _FacehashDemoState();
}

class _FacehashDemoState extends State<FacehashDemo> {
  final _textController = TextEditingController(text: 'Odubu');
  FacehashShape _selectedShape = FacehashShape.squircle;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Section builders
  // -------------------------------------------------------------------------

  Widget _buildTryItSection() {
    return _Section(
      title: 'try it -- type anything',
      children: [
        // Text input
        TextField(
          controller: _textController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Type a name or email...',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade500,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Shape selector chips
        Row(
          children: [
            _ShapeChip(
              label: 'square',
              selected: _selectedShape == FacehashShape.square,
              onTap: () =>
                  setState(() => _selectedShape = FacehashShape.square),
            ),
            const SizedBox(width: 8),
            _ShapeChip(
              label: 'squircle',
              selected: _selectedShape == FacehashShape.squircle,
              onTap: () =>
                  setState(() => _selectedShape = FacehashShape.squircle),
            ),
            const SizedBox(width: 8),
            _ShapeChip(
              label: 'round',
              selected: _selectedShape == FacehashShape.circle,
              onTap: () =>
                  setState(() => _selectedShape = FacehashShape.circle),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Sizes row
        const _SubLabel('sizes'),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final size in [32.0, 48.0, 64.0, 80.0]) ...[
              if (size != 32.0) const SizedBox(width: 20),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Facehash(
                    name: _textController.text,
                    size: size,
                    shape: _selectedShape,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${size.toInt()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 28),

        // Variants row
        const _SubLabel('variants'),
        const SizedBox(height: 12),
        Row(
          children: [
            _LabeledFace(
              label: '3d',
              child: Facehash(
                name: _textController.text,
                size: 56,
                shape: _selectedShape,
              ),
            ),
            const SizedBox(width: 24),
            _LabeledFace(
              label: 'flat',
              child: Facehash(
                name: _textController.text,
                size: 56,
                shape: _selectedShape,
                intensity3d: Intensity3D.none,
              ),
            ),
            const SizedBox(width: 24),
            _LabeledFace(
              label: 'no letter',
              child: Facehash(
                name: _textController.text,
                size: 56,
                shape: _selectedShape,
                showInitial: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropsSection() {
    return _Section(
      title: 'props',
      children: [
        // -- name -------------------------------------------------------------
        const _PropLabel('name'),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final name in ['alice', 'bob', 'charlie']) ...[
              if (name != 'alice') const SizedBox(width: 16),
              _LabeledFace(
                label: name,
                child: Facehash(name: name, size: 56),
              ),
            ],
          ],
        ),
        const SizedBox(height: 36),

        // -- colors -----------------------------------------------------------
        const _PropLabel('colors'),
        const SizedBox(height: 12),
        const _SubLabel('default'),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final name in [
              'pink',
              'amber',
              'blue',
              'orange',
              'emerald',
            ]) ...[
              if (name != 'pink') const SizedBox(width: 12),
              Facehash(name: name, size: 48),
            ],
          ],
        ),
        const SizedBox(height: 16),
        const _SubLabel('custom'),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final name in [
              'terra',
              'moss',
              'clay',
              'sage',
              'bark',
            ]) ...[
              if (name != 'terra') const SizedBox(width: 12),
              Facehash(
                name: name,
                size: 48,
                colors: const [
                  Color(0xFF264653),
                  Color(0xFF2A9D8F),
                  Color(0xFFE9C46A),
                  Color(0xFFF4A261),
                  Color(0xFFE76F51),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 36),

        // -- intensity3d ------------------------------------------------------
        const _PropLabel('intensity3d'),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final entry in {
              'none': Intensity3D.none,
              'subtle': Intensity3D.subtle,
              'medium': Intensity3D.medium,
              'dramatic': Intensity3D.dramatic,
            }.entries) ...[
              if (entry.key != 'none') const SizedBox(width: 16),
              _LabeledFace(
                label: entry.key,
                child: Facehash(
                  name: 'intensity',
                  size: 56,
                  intensity3d: entry.value,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 36),

        // -- variant ----------------------------------------------------------
        const _PropLabel('variant'),
        const SizedBox(height: 12),
        const Row(
          children: [
            _LabeledFace(
              label: 'gradient',
              child: Facehash(
                name: 'variant',
                size: 56,
              ),
            ),
            SizedBox(width: 16),
            _LabeledFace(
              label: 'solid',
              child: Facehash(
                name: 'variant',
                size: 56,
                variant: FacehashVariant.solid,
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),

        // -- showInitial ------------------------------------------------------
        const _PropLabel('showInitial'),
        const SizedBox(height: 12),
        const Row(
          children: [
            _LabeledFace(
              label: 'true',
              child: Facehash(
                name: 'initial',
                size: 56,
              ),
            ),
            SizedBox(width: 16),
            _LabeledFace(
              label: 'false',
              child: Facehash(
                name: 'initial',
                size: 56,
                showInitial: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),

        // -- enableBlink ------------------------------------------------------
        const _PropLabel('enableBlink'),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final name in ['blinky', 'winky', 'noddy']) ...[
              if (name != 'blinky') const SizedBox(width: 16),
              _LabeledFace(
                label: name,
                child: Facehash(
                  name: name,
                  size: 56,
                  enableBlink: true,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 36),

        // -- mouthBuilder -----------------------------------------------------
        const _PropLabel('mouthBuilder'),
        const SizedBox(height: 12),
        Row(
          children: [
            const _LabeledFace(
              label: 'default',
              child: Facehash(
                name: 'loading',
                size: 64,
                shape: FacehashShape.squircle,
              ),
            ),
            const SizedBox(width: 16),
            _LabeledFace(
              label: 'spinner',
              child: Facehash(
                name: 'loading',
                size: 64,
                shape: FacehashShape.squircle,
                mouthBuilder: (_) => const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            _LabeledFace(
              label: 'thinking',
              child: Facehash(
                name: 'thinking',
                size: 64,
                shape: FacehashShape.squircle,
                enableBlink: true,
                mouthBuilder: (_) => const _SadMouth(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUseCasesSection() {
    return _Section(
      title: 'use cases',
      children: [
        // -- Chat -------------------------------------------------------------
        const _SubLabel('chat'),
        const SizedBox(height: 12),
        for (final msg in [
          ('alice', 'Hey, has anyone seen the new design?'),
          ('bob', 'Yeah, looks great! Ship it.'),
          ('charlie', 'One small tweak on the spacing...'),
        ]) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Facehash(
                  name: msg.$1,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        msg.$2,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),

        // -- User list (avatar stack) -----------------------------------------
        const _SubLabel('avatar stack'),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: Stack(
            children: [
              for (var i = 0; i < _stackNames.length; i++)
                Positioned(
                  left: i * 30.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: Facehash(
                      name: _stackNames[i],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static const _stackNames = [
    'alice',
    'bob',
    'charlie',
    'diana',
    'eve',
    'frank',
  ];

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'facehash',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'deterministic avatar faces from any string',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 40),

              _buildTryItSection(),
              const SizedBox(height: 48),
              _buildPropsSection(),
              const SizedBox(height: 48),
              _buildUseCasesSection(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Shared presentation widgets
// =============================================================================

/// A top-level section with a grey, lowercase title.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }
}

/// A monospace-styled prop name label.
class _PropLabel extends StatelessWidget {
  const _PropLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}

/// A lightweight sub-label (e.g. "default", "custom", "sizes").
class _SubLabel extends StatelessWidget {
  const _SubLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade500,
        letterSpacing: 0.3,
      ),
    );
  }
}

/// A face widget with a label below it.
class _LabeledFace extends StatelessWidget {
  const _LabeledFace({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

/// A toggle chip for the shape selector.
class _ShapeChip extends StatelessWidget {
  const _ShapeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

/// A custom sad/thinking mouth drawn as a curved line.
class _SadMouth extends StatelessWidget {
  const _SadMouth();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(16, 10),
      painter: _SadMouthPainter(),
    );
  }
}

class _SadMouthPainter extends CustomPainter {
  const _SadMouthPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width,
        size.height * 0.2,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
