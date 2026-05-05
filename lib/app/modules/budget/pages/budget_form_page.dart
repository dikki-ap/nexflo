import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/budget_period.dart';
import '../../../domain/entities/budget_entity.dart';
import '../controllers/budget_controller.dart';

class BudgetFormPage extends GetView<BudgetController> {
  const BudgetFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final existing = Get.arguments as BudgetEntity?;
    final isEdit = existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Budget' : 'New Budget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.nameCtrl,
              decoration: const InputDecoration(labelText: 'Budget Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Limit Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            // Period
            Obx(() => DropdownButtonFormField<BudgetPeriod>(
                  value: controller.selectedPeriod.value,
                  items: BudgetPeriod.values
                      .map((p) => DropdownMenuItem(
                          value: p, child: Text(p.label)))
                      .toList(),
                  onChanged: (v) =>
                      controller.selectedPeriod.value = v!,
                  decoration: const InputDecoration(labelText: 'Period'),
                )),
            const SizedBox(height: 16),
            // All categories toggle
            Obx(() => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('All Categories'),
                  subtitle: const Text(
                      'Track total spending across all categories'),
                  value: controller.isAllCategories.value,
                  onChanged: (v) => controller.isAllCategories.value = v,
                )),
            // Category picker (when not all)
            Obx(() {
              if (controller.isAllCategories.value) {
                return const SizedBox.shrink();
              }
              final cats = controller.categories
                  .where((c) => c.type.name != 'income')
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
                  decoration:
                      const InputDecoration(labelText: 'Category'),
                ),
              );
            }),
            // Wallet picker
            Obx(() => DropdownButtonFormField<String?>(
                  value: controller.selectedWalletId.value,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All Wallets')),
                    ...controller.wallets.map((w) => DropdownMenuItem(
                        value: w.id, child: Text(w.name))),
                  ],
                  onChanged: (v) =>
                      controller.selectedWalletId.value = v,
                  decoration:
                      const InputDecoration(labelText: 'Wallet'),
                )),
            const SizedBox(height: 16),
            Obx(() => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Rollover'),
                  subtitle: const Text(
                      'Carry unused budget to next period'),
                  value: controller.rollover.value,
                  onChanged: (v) => controller.rollover.value = v,
                )),
            const SizedBox(height: 8),
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Alert at ${controller.alertAtPercent.value}%',
                        style: const TextStyle(fontSize: 13)),
                    Slider(
                      value: controller.alertAtPercent.value.toDouble(),
                      min: 50,
                      max: 100,
                      divisions: 10,
                      label: '${controller.alertAtPercent.value}%',
                      onChanged: (v) =>
                          controller.alertAtPercent.value = v.toInt(),
                    ),
                  ],
                )),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.saveBudget(existing),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Save' : 'Create Budget'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
