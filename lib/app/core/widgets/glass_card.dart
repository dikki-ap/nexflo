import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Glassmorphism card — frosted blur + glass border.
/// Use on top of gradient backgrounds for maximum effect.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.blur = 12.0,
    this.color,
    this.border,
    this.gradient,
    this.onTap,
    this.boxShadow,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final Color? color;
  final Border? border;
  final LinearGradient? gradient;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? AppColors.glassLight : Colors.white.withValues(alpha: 0.7);
    final defaultBorder = Border.all(
      color: isDark ? AppColors.glassBorder : Colors.white.withValues(alpha: 0.6),
      width: 1.0,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: gradient,
            color: gradient == null ? (color ?? defaultColor) : null,
            border: border ?? defaultBorder,
            boxShadow: boxShadow,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      final primary = Theme.of(context).colorScheme.primary;
      card = Material(
        color: Colors.transparent,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: primary.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          child: card,
        ),
      );
    }

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}
