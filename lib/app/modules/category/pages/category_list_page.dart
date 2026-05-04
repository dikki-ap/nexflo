import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../widgets/category_tile.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/enums/category_type.dart';

class CategoryListPage extends GetView<CategoryController> {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                controller.prepareForm();
                Get.toNamed(AppRoutes.categoryAdd);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            children: [
              _CategoryTab(
                categories: controller.expenseCategories,
                controller: controller,
              ),
              _CategoryTab(
                categories: controller.incomeCategories,
                controller: controller,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final List categories;
  final CategoryController controller;
  const _CategoryTab(
      {required this.categories, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Center(
        child: Text('No categories',
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4))),
      );
    }
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final cat = categories[i];
        return CategoryTile(
          category: cat,
          onTap: () => _showSubcategories(context, cat),
          onEdit: () {
            controller.prepareForm(cat);
            Get.toNamed(
              AppRoutes.categoryEdit.replaceFirst(':id', cat.id),
              arguments: cat,
            );
          },
          onDelete: cat.isDefault
              ? null
              : () => _confirmDelete(context, cat.id, cat.name),
        );
      },
    );
  }

  void _showSubcategories(BuildContext context, dynamic cat) {
    controller.loadSubcategories(cat.id);
    final subNameCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${cat.name} — Subcategories',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() => Column(
                  children: controller.subcategories.map((s) {
                    return ListTile(
                      dense: true,
                      title: Text(s.name),
                      trailing: s.isDefault
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: Colors.red),
                              onPressed: () =>
                                  controller.deleteSubcategory(s.id, cat.id),
                            ),
                    );
                  }).toList(),
                )),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: subNameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'New subcategory name',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    controller.addSubcategory(cat.id, subNameCtrl.text);
                    subNameCtrl.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              controller.deleteCategory(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
