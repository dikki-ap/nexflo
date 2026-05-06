import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_animations.dart';
import '../constants/app_colors.dart';

class NavItem {
  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Floating glassmorphic bottom navigation bar.
/// Active item shows pill highlight + teal color + glow.
/// Center item (index 2) is the FAB-style add button.
class ModernBottomNav extends StatelessWidget {
  const ModernBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.onFabTap,
    this.accentColor = AppColors.teal,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onFabTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkCard.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.88);
    final shadow = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ];

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? AppColors.glassBorder : Colors.white.withValues(alpha: 0.7),
                width: 1,
              ),
              boxShadow: shadow,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildChildren(isDark),
            ),
          ),
        ),
      ),
    );
  }
}

  // Inserts the FAB BETWEEN items at the halfway point (not replacing any item).
  // With 3 items [Home, Statistics, Settings]: Home | [FAB] | Statistics | Settings
  List<Widget> _buildChildren(bool isDark) {
    if (onFabTap == null) {
      return List.generate(
        items.length,
        (i) => _NavItemWidget(
          item: items[i],
          isActive: currentIndex == i,
          accentColor: accentColor,
          isDark: isDark,
          onTap: () => onTap(i),
        ),
      );
    }
    final half = items.length ~/ 2;
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i == half) {
        result.add(_FabItem(accentColor: accentColor, onTap: onFabTap!));
      }
      result.add(_NavItemWidget(
        item: items[i],
        isActive: currentIndex == i,
        accentColor: accentColor,
        isDark: isDark,
        onTap: () => onTap(i),
      ));
    }
    return result;
  }
}

class _NavItemWidget extends StatelessWidget {
  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  final NavItem item;
  final bool isActive;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? accentColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppAnimations.fast,
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                color: isActive
                    ? accentColor
                    : (isDark ? AppColors.grey500 : AppColors.grey400),
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: AppAnimations.fast,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? accentColor
                    : (isDark ? AppColors.grey500 : AppColors.grey400),
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _FabItem extends StatefulWidget {
  const _FabItem({required this.accentColor, required this.onTap});
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_FabItem> createState() => _FabItemState();
}

class _FabItemState extends State<_FabItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
      lowerBound: 0,
      upperBound: 1,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: Tween(begin: 1.0, end: 0.92)
              .evaluate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)),
          child: child,
        ),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.tealGlow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
