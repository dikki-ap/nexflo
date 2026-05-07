import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/budget_period.dart';
import '../../../domain/entities/budget_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/wallet_entity.dart';
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
            Obx(() => DropdownButtonFormField<BudgetPeriod>(
                  value: controller.selectedPeriod.value,
                  items: BudgetPeriod.values
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                      .toList(),
                  onChanged: (v) => controller.selectedPeriod.value = v!,
                  decoration: const InputDecoration(labelText: 'Period'),
                )),
            const SizedBox(height: 16),
            Obx(() => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('All Categories'),
                  subtitle:
                      const Text('Track spending across all categories'),
                  value: controller.isAllCategories.value,
                  onChanged: (v) => controller.isAllCategories.value = v,
                )),
            Obx(() {
              if (controller.isAllCategories.value) {
                return const SizedBox.shrink();
              }
              return _MultiSelectField(
                label: 'Categories',
                hint: 'Tap to select categories',
                selectedIds: controller.selectedCategoryIds,
                items: controller.categories
                    .where((c) => c.type.name != 'income')
                    .map((c) => _SelectItem(c.id, c.name, _categoryIcon(c)))
                    .toList(),
                onTap: () => _showMultiSelectSheet(
                  context,
                  title: 'Select Categories',
                  items: controller.categories
                      .where((c) => c.type.name != 'income')
                      .map((c) => _SelectItem(c.id, c.name, _categoryIcon(c)))
                      .toList(),
                  selectedIds: controller.selectedCategoryIds,
                ),
              );
            }),
            const SizedBox(height: 12),
            Obx(() => _MultiSelectField(
                  label: 'Wallets',
                  hint: 'All wallets (tap to restrict)',
                  selectedIds: controller.selectedWalletIds,
                  items: controller.wallets
                      .map((w) => _SelectItem(w.id, w.name, _walletIcon(w)))
                      .toList(),
                  onTap: () => _showMultiSelectSheet(
                    context,
                    title: 'Select Wallets',
                    items: controller.wallets
                        .map((w) => _SelectItem(w.id, w.name, _walletIcon(w)))
                        .toList(),
                    selectedIds: controller.selectedWalletIds,
                  ),
                )),
            const SizedBox(height: 16),
            Obx(() => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Rollover'),
                  subtitle: const Text('Carry unused budget to next period'),
                  value: controller.rollover.value,
                  onChanged: (v) => controller.rollover.value = v,
                )),
            const SizedBox(height: 8),
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alert at ${controller.alertAtPercent.value}%',
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

  void _showMultiSelectSheet(
    BuildContext context, {
    required String title,
    required List<_SelectItem> items,
    required RxList<String> selectedIds,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MultiSelectSheet(
        title: title,
        items: items,
        selectedIds: selectedIds,
      ),
    );
  }

  IconData _categoryIcon(CategoryEntity c) => Icons.label_outline_rounded;
  IconData _walletIcon(WalletEntity w) => Icons.account_balance_wallet_outlined;
}

class _SelectItem {
  final String id;
  final String name;
  final IconData icon;
  const _SelectItem(this.id, this.name, this.icon);
}

class _MultiSelectField extends StatelessWidget {
  final String label;
  final String hint;
  final RxList<String> selectedIds;
  final List<_SelectItem> items;
  final VoidCallback onTap;

  const _MultiSelectField({
    required this.label,
    required this.hint,
    required this.selectedIds,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final selected = items.where((i) => selectedIds.contains(i.id)).toList();
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.expand_more_rounded),
          ),
          child: selected.isEmpty
              ? Text(hint,
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 14))
              : Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: selected
                      .map((i) => Chip(
                            label: Text(i.name,
                                style: const TextStyle(fontSize: 12)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => selectedIds.remove(i.id),
                          ))
                      .toList(),
                ),
        ),
      );
    });
  }
}

class _MultiSelectSheet extends StatelessWidget {
  final String title;
  final List<_SelectItem> items;
  final RxList<String> selectedIds;

  const _MultiSelectSheet({
    required this.title,
    required this.items,
    required this.selectedIds,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: scrollCtrl,
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    final isSelected = selectedIds.contains(item.id);
                    return CheckboxListTile(
                      secondary: Icon(item.icon, size: 20),
                      title: Text(item.name),
                      value: isSelected,
                      onChanged: (_) {
                        if (isSelected) {
                          selectedIds.remove(item.id);
                        } else {
                          selectedIds.add(item.id);
                        }
                      },
                      controlAffinity: ListTileControlAffinity.trailing,
                      dense: true,
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}
