import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../domain/entities/transaction_entity.dart';

class TransactionFormPage extends GetView<TransactionController> {
  const TransactionFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final existing = Get.arguments as TransactionEntity?;
    final isEdit = existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'New Transaction'),
      ),
      body: Column(
        children: [
          // Type tabs
          Obx(() => Row(
                children: [
                  _TypeTab('Expense', 0, AppColors.expense),
                  _TypeTab('Income', 1, AppColors.income),
                  _TypeTab('Transfer', 2, AppColors.transfer),
                ],
              )),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount
                  TextField(
                    controller: controller.amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                      prefixIcon: const Icon(Icons.attach_money),
                      border: const OutlineInputBorder(),
                      labelText: 'Amount',
                    ),
                    autofocus: !isEdit,
                  ),
                  const SizedBox(height: 16),
                  // Wallet picker
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedWalletId.value,
                        items: controller.wallets
                            .map((w) => DropdownMenuItem(
                                value: w.id,
                                child: Text(
                                    '${w.name} (${w.currencyCode})')))
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedWalletId.value = v,
                        decoration: const InputDecoration(
                          labelText: 'Wallet',
                          border: OutlineInputBorder(),
                        ),
                      )),
                  const SizedBox(height: 16),
                  // To wallet (transfer only)
                  Obx(() {
                    if (controller.selectedTab.value != 2) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedToWalletId.value,
                        items: controller.wallets
                            .where((w) =>
                                w.id != controller.selectedWalletId.value)
                            .map((w) => DropdownMenuItem(
                                value: w.id,
                                child: Text(w.name)))
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedToWalletId.value = v,
                        decoration: const InputDecoration(
                          labelText: 'To Wallet',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  }),
                  // Category picker (non-transfer)
                  Obx(() {
                    if (controller.selectedTab.value == 2) {
                      return const SizedBox.shrink();
                    }
                    final isExpense = controller.selectedTab.value == 0;
                    final cats = isExpense
                        ? controller.categories
                            .where((c) =>
                                c.type.name == 'expense' ||
                                c.type.name == 'both')
                            .toList()
                        : controller.categories
                            .where((c) =>
                                c.type.name == 'income' ||
                                c.type.name == 'both')
                            .toList();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedCategoryId.value,
                        items: cats
                            .map((c) => DropdownMenuItem(
                                value: c.id, child: Text(c.name)))
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedCategoryId.value = v,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  }),
                  // Date
                  Obx(() => InkWell(
                        onTap: () => _pickDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(_formatDate(
                              controller.selectedDate.value)),
                        ),
                      )),
                  const SizedBox(height: 16),
                  // Note
                  TextField(
                    controller: controller.noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () =>
                                  controller.saveTransaction(existing),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white))
                              : Text(isEdit ? 'Save' : 'Add Transaction'),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) controller.selectedDate.value = picked;
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_month(d.month)} ${d.year}';

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}

class _TypeTab extends GetView<TransactionController> {
  final String label;
  final int index;
  final Color color;
  const _TypeTab(this.label, this.index, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final selected = controller.selectedTab.value == index;
        return GestureDetector(
          onTap: () => controller.selectedTab.value = index,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? color : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: selected ? color : Colors.grey.shade300,
                  width: selected ? 3 : 1,
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? color : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}
