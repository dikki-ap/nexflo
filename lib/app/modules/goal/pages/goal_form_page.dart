import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../domain/entities/goal_entity.dart';
import '../controllers/goal_controller.dart';

class GoalFormPage extends GetView<GoalController> {
  const GoalFormPage({super.key});

  static const _icons = [
    'savings', 'home', 'flight', 'directions_car', 'school',
    'laptop', 'phone_android', 'favorite', 'card_travel', 'beach_access',
  ];

  static const _colors = [
    AppColors.teal, AppColors.blue, AppColors.purple,
    AppColors.green, AppColors.orange, AppColors.pink,
    Color(0xFF795548), Color(0xFF607D8B), Color(0xFFFF5722),
  ];

  @override
  Widget build(BuildContext context) {
    final existing = Get.arguments as GoalEntity?;
    final isEdit = existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Goal' : 'New Goal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.nameCtrl,
              decoration: const InputDecoration(labelText: 'Goal Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.targetCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Icon',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _icons.map((iconName) {
                    final selected =
                        controller.selectedIcon.value == iconName;
                    return GestureDetector(
                      onTap: () =>
                          controller.selectedIcon.value = iconName,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(IconMapper.get(iconName),
                            size: 22,
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : null),
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 20),
            const Text('Color',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colors.map((c) {
                    final selected = controller.selectedColor.value == c;
                    return GestureDetector(
                      onTap: () => controller.selectedColor.value = c,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                  width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 20),
            // Deadline
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
                        : () => controller.saveGoal(existing),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Save' : 'Create Goal'),
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
