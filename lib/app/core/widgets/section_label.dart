import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../config/theme/app_text_styles.dart';

/// Uppercase section label with optional "See All" action button.
class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.label,
    this.onSeeAll,
    this.seeAllLabel = 'See All',
    this.padding,
  });

  final String label;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.grey400 : AppColors.grey500;
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.sectionLabel.copyWith(color: labelColor),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                seeAllLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
