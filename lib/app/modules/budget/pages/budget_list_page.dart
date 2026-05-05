import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/budget_period.dart';
import '../../../core/utils/color_helper.dart';
import '../../../domain/entities/budget_entity.dart';
import '../controllers/budget_controller.dart';

class BudgetListPage extends GetView<BudgetController> {
  const BudgetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.budgets.isEmpty) {
          return _EmptyState();
        }
        return Column(
          children: [
            if (controller.alertBudgets.isNotEmpty)
              _AlertBanner(controller.alertBudgets.length),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: controller.budgets.length,
                itemBuilder: (_, i) =>
                    _BudgetCard(controller.budgets[i], controller),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.initForm();
          Get.toNamed(AppRoutes.budgetAdd);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Budget'),
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final int count;
  const _AlertBanner(this.count);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.budgetAlert.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.budgetAlert, size: 18),
          const SizedBox(width: 8),
          Text(
            '$count budget${count > 1 ? 's' : ''} reaching limit',
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.budgetAlert,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
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
          Icon(Icons.pie_chart_outline,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text('No budgets yet',
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

class _BudgetCard extends StatelessWidget {
  final BudgetEntity budget;
  final BudgetController ctrl;
  const _BudgetCard(this.budget, this.ctrl);

  @override
  Widget build(BuildContext context) {
    final spent = ctrl.spentFor(budget);
    final progress = ctrl.progressFor(budget);
    final progressColor = _progressColor(progress);
    final effectiveLimit = ctrl.effectiveLimitFor(budget);
    final rollover = ctrl.rolloverAmounts[budget.id] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
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
                      Text(budget.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            budget.period.label,
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5)),
                          ),
                          if (rollover > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '+${_fmt(rollover)} rollover',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.income.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500),
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
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Over Budget',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.expense,
                            fontWeight: FontWeight.w600)),
                  ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') {
                      ctrl.initForm(budget);
                      Get.toNamed(
                          AppRoutes.budgetEdit.replaceFirst(':id', budget.id),
                          arguments: budget);
                    } else {
                      _confirmDelete(context);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmt(spent),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: progressColor),
                ),
                Text(
                  'of ${_fmt(effectiveLimit)}',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5)),
                ),
              ],
            ),
          ],
        ),
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
