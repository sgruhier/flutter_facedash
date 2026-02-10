import 'package:flutter/animation.dart';

/// Computes blink animation timing from a hash value.
///
/// Matches the React implementation:
/// - delay: `(hash * 31 % 40) / 10` → 0-4 seconds
/// - duration: `2 + (hash * 31 % 40) / 10` → 2-6 seconds
({double delay, double duration}) blinkTimingFromHash(int hash) {
  final blinkSeed = hash * 31;
  final mod = (blinkSeed % 40).abs();
  final delay = mod / 10.0;
  final duration = 2.0 + mod / 10.0;
  return (delay: delay, duration: duration);
}

/// A [TweenSequence] matching the React blink CSS keyframe:
///
/// ```text
/// 0%-92%:  scaleY(1.0)   — eyes open
/// 92%-96%: scaleY(0.05)  — eyes closing
/// 96%-100%: scaleY(1.0)  — eyes opening
/// ```
final TweenSequence<double> blinkTweenSequence = TweenSequence<double>([
  TweenSequenceItem(
    tween: ConstantTween<double>(1),
    weight: 92,
  ),
  TweenSequenceItem(
    tween: Tween<double>(begin: 1, end: 0.05),
    weight: 4,
  ),
  TweenSequenceItem(
    tween: Tween<double>(begin: 0.05, end: 1),
    weight: 4,
  ),
]);
