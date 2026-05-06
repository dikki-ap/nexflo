import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/category_type.dart';
import '../../../data/datasources/local/category_local_ds.dart';
import '../../../data/datasources/local/subcategory_local_ds.dart';
import '../../../data/repositories/category_repository_impl.dart';
import '../../../data/repositories/subcategory_repository_impl.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/subcategory_entity.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../domain/usecases/category/create_category_usecase.dart';
import '../../../domain/usecases/category/update_category_usecase.dart';
import '../../../domain/usecases/category/delete_category_usecase.dart';
import '../../../domain/usecases/subcategory/get_subcategories_usecase.dart';
import '../../../domain/usecases/subcategory/create_subcategory_usecase.dart';
import '../../../domain/usecases/subcategory/delete_subcategory_usecase.dart';
import '../../../services/auth_service.dart';

class CategoryController extends GetxController {
  final categories = <CategoryEntity>[].obs;
  final subcategories = <SubcategoryEntity>[].obs;
  final subsByCategory = RxMap<String, List<SubcategoryEntity>>();
  final isLoading = false.obs;

  // Category form
  final nameCtrl = TextEditingController();
  final selectedType = CategoryType.expense.obs;
  final selectedColor = AppColors.teal.obs;
  final selectedIcon = 'more_horiz'.obs;

  // Subcategory form
  final subNameCtrl = TextEditingController();
  final selectedSubIcon = 'more_horiz'.obs;

  late final GetCategoriesUseCase _getCategories;
  late final CreateCategoryUseCase _createCategory;
  late final UpdateCategoryUseCase _updateCategory;
  late final DeleteCategoryUseCase _deleteCategory;
  late final GetSubcategoriesUseCase _getSubcategories;
  late final CreateSubcategoryUseCase _createSubcategory;
  late final DeleteSubcategoryUseCase _deleteSubcategory;

  String get _userId => Get.find<AuthService>().currentUser?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    final db = Get.find<AppDatabase>();
    final catDs = CategoryLocalDataSource(db);
    final catRepo = CategoryRepositoryImpl(catDs);
    final subDs = SubcategoryLocalDataSource(db);
    final subRepo = SubcategoryRepositoryImpl(subDs);

    _getCategories = GetCategoriesUseCase(catRepo);
    _createCategory = CreateCategoryUseCase(catRepo);
    _updateCategory = UpdateCategoryUseCase(catRepo);
    _deleteCategory = DeleteCategoryUseCase(catRepo);
    _getSubcategories = GetSubcategoriesUseCase(subRepo);
    _createSubcategory = CreateSubcategoryUseCase(subRepo);
    _deleteSubcategory = DeleteSubcategoryUseCase(subRepo);

    loadCategories();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    subNameCtrl.dispose();
    super.onClose();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    final result = await _getCategories(GetCategoriesParams(_userId));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (list) => categories.value = list,
    );
    isLoading.value = false;
    await _loadAllSubcategories();
  }

  Future<void> _loadAllSubcategories() async {
    for (final cat in categories) {
      final r = await _getSubcategories(GetSubcategoriesParams(cat.id));
      r.fold((_) {}, (list) {
        subsByCategory[cat.id] = list as List<SubcategoryEntity>;
      });
    }
  }

  Future<void> loadSubcategories(String categoryId) async {
    final result = await _getSubcategories(GetSubcategoriesParams(categoryId));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (list) {
        subcategories.value = list as List<SubcategoryEntity>;
        subsByCategory[categoryId] = list;
      },
    );
  }

  void prepareForm([CategoryEntity? existing]) {
    if (existing != null) {
      nameCtrl.text = existing.name;
      selectedType.value = existing.type;
      selectedColor.value = _colorFromHex(existing.colorHex);
      selectedIcon.value = existing.iconName;
    } else {
      nameCtrl.clear();
      selectedType.value = CategoryType.expense;
      selectedColor.value = AppColors.teal;
      selectedIcon.value = 'more_horiz';
    }
  }

  void prepareSubForm() {
    subNameCtrl.clear();
    selectedSubIcon.value = 'more_horiz';
  }

  Future<void> saveCategory([CategoryEntity? existing]) async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Validation', 'Category name is required');
      return;
    }
    isLoading.value = true;

    if (existing == null) {
      final result = await _createCategory(CreateCategoryParams(
        userId: _userId,
        name: name,
        type: selectedType.value.value,
        iconName: selectedIcon.value,
        colorHex: _hexFromColor(selectedColor.value),
      ));
      result.fold((f) => Get.snackbar('Error', f.message), (_) {});
    } else {
      final updated = _CategoryCopy(
        id: existing.id,
        userId: existing.userId,
        name: name,
        type: selectedType.value,
        iconName: selectedIcon.value,
        colorHex: _hexFromColor(selectedColor.value),
        isDefault: existing.isDefault,
        sortOrder: existing.sortOrder,
        isArchived: existing.isArchived,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: existing.deletedAt,
        syncStatus: 'pending',
      );
      final result = await _updateCategory(updated);
      result.fold((f) => Get.snackbar('Error', f.message), (_) {});
    }

    isLoading.value = false;
    await loadCategories();
    Get.back();
  }

  Future<void> deleteCategory(String id) async {
    final result = await _deleteCategory(DeleteCategoryParams(id));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (_) => categories.removeWhere((c) => c.id == id),
    );
  }

  Future<void> addSubcategory(
      String categoryId, String name, String iconName) async {
    if (name.trim().isEmpty) return;
    final cat = categories.firstWhereOrNull((c) => c.id == categoryId);
    final result = await _createSubcategory(CreateSubcategoryParams(
      userId: _userId,
      categoryId: categoryId,
      name: name.trim(),
      iconName: iconName,
      colorHex: cat?.colorHex ?? '#9E9E9E',
    ));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (_) => loadSubcategories(categoryId),
    );
  }

  Future<void> deleteSubcategory(String id, String categoryId) async {
    final result = await _deleteSubcategory(DeleteSubcategoryParams(id));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (_) => loadSubcategories(categoryId),
    );
  }

  String _hexFromColor(Color c) =>
      '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  Color _colorFromHex(String hex) {
    final s = hex.replaceAll('#', '');
    return Color(int.parse('FF$s', radix: 16));
  }

  List<CategoryEntity> get expenseCategories =>
      categories
          .where((c) =>
              (c.type == CategoryType.expense || c.type == CategoryType.both) &&
              !c.isArchived)
          .toList();

  List<CategoryEntity> get incomeCategories =>
      categories
          .where((c) =>
              (c.type == CategoryType.income || c.type == CategoryType.both) &&
              !c.isArchived)
          .toList();
}

class _CategoryCopy extends CategoryEntity {
  const _CategoryCopy({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.iconName,
    required super.colorHex,
    required super.isDefault,
    required super.sortOrder,
    required super.isArchived,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required super.syncStatus,
  });
}
