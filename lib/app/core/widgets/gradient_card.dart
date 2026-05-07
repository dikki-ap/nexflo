import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Rich gradient card with optional teal glow shadow.
/// Used for hero sections (net worth, dashboard header).
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.borderRadius = 24.0,
    this.padding,
    this.margin,
    this.onTap,
    this.withGlow = true,
    this.height,
    this.width,
  });

  final Widget child;
  final LinearGradient? gradient;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool withGlow;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final effectiveGradient = gradient ?? AppColors.primaryGradient(primary);
    Widget card = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          child: card,
        ),
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }
    return card;
  }
}
