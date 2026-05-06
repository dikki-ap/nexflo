import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/enums/category_type.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/nexflo_button.dart';
import '../../../core/widgets/section_label.dart';
import '../../../domain/entities/category_entity.dart';

class CategoryFormPage extends GetView<CategoryController> {
  const CategoryFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final existing = Get.arguments as CategoryEntity?;
    final isEdit = existing != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = MediaQuery.of(context).size.width < 360 ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isEdit ? 'Edit Category' : 'New Category',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name section
            SectionLabel(label: 'NAME'),
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 16,
              padding: EdgeInsets.zero,
              child: TextField(
                controller: controller.nameCtrl,
                textCapitalization: TextCapitalization.words,
                style:
                    TextStyle(color: isDark ? Colors.white : AppColors.grey900),
                decoration: InputDecoration(
                  hintText: 'Category name',
                  hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.35)
                          : AppColors.grey400),
                  prefixIcon: const Icon(Icons.label_outline_rounded,
                      color: AppColors.tealMid),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Type section
            SectionLabel(label: 'TYPE'),
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(4),
              child: Obx(() => Row(
                    children: CategoryType.values
                        .where((t) => t != CategoryType.both)
                        .map((t) => Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  controller.selectedType.value = t;
                                },
                                child: AnimatedContainer(
                                  duration: AppAnimations.normal,
                                  curve: AppAnimations.easeOutCubic,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 11),
                                  decoration: BoxDecoration(
                                    color: controller.selectedType.value == t
                                        ? AppColors.tealMid
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    t.name[0].toUpperCase() +
                                        t.name.substring(1),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: controller.selectedType.value == t
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.45)
                                              : AppColors.grey500),
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  )),
            ),
            const SizedBox(height: 20),

            // Icon preview + color preview row
            Obx(() {
              final color = controller.selectedColor.value;
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionLabel(label: 'ICON'),
                        const SizedBox(height: 8),
                        GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                IconMapper.get(
                                    controller.selectedIcon.value),
                                color: color,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionLabel(label: 'COLOR'),
                        const SizedBox(height: 8),
                        GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),

            // Color grid
            SectionLabel(label: 'PICK COLOR'),
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: _ColorGrid(ctrl: controller, isDark: isDark),
            ),
            const SizedBox(height: 20),

            // Icon grid
            SectionLabel(label: 'PICK ICON'),
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: _IconGrid(ctrl: controller, isDark: isDark),
            ),
            const SizedBox(height: 28),

            Obx(() => NexFloButton(
                  label: isEdit ? 'Save Changes' : 'Create Category',
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.saveCategory(existing),
                  isLoading: controller.isLoading.value,
                  icon: isEdit ? Icons.check_rounded : Icons.add_rounded,
                  width: double.infinity,
                )),
          ],
        ),
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  final CategoryController ctrl;
  final bool isDark;

  const _ColorGrid({required this.ctrl, required this.isDark});

  static const _colors = [
    Color(0xFFFF5722), Color(0xFF2196F3), Color(0xFFE91E63),
    Color(0xFF795548), Color(0xFFF44336), Color(0xFF9C27B0),
    Color(0xFF3F51B5), Color(0xFFFF9800), AppColors.teal,
    Color(0xFF607D8B), Color(0xFF009688), Color(0xFF9E9E9E),
    AppColors.green, Color(0xFF8BC34A), Color(0xFFFFC107),
    Color(0xFF00BCD4), Color(0xFF4CAF50), Color(0xFF1E88E5),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _colors.map((c) {
            final isSelected = ctrl.selectedColor.value == c;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ctrl.selectedColor.value = c;
              },
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: isDark ? Colors.white : AppColors.grey900,
                          width: 2.5)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: c.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18)
                    : null,
              ),
            );
          }).toList(),
        ));
  }
}

class _IconGrid extends StatelessWidget {
  final CategoryController ctrl;
  final bool isDark;

  const _IconGrid({required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final icons = IconMapper.allIconNames;
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: icons.map((name) {
            final isSelected = ctrl.selectedIcon.value == name;
            final color = ctrl.selectedColor.value;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ctrl.selectedIcon.value = name;
              },
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.grey100),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  IconMapper.get(name),
                  size: 22,
                  color: isSelected
                      ? color
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppColors.grey600),
                ),
              ),
            );
          }).toList(),
        ));
  }
}
