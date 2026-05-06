import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/staggered_list.dart';
import '../../../domain/entities/budget_entity.dart';
import '../controllers/budget_controller.dart';

class BudgetListPage extends GetView<BudgetController> {
  const BudgetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hPad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Budgets'),
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
                height: 120,
                horizontalMargin: 0,
                borderRadius: 18,
              ),
            ),
          );
        }
        if (controller.budgets.isEmpty) {
          return _EmptyState();
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 100),
          itemCount: controller.budgets.length + (controller.alertBudgets.isNotEmpty ? 1 : 0),
          itemBuilder: (_, i) {
            if (controller.alertBudgets.isNotEmpty && i == 0) {
              return _AlertBanner(controller.alertBudgets.length);
            }
            final idx = controller.alertBudgets.isNotEmpty ? i - 1 : i;
            return StaggeredItem(
              delayIndex: idx,
              child: _BudgetCard(controller.budgets[idx], controller, isDark),
            );
          },
        );
      }),
      floatingActionButton: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          controller.initForm();
          Get.toNamed(AppRoutes.budgetAdd);
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.tealGlow,
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
                'Add Budget',
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

class _AlertBanner extends StatelessWidget {
  final int count;
  const _AlertBanner(this.count);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.budgetAlert.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: AppColors.budgetAlert, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            '$count budget${count > 1 ? 's' : ''} reaching limit',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.budgetAlert,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
            decoration: const BoxDecoration(
              color: AppColors.tealGlowSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pie_chart_outline_rounded,
              size: 36,
              color: AppColors.tealMid,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No budgets yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.grey900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to set your first budget',
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

class _BudgetCard extends StatelessWidget {
  final BudgetEntity budget;
  final BudgetController ctrl;
  final bool isDark;
  const _BudgetCard(this.budget, this.ctrl, this.isDark);

  @override
  Widget build(BuildContext context) {
    final spent = ctrl.spentFor(budget);
    final progress = ctrl.progressFor(budget);
    final progressColor = _progressColor(progress);
    final effectiveLimit = ctrl.effectiveLimitFor(budget);
    final rollover = ctrl.rolloverAmounts[budget.id] ?? 0;

    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          budget.period.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.45)
                                : AppColors.grey500,
                          ),
                        ),
                        if (rollover > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.income.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '+${_fmt(rollover)} rollover',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.income,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (progress > 1)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.expense.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Over Budget',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.expense,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : AppColors.grey400,
                ),
                onSelected: (v) {
                  if (v == 'edit') {
                    ctrl.initForm(budget);
                    Get.toNamed(
                      AppRoutes.budgetEdit.replaceFirst(':id', budget.id),
                      arguments: budget,
                    );
                  } else {
                    _confirmDelete(context);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Gradient progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  color: progressColor.withValues(alpha: 0.12),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          progressColor.withValues(alpha: 0.75),
                          progressColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _fmt(spent),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: progressColor,
                ),
              ),
              Text(
                'of ${_fmt(effectiveLimit)}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.45)
                      : AppColors.grey500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _progressColor(double p) {
    if (p > 1.0) return AppColors.budgetOver;
    if (p >= 0.8) return AppColors.budgetAlert;
    if (p >= 0.6) return AppColors.budgetWarning;
    return AppColors.budgetSafe;
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Delete "${budget.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              ctrl.deleteBudget(budget.id);
            },
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
