import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/category_type.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../domain/entities/category_entity.dart';

class CategoryFormPage extends GetView<CategoryController> {
  const CategoryFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final existing = Get.arguments as CategoryEntity?;
    final isEdit = existing != null;

    return Scaffold(
      appBar:
          AppBar(title: Text(isEdit ? 'Edit Category' : 'New Category')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<CategoryType>(
                  value: controller.selectedType.value,
                  items: CategoryType.values
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t.name)))
                      .toList(),
                  onChanged: (v) =>
                      controller.selectedType.value = v!,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                )),
            const SizedBox(height: 16),
            _ColorPicker(controller),
            const SizedBox(height: 16),
            _IconPicker(controller),
            const SizedBox(height: 28),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.saveCategory(existing),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Save' : 'Create'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final CategoryController ctrl;
  const _ColorPicker(this.ctrl);

  static const _colors = [
    Color(0xFFFF5722), Color(0xFF2196F3), Color(0xFFE91E63),
    Color(0xFF795548), Color(0xFFF44336), Color(0xFF9C27B0),
    Color(0xFF3F51B5), Color(0xFFFF9800), AppColors.teal,
    Color(0xFF607D8B), Color(0xFF009688), Color(0xFF9E9E9E),
    AppColors.green, Color(0xFF8BC34A), Color(0xFFFFC107),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color',
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6))),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 10,
              runSpacing: 8,
              children: _colors
                  .map((c) => GestureDetector(
                        onTap: () => ctrl.selectedColor.value = c,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: ctrl.selectedColor.value == c
                                ? Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    width: 3)
                                : null,
                          ),
                        ),
                      ))
                  .toList(),
            )),
      ],
    );
  }
}

class _IconPicker extends StatelessWidget {
  final CategoryController ctrl;
  const _IconPicker(this.ctrl);

  static const _icons = [
    'restaurant', 'directions_car', 'shopping_bag', 'home',
    'favorite', 'movie', 'school', 'spa', 'flight',
    'receipt_long', 'repeat', 'more_horiz', 'work', 'laptop',
    'trending_up', 'card_giftcard', 'star', 'swap_horiz',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Icon',
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6))),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _icons
                  .map((name) => GestureDetector(
                        onTap: () => ctrl.selectedIcon.value = name,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: ctrl.selectedIcon.value == name
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(IconMapper.get(name), size: 22),
                        ),
                      ))
                  .toList(),
            )),
      ],
    );
  }
}
