import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_animations.dart';
import '../constants/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark
          ? AppAnimations.shimmerBase
          : AppAnimations.shimmerBaseLight,
      highlightColor: isDark
          ? AppAnimations.shimmerHighlight
          : AppAnimations.shimmerHighlightLight,
      child: child,
    );
  }
}

/// Generic shimmer block — fill it with white, Shimmer wraps the color.
class ShimmerTile extends StatelessWidget {
  const ShimmerTile({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = 8,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer placeholder for a standard transaction tile.
class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key, this.horizontalPadding = 20});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 11,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 14,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer card placeholder — height and margin are responsive.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
    this.height = 100,
    this.horizontalMargin = 20,
    this.borderRadius = 20,
  });

  final double height;
  final double horizontalMargin;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A row of shimmer wallet card placeholders.
class ShimmerWalletRow extends StatelessWidget {
  const ShimmerWalletRow({super.key, this.cardWidth = 160, this.height = 100});

  final double cardWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

/// Full-page shimmer for list screens.
class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ShimmerLoading(
      isLoading: true,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, __) => const ShimmerListTile(),
      ),
    );
  }
}
