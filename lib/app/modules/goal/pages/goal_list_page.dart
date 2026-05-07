import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/goal_status.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/staggered_list.dart';
import '../../../domain/entities/goal_entity.dart';
import '../controllers/goal_controller.dart';

class GoalListPage extends GetView<GoalController> {
  const GoalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hPad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Goals'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ShimmerLoading(
            isLoading: true,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 100),
              itemCount: 5,
              itemBuilder: (_, __) => const ShimmerCard(
                height: 110,
                horizontalMargin: 0,
                borderRadius: 18,
              ),
            ),
          );
        }
        if (controller.goals.isEmpty) {
          return _EmptyState();
        }
        int staggerIdx = 0;
        return ListView(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 100),
          children: [
            if (controller.activeGoals.isNotEmpty) ...[
              SectionLabel(label: 'Active', padding: const EdgeInsets.only(bottom: 10)),
              ...controller.activeGoals.map((g) {
                final w = StaggeredItem(
                  delayIndex: staggerIdx,
                  child: _GoalCard(g, controller, isDark),
                );
                staggerIdx++;
                return w;
              }),
            ],
            if (controller.completedGoals.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionLabel(label: 'Completed', padding: const EdgeInsets.only(bottom: 10)),
              ...controller.completedGoals.map((g) {
                final w = StaggeredItem(
                  delayIndex: staggerIdx,
                  child: _GoalCard(g, controller, isDark),
                );
                staggerIdx++;
                return w;
              }),
            ],
          ],
        );
      }),
      floatingActionButton: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          controller.initForm();
          Get.toNamed(AppRoutes.goalAdd);
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 22),
              SizedBox(width: 6),
              Text(
                'Add Goal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No goals yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.grey900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to set your first goal',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalEntity goal;
  final GoalController ctrl;
  final bool isDark;
  const _GoalCard(this.goal, this.ctrl, this.isDark);

  @override
  Widget build(BuildContext context) {
    final color = ColorHelper.fromHex(goal.colorHex);
    final isDone = goal.status == GoalStatus.completed;
    final onTrack = ctrl.onTrackLabel(goal);

    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      onTap: () => Get.toNamed(
        AppRoutes.goalDetail.replaceFirst(':id', goal.id),
        arguments: goal,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(IconMapper.get(goal.iconName), color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.grey900,
                        ),
                      ),
                    ),
                    if (isDone)
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.income, size: 18)
                    else if (onTrack.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: (onTrack == 'On Track'
                                  ? AppColors.income
                                  : AppColors.budgetAlert)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          onTrack,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: onTrack == 'On Track'
                                ? AppColors.income
                                : AppColors.budgetAlert,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Gradient progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(height: 6, color: color.withValues(alpha: 0.12)),
                      FractionallySizedBox(
                        widthFactor: goal.progress.clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color.withValues(alpha: 0.7), color],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(goal.progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_fmt(goal.currentAmount)} / ${_fmt(goal.targetAmount)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.45)
                            : AppColors.grey500,
                      ),
                    ),
                  ],
                ),
                if (goal.daysRemaining != null && !isDone)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      goal.daysRemaining! >= 0
                          ? '${goal.daysRemaining} days left'
                          : 'Overdue',
                      style: TextStyle(
                        fontSize: 11,
                        color: goal.daysRemaining! < 0
                            ? AppColors.expense
                            : isDark
                                ? Colors.white.withValues(alpha: 0.35)
                                : AppColors.grey400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
