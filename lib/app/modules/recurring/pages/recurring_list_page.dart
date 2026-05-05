import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../domain/entities/recurring_transaction_entity.dart';
import '../controllers/recurring_controller.dart';

class RecurringListPage extends GetView<RecurringController> {
  const RecurringListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.recurringList.isEmpty) {
          return _EmptyState();
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            if (controller.activeList.isNotEmpty) ...[
              const _SectionHeader('Active'),
              ...controller.activeList
                  .map((r) => _RecurringTile(r, controller)),
            ],
            if (controller.inactiveList.isNotEmpty) ...[
              const _SectionHeader('Paused'),
              ...controller.inactiveList
                  .map((r) => _RecurringTile(r, controller)),
            ],
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.initForm();
          Get.toNamed(AppRoutes.recurringAdd);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Recurring'),
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
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(title,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              letterSpacing: 0.5)),
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
          Icon(Icons.repeat_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text('No recurring transactions',
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

class _RecurringTile extends StatelessWidget {
  final RecurringTransactionEntity recurring;
  final RecurringController ctrl;
  const _RecurringTile(this.recurring, this.ctrl);

  @override
  Widget build(BuildContext context) {
    final isExpense = recurring.type == TransactionType.expense;
    final isTransfer = recurring.type == TransactionType.transfer;
    final color = isTransfer
        ? AppColors.transfer
        : isExpense
            ? AppColors.expense
            : AppColors.income;
    final wallet = ctrl.walletById(recurring.walletId);
    final cat = ctrl.categoryById(recurring.categoryId);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.repeat, color: color, size: 20),
        ),
        title: Text(
          cat?.name ?? (isTransfer ? 'Transfer' : recurring.type.value),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recurring.recurrenceLabel,
                style: const TextStyle(fontSize: 12)),
            Text(wallet?.name ?? '',
                style: const TextStyle(fontSize: 11)),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isExpense ? '-' : isTransfer ? '' : '+'}${_fmt(recurring.amount)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') {
                  ctrl.initForm(recurring);
                  Get.toNamed(AppRoutes.recurringAdd, arguments: recurring);
                } else if (v == 'toggle') {
                  ctrl.toggleActive(recurring);
                } else {
                  _confirmDelete(context);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(recurring.isActive ? 'Pause' : 'Resume'),
                ),
                const PopupMenuItem(
                    value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
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
        title: const Text('Delete Recurring'),
        content: const Text('This will stop future transactions from being created automatically.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              ctrl.delete(recurring.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
