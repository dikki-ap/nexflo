import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/debt_type.dart';
import '../../../domain/entities/debt_entity.dart';
import '../controllers/debt_controller.dart';

class DebtFormPage extends GetView<DebtController> {
  const DebtFormPage({super.key});

  static const _currencies = [
    'IDR', 'USD', 'EUR', 'SGD', 'MYR', 'JPY', 'GBP', 'AUD',
  ];

  @override
  Widget build(BuildContext context) {
    final existing = Get.arguments as DebtEntity?;
    final isEdit = existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Debt' : 'New Debt')),
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
                    children: DebtType.values.map((t) {
                      final selected = controller.selectedType.value == t;
                      final color = t == DebtType.iOwe
                          ? AppColors.expense
                          : AppColors.income;
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
                              t.label,
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
              controller: controller.personNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Person Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: controller.amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedCurrency.value,
                        items: _currencies
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedCurrency.value = v!,
                        decoration:
                            const InputDecoration(labelText: 'Currency'),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => InkWell(
                  onTap: () => _pickDeadline(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Deadline (optional)',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      controller.selectedDeadline.value == null
                          ? 'No deadline'
                          : _fmtDate(controller.selectedDeadline.value!),
                    ),
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
                        : () => controller.saveDebt(existing),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Save' : 'Record Debt'),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDeadline.value ??
          DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) controller.selectedDeadline.value = picked;
  }

  String _fmtDate(DateTime d) =>
      '${d.day} ${_month(d.month)} ${d.year}';

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}
