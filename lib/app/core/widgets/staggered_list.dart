import 'package:flutter/material.dart';
import '../constants/app_animations.dart';

/// Wraps a widget to animate in with slide + fade when first built.
/// Use [delayIndex] to stagger multiple items in a list.
class StaggeredItem extends StatefulWidget {
  const StaggeredItem({
    super.key,
    required this.child,
    this.delayIndex = 0,
    this.duration = AppAnimations.slow,
    this.slideOffset = const Offset(0, 24),
  });

  final Widget child;
  final int delayIndex;
  final Duration duration;
  final Offset slideOffset;

  @override
  State<StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: AppAnimations.easeOutCubic);
    _slide = Tween<Offset>(begin: widget.slideOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: AppAnimations.easeOutCubic),
    );

    final delay = AppAnimations.staggerOffset * widget.delayIndex;
    Future.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: _slide.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Convenience builder for staggered animated lists.
/// [itemBuilder] receives (context, index) and returns the item widget.
/// [count] total item count.
class StaggeredListView extends StatelessWidget {
  const StaggeredListView({
    super.key,
    required this.count,
    required this.itemBuilder,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.separator,
  });

  final int count;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final Widget? separator;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: count,
      separatorBuilder: (_, __) => separator ?? const SizedBox(height: 8),
      itemBuilder: (ctx, i) => StaggeredItem(
        delayIndex: i,
        child: itemBuilder(ctx, i),
      ),
    );
  }
}
