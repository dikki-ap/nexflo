import 'package:flutter/material.dart';
import '../constants/app_animations.dart';

/// Animates a numeric amount value rolling up/down on change.
/// Displays full number with thousands separator (e.g. 4,800 not 4.8K).
/// Decimal part (if present) is shown in a smaller font.
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
    this.compact = false,
  });

  final double amount;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final Color? color;
  final Duration duration;
  final int decimals;
  final TextAlign textAlign;

  /// When true, abbreviates large numbers (e.g. 4.8K, 1.2M).
  /// Defaults to false — full number with thousands separator.
  final bool compact;

  String _formatCompact(double v) {
    final abs = v.abs();
    if (abs >= 1000000000) return '$prefix${(v / 1000000000).toStringAsFixed(1)}B$suffix';
    if (abs >= 1000000) return '$prefix${(v / 1000000).toStringAsFixed(1)}M$suffix';
    if (abs >= 1000) return '$prefix${(v / 1000).toStringAsFixed(1)}K$suffix';
    return '$prefix${v.toStringAsFixed(0)}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? style.color;
    final effectiveStyle =
        effectiveColor != null ? style.copyWith(color: effectiveColor) : style;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: amount),
      duration: duration,
      curve: AppAnimations.easeOutCubic,
      builder: (_, value, __) {
        if (compact || decimals > 0) {
          final text = compact
              ? _formatCompact(value)
              : '$prefix${value.toStringAsFixed(decimals)}$suffix';
          return Text(text, style: effectiveStyle, textAlign: textAlign);
        }

        // Full number with thousands separator + optional small decimal
        final isNeg = value < 0;
        final abs = value.abs();
        final intPart = abs.truncate();
        final decPart = abs - intPart.toDouble();

        // Format integer part with thousands separator
        final intStr = _formatThousands(intPart);
        final sign = isNeg ? '-' : '';

        // Show decimal only if meaningful (> 0.001)
        final decStr = decPart > 0.0005
            ? decPart.toStringAsFixed(3).substring(1) // ".xyz"
            : '';

        final smallStyle = effectiveStyle.copyWith(
          fontSize: (effectiveStyle.fontSize ?? 14) * 0.65,
        );

        return Text.rich(
          TextSpan(
            children: [
              if (prefix.isNotEmpty)
                TextSpan(text: prefix, style: effectiveStyle),
              TextSpan(text: '$sign$intStr', style: effectiveStyle),
              if (decStr.isNotEmpty)
                TextSpan(text: decStr, style: smallStyle),
              if (suffix.isNotEmpty)
                TextSpan(text: suffix, style: effectiveStyle),
            ],
          ),
          textAlign: textAlign,
        );
      },
    );
  }

  static String _formatThousands(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    final len = s.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
