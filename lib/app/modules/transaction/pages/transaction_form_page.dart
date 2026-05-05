import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../services/ocr_service.dart';

class TransactionFormPage extends GetView<TransactionController> {
  const TransactionFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final existing = Get.arguments as TransactionEntity?;
    final isEdit = existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'New Transaction'),
        actions: [
          if (!isEdit)
            IconButton(
              icon: const Icon(Icons.document_scanner_outlined),
              tooltip: 'Scan Receipt',
              onPressed: () async {
                final result = await Get.toNamed(AppRoutes.receiptScan);
                if (result is OcrParseResult) {
                  controller.prefillFromReceipt(result);
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _TypeSelector(context),
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
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                      prefixIcon: Icon(Icons.attach_money),
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

  Widget _TypeSelector(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _PillTab('Expense', 0, AppColors.expense),
          _PillTab('Income', 1, AppColors.income),
          _PillTab('Transfer', 2, AppColors.transfer),
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

class _PillTab extends GetView<TransactionController> {
  final String label;
  final int index;
  final Color color;
  const _PillTab(this.label, this.index, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final selected = controller.selectedTab.value == index;
        return GestureDetector(
          onTap: () => controller.selectedTab.value = index,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
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
        );
      }),
    );
  }
}
