import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../core/enums/recurrence_type.dart';
import '../../../domain/entities/recurring_transaction_entity.dart';
import '../controllers/recurring_controller.dart';

class RecurringFormPage extends GetView<RecurringController> {
  const RecurringFormPage({super.key});

  static const _intervals = [1, 2, 3, 6, 12];

  @override
  Widget build(BuildContext context) {
    final existing = Get.arguments as RecurringTransactionEntity?;
    final isEdit = existing != null;

    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? 'Edit Recurring' : 'New Recurring')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() => Row(
                    children: [
                      TransactionType.expense,
                      TransactionType.income,
                      TransactionType.transfer,
                    ].map((t) {
                      final selected = controller.selectedType.value == t;
                      final color = t == TransactionType.expense
                          ? AppColors.expense
                          : t == TransactionType.income
                              ? AppColors.income
                              : AppColors.transfer;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectedType.value = t,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? color : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t.value[0].toUpperCase() + t.value.substring(1),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 13,
                                color: selected
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            // Wallet
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedWalletId.value,
                  items: controller.wallets
                      .map((w) => DropdownMenuItem(
                          value: w.id, child: Text(w.name)))
                      .toList(),
                  onChanged: (v) => controller.selectedWalletId.value = v,
                  decoration: const InputDecoration(
                      labelText: 'Wallet',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
                )),
            const SizedBox(height: 16),
            // To Wallet (transfer only)
            Obx(() {
              if (controller.selectedType.value != TransactionType.transfer) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: controller.selectedToWalletId.value,
                    items: controller.wallets
                        .where((w) => w.id != controller.selectedWalletId.value)
                        .map((w) => DropdownMenuItem(
                            value: w.id, child: Text(w.name)))
                        .toList(),
                    onChanged: (v) => controller.selectedToWalletId.value = v,
                    decoration: const InputDecoration(
                        labelText: 'To Wallet',
                        prefixIcon: Icon(Icons.swap_horiz)),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
            // Category
            Obx(() {
              if (controller.selectedType.value == TransactionType.transfer) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  DropdownButtonFormField<String?>(
                    value: controller.selectedCategoryId.value,
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('No category')),
                      ...controller.categories
                          .where((c) =>
                              controller.selectedType.value ==
                                      TransactionType.expense
                                  ? c.type.value == 'expense'
                                  : c.type.value == 'income')
                          .map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (v) =>
                        controller.selectedCategoryId.value = v,
                    decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined)),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
            // Recurrence
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Obx(() => DropdownButtonFormField<int>(
                        value: controller.selectedInterval.value,
                        items: _intervals
                            .map((i) => DropdownMenuItem(
                                value: i, child: Text('Every $i')))
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedInterval.value = v!,
                        decoration:
                            const InputDecoration(labelText: 'Interval'),
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Obx(() => DropdownButtonFormField<RecurrenceType>(
                        value: controller.selectedRecurrenceType.value,
                        items: RecurrenceType.values
                            .map((r) => DropdownMenuItem(
                                value: r, child: Text(r.label)))
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedRecurrenceType.value = v!,
                        decoration:
                            const InputDecoration(labelText: 'Frequency'),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Start Date
            Obx(() => InkWell(
                  onTap: () => _pickDate(context, isStart: true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child:
                        Text(_fmtDate(controller.startDate.value)),
                  ),
                )),
            const SizedBox(height: 16),
            // End Date (optional)
            Obx(() => InkWell(
                  onTap: () => _pickDate(context, isStart: false),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'End Date (optional)',
                      suffixIcon: controller.endDate.value != null
                          ? GestureDetector(
                              onTap: () => controller.endDate.value = null,
                              child: const Icon(Icons.clear))
                          : const Icon(Icons.calendar_today),
                    ),
                    child: Text(controller.endDate.value == null
                        ? 'No end date'
                        : _fmtDate(controller.endDate.value!)),
                  ),
                )),
            const SizedBox(height: 16),
            TextField(
              controller: controller.noteCtrl,
              decoration:
                  const InputDecoration(labelText: 'Note (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.save(existing),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Save' : 'Create Recurring'),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final initial = isStart
        ? controller.startDate.value
        : controller.endDate.value ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isStart
          ? DateTime.now().subtract(const Duration(days: 365))
          : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      if (isStart) {
        controller.startDate.value = picked;
      } else {
        controller.endDate.value = picked;
      }
    }
  }

  String _fmtDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}
