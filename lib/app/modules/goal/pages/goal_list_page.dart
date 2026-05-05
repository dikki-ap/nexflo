import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/goal_status.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../domain/entities/goal_entity.dart';
import '../controllers/goal_controller.dart';

class GoalListPage extends GetView<GoalController> {
  const GoalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.goals.isEmpty) {
          return _EmptyState();
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            if (controller.activeGoals.isNotEmpty) ...[
              _SectionHeader('Active'),
              ...controller.activeGoals
                  .map((g) => _GoalCard(g, controller)),
            ],
            if (controller.completedGoals.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SectionHeader('Completed'),
              ...controller.completedGoals
                  .map((g) => _GoalCard(g, controller)),
            ],
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.initForm();
          Get.toNamed(AppRoutes.goalAdd);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text('No goals yet',
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalEntity goal;
  final GoalController ctrl;
  const _GoalCard(this.goal, this.ctrl);

  @override
  Widget build(BuildContext context) {
    final color = ColorHelper.fromHex(goal.colorHex);
    final isDone = goal.status == GoalStatus.completed;
    final onTrack = ctrl.onTrackLabel(goal);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.toNamed(
          AppRoutes.goalDetail.replaceFirst(':id', goal.id),
          arguments: goal,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(IconMapper.get(goal.iconName),
                    color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(goal.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14))),
                        if (isDone)
                          Icon(Icons.check_circle,
                              color: AppColors.income, size: 18),
                        if (!isDone && onTrack.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
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
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        minHeight: 6,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(goal.progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${_fmt(goal.currentAmount)} / ${_fmt(goal.targetAmount)}',
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                    if (goal.daysRemaining != null && !isDone)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          goal.daysRemaining! >= 0
                              ? '${goal.daysRemaining} days left'
                              : 'Overdue',
                          style: TextStyle(
                              fontSize: 11,
                              color: goal.daysRemaining! < 0
                                  ? AppColors.expense
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.4)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
