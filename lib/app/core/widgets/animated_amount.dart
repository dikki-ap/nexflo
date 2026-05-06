import 'package:flutter/material.dart';
import '../constants/app_animations.dart';

/// Animates a numeric amount value rolling up/down on change.
/// Shows formatted string while number tweens smoothly.
class AnimatedAmount extends StatelessWidget {
  const AnimatedAmount({
    super.key,
    required this.amount,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.color,
    this.duration = AppAnimations.counter,
    this.decimals = 0,
    this.textAlign = TextAlign.start,
  });

  final double amount;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final Color? color;
  final Duration duration;
  final int decimals;
  final TextAlign textAlign;

  String _format(double v) {
    if (decimals == 0) {
      final abs = v.abs();
      if (abs >= 1000000000) return '${prefix}${(v / 1000000000).toStringAsFixed(1)}B$suffix';
      if (abs >= 1000000) return '${prefix}${(v / 1000000).toStringAsFixed(1)}M$suffix';
      if (abs >= 1000) return '${prefix}${(v / 1000).toStringAsFixed(1)}K$suffix';
      return '$prefix${v.toStringAsFixed(0)}$suffix';
    }
    return '$prefix${v.toStringAsFixed(decimals)}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: amount),
      duration: duration,
      curve: AppAnimations.easeOutCubic,
      builder: (_, value, __) {
        return Text(
          _format(value),
          style: color != null ? style.copyWith(color: color) : style,
          textAlign: textAlign,
        );
      },
    );
  }
}
