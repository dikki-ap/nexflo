import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../domain/entities/category_entity.dart';

class CategoryListPage extends GetView<CategoryController> {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Categories',
              style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: GlassCard(
                borderRadius: 12,
                padding: const EdgeInsets.all(3),
                child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    gradient: AppColors.tealGradient,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark
                      ? Colors.white.withValues(alpha: 0.45)
                      : AppColors.grey500,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: const [Tab(text: 'Expense'), Tab(text: 'Income')],
                ),
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.tealMid),
            );
          }
          return TabBarView(
            children: [
              _CategoryTab(
                key: const ValueKey('expense'),
                categories: controller.expenseCategories,
                controller: controller,
                isDark: isDark,
              ),
              _CategoryTab(
                key: const ValueKey('income'),
                categories: controller.incomeCategories,
                controller: controller,
                isDark: isDark,
              ),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            controller.prepareForm();
            Get.toNamed(AppRoutes.categoryAdd);
          },
          backgroundColor: AppColors.tealMid,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Add Category',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final List<CategoryEntity> categories;
  final CategoryController controller;
  final bool isDark;

  const _CategoryTab({
    super.key,
    required this.categories,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.tealGlowSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.category_outlined,
                  color: AppColors.tealMid, size: 30),
            ),
            const SizedBox(height: 16),
            Text('No categories yet',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.grey900)),
            const SizedBox(height: 4),
            Text('Tap + to add your first category',
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : AppColors.grey500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: categories.length,
      itemBuilder: (_, i) => _CategoryCard(
        category: categories[i],
        controller: controller,
        isDark: isDark,
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final CategoryController controller;
  final bool isDark;

  const _CategoryCard({
    required this.category,
    required this.controller,
    required this.isDark,
  });

  Color get _catColor {
    final hex = category.colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderRadius: 18,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Category header row
            InkWell(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              onTap: () => _showSubcategoriesSheet(context),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(IconMapper.get(category.iconName),
                          color: _catColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    // Name + sub count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isDark ? Colors.white : AppColors.grey900,
                            ),
                          ),
                          Obx(() {
                            final subs =
                                controller.subsByCategory[category.id] ?? [];
                            return Text(
                              '${subs.length} subcategor${subs.length == 1 ? 'y' : 'ies'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.4)
                                    : AppColors.grey500,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    // Actions
                    if (!category.isDefault)
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            size: 18,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.grey400),
                        onPressed: () {
                          controller.prepareForm(category);
                          Get.toNamed(
                            AppRoutes.categoryEdit
                                .replaceFirst(':id', category.id),
                            arguments: category,
                          );
                        },
                      ),
                    if (!category.isDefault)
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(context),
                      ),
                    const Icon(Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.tealMid),
                  ],
                ),
              ),
            ),
            // Subcategory chip preview strip
            Obx(() {
              final subs = controller.subsByCategory[category.id] ?? [];
              if (subs.isEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.glassBorder
                          : AppColors.grey200,
                      width: 0.5,
                    ),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: subs.take(4).map((s) {
                    final hex = s.colorHex.replaceAll('#', '');
                    final color = Color(int.parse('FF$hex', radix: 16));
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: color.withValues(alpha: 0.3), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(IconMapper.get(s.iconName),
                              size: 12, color: color),
                          const SizedBox(width: 4),
                          Text(
                            s.name,
                            style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList()
                    ..addAll(subs.length > 4
                        ? [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tealMid.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '+${subs.length - 4} more',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.tealMid,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          ]
                        : []),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSubcategoriesSheet(BuildContext context) {
    controller.loadSubcategories(category.id);
    controller.prepareSubForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SubcategorySheet(
        category: category,
        controller: controller,
        isDark: isDark,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${category.name}"?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              controller.deleteCategory(category.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SubcategorySheet extends StatefulWidget {
  final CategoryEntity category;
  final CategoryController controller;
  final bool isDark;

  const _SubcategorySheet({
    required this.category,
    required this.controller,
    required this.isDark,
  });

  @override
  State<_SubcategorySheet> createState() => _SubcategorySheetState();
}

class _SubcategorySheetState extends State<_SubcategorySheet> {
  bool _showIconPicker = false;

  Color get _catColor {
    final hex = widget.category.colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final isDark = widget.isDark;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.glassBorder : AppColors.grey200,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                        IconMapper.get(widget.category.iconName),
                        color: _catColor,
                        size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: isDark ? Colors.white : AppColors.grey900,
                          ),
                        ),
                        Text('Subcategories',
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.4)
                                    : AppColors.grey500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Subcategory list
            Expanded(
              child: Obx(() {
                final subs = ctrl.subcategories;
                if (subs.isEmpty) {
                  return Center(
                    child: Text(
                      'No subcategories yet',
                      style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : AppColors.grey400),
                    ),
                  );
                }
                return ListView.builder(
                  controller: scrollCtrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: subs.length,
                  itemBuilder: (_, i) {
                    final s = subs[i];
                    final hex = s.colorHex.replaceAll('#', '');
                    final color = Color(int.parse('FF$hex', radix: 16));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        borderRadius: 12,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(IconMapper.get(s.iconName),
                                  color: color, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.grey900,
                                ),
                              ),
                            ),
                            if (!s.isDefault)
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 18, color: Colors.redAccent),
                                onPressed: () => ctrl.deleteSubcategory(
                                    s.id, widget.category.id),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            // Add subcategory section
            Container(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.glassBorder : AppColors.grey200,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SectionLabel(label: 'ADD SUBCATEGORY'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Icon picker button
                      Obx(() => GestureDetector(
                            onTap: () =>
                                setState(() => _showIconPicker = !_showIconPicker),
                            child: AnimatedContainer(
                              duration: AppAnimations.normal,
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _showIconPicker
                                    ? AppColors.tealMid.withValues(alpha: 0.15)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : AppColors.grey100),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _showIconPicker
                                      ? AppColors.tealMid
                                      : (isDark
                                          ? AppColors.glassBorder
                                          : AppColors.grey200),
                                  width: _showIconPicker ? 1.5 : 0.5,
                                ),
                              ),
                              child: Icon(
                                IconMapper.get(ctrl.selectedSubIcon.value),
                                color: _showIconPicker
                                    ? AppColors.tealMid
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.5)
                                        : AppColors.grey500),
                                size: 22,
                              ),
                            ),
                          )),
                      const SizedBox(width: 10),
                      // Name field
                      Expanded(
                        child: GlassCard(
                          borderRadius: 12,
                          padding: EdgeInsets.zero,
                          child: TextField(
                            controller: ctrl.subNameCtrl,
                            style: TextStyle(
                                color:
                                    isDark ? Colors.white : AppColors.grey900),
                            decoration: InputDecoration(
                              hintText: 'Subcategory name',
                              hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.35)
                                      : AppColors.grey400),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Add button
                      Obx(() => GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ctrl.addSubcategory(
                                widget.category.id,
                                ctrl.subNameCtrl.text,
                                ctrl.selectedSubIcon.value,
                              );
                              ctrl.subNameCtrl.clear();
                              ctrl.selectedSubIcon.value = 'more_horiz';
                              setState(() => _showIconPicker = false);
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppColors.tealGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 22),
                            ),
                          )),
                    ],
                  ),
                  // Icon picker grid
                  AnimatedSize(
                    duration: AppAnimations.normal,
                    curve: AppAnimations.easeOutCubic,
                    child: _showIconPicker
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _IconPickerGrid(
                              ctrl: ctrl,
                              isDark: isDark,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconPickerGrid extends StatelessWidget {
  final CategoryController ctrl;
  final bool isDark;

  const _IconPickerGrid({required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final icons = IconMapper.allIconNames;
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: icons.map((name) {
            final isSelected = ctrl.selectedSubIcon.value == name;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ctrl.selectedSubIcon.value = name;
              },
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.tealMid.withValues(alpha: 0.2)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.grey100),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.tealMid : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  IconMapper.get(name),
                  size: 18,
                  color: isSelected
                      ? AppColors.tealMid
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
