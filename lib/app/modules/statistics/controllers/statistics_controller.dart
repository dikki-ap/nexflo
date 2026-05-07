import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/enums/filter_period.dart';
import '../../../core/utils/color_helper.dart';
import '../../../data/database/app_database.dart';
import '../../../data/datasources/local/statistics_local_ds.dart';
import '../../../data/datasources/local/transaction_local_ds.dart';
import '../../../data/datasources/local/category_local_ds.dart';
import '../../../data/datasources/local/subcategory_local_ds.dart';
import '../../../data/repositories/category_repository_impl.dart';
import '../../../data/repositories/subcategory_repository_impl.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/subcategory_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../domain/usecases/subcategory/get_subcategories_usecase.dart';
import '../../../services/auth_service.dart';

class CategoryAmount {
  final CategoryEntity? category;
  final double amount;
  CategoryAmount(this.category, this.amount);
}

class SubcategoryAmount {
  final SubcategoryEntity? subcategory;
  final double amount;
  final double percentage;
  SubcategoryAmount({
    required this.subcategory,
    required this.amount,
    required this.percentage,
  });
}

class StatisticsController extends GetxController {
  final selectedPeriod = FilterPeriod.thisMonth.obs;
  final isLoading = false.obs;

  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final monthlyData = <MonthlyData>[].obs;
  final topCategories = <CategoryAmount>[].obs;
  final allTransactions = <TransactionEntity>[].obs;

  final categories = <CategoryEntity>[].obs;

  late final StatisticsLocalDataSource _statsDs;
  late final TransactionLocalDataSource _txDs;
  late final GetCategoriesUseCase _getCategories;
  late final GetSubcategoriesUseCase _getSubcategories;

  String get _userId => Get.find<AuthService>().currentUser?.id ?? '';

  double get cashflow => totalIncome.value - totalExpense.value;
  double get savingsRate =>
      totalIncome.value > 0 ? cashflow / totalIncome.value * 100 : 0;

  static const _periods = [
    FilterPeriod.thisMonth,
    FilterPeriod.threeMonths,
    FilterPeriod.sixMonths,
    FilterPeriod.oneYear,
  ];
  List<FilterPeriod> get filterPeriods => _periods;

  @override
  void onInit() {
    super.onInit();
    final db = Get.find<AppDatabase>();
    _statsDs = StatisticsLocalDataSource(db);
    _txDs = TransactionLocalDataSource(db);
    _getCategories =
        GetCategoriesUseCase(CategoryRepositoryImpl(CategoryLocalDataSource(db)));
    _getSubcategories =
        GetSubcategoriesUseCase(SubcategoryRepositoryImpl(SubcategoryLocalDataSource(db)));
    loadAll();
  }

  void changePeriod(FilterPeriod p) {
    selectedPeriod.value = p;
    loadAll();
  }

  (DateTime, DateTime) get _range {
    final now = DateTime.now();
    return switch (selectedPeriod.value) {
      FilterPeriod.thisMonth =>
        (DateTime(now.year, now.month, 1), now),
      FilterPeriod.threeMonths =>
        (DateTime(now.year, now.month - 2, 1), now),
      FilterPeriod.sixMonths =>
        (DateTime(now.year, now.month - 5, 1), now),
      FilterPeriod.oneYear =>
        (DateTime(now.year - 1, now.month, 1), now),
      _ => (DateTime(now.year, now.month, 1), now),
    };
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    final uid = _userId;
    final (start, end) = _range;

    await Future.wait([
      _loadSummary(uid, start, end),
      _loadMonthly(uid, start, end),
      _loadCategories(uid),
      _loadTransactions(uid, start, end),
    ]);
    _buildTopCategories();
    isLoading.value = false;
  }

  Future<void> _loadSummary(String uid, DateTime start, DateTime end) async {
    final s = await _statsDs.getSummary(userId: uid, start: start, end: end);
    totalIncome.value = s['income'] ?? 0;
    totalExpense.value = s['expense'] ?? 0;
  }

  Future<void> _loadMonthly(String uid, DateTime start, DateTime end) async {
    monthlyData.value = await _statsDs.getMonthlyBreakdown(
        userId: uid, start: start, end: end);
  }

  Future<void> _loadCategories(String uid) async {
    final r = await _getCategories(GetCategoriesParams(uid));
    r.fold((_) {}, (list) => categories.value = list);
  }

  Future<void> _loadTransactions(
      String uid, DateTime start, DateTime end) async {
    final rows = await _txDs.getByFilter(
      userId: uid,
      period: selectedPeriod.value,
      customStart: start,
      customEnd: end,
    );
    allTransactions.value = rows;
  }

  void _buildTopCategories() async {
    final uid = _userId;
    final (start, end) = _range;
    final byCategory = await _statsDs.getExpenseByCategory(
        userId: uid, start: start, end: end);

    final catMap = {for (final c in categories) c.id: c};
    final list = byCategory.entries
        .map((e) => CategoryAmount(catMap[e.key], e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    topCategories.value = list.take(5).toList();
  }

  Color categoryColor(CategoryAmount ca) {
    if (ca.category == null) return Colors.grey;
    return ColorHelper.fromHex(ca.category!.colorHex);
  }

  Future<List<SubcategoryAmount>> getSubcategoryBreakdown(
      String categoryId) async {
    final (start, end) = _range;
    final bySubcat = await _statsDs.getExpenseBySubcategory(
      userId: _userId,
      categoryId: categoryId,
      start: start,
      end: end,
    );

    final subsResult = await _getSubcategories(GetSubcategoriesParams(categoryId));
    final subsMap = <String, SubcategoryEntity>{};
    subsResult.fold((_) {}, (list) {
      for (final s in list as List<SubcategoryEntity>) {
        subsMap[s.id] = s;
      }
    });

    final total = bySubcat.values.fold(0.0, (a, b) => a + b);
    final result = bySubcat.entries.map((e) {
      final sub = e.key == '__none__' ? null : subsMap[e.key];
      return SubcategoryAmount(
        subcategory: sub,
        amount: e.value,
        percentage: total > 0 ? e.value / total * 100 : 0,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  List<TransactionEntity> getTransactionsByCategory(String categoryId) {
    return allTransactions
        .where((t) => t.categoryId == categoryId && t.type.value == 'expense')
        .toList();
  }

  Future<String?> exportCsv() async {
    try {
      final rows = allTransactions;
      if (rows.isEmpty) return null;

      final catMap = {for (final c in categories) c.id: c.name};
      final buffer = StringBuffer();
      buffer.writeln('Date,Type,Amount,Category,Note');
      for (final tx in rows) {
        final date =
            '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}';
        final type = tx.type.value;
        final cat = catMap[tx.categoryId] ?? '';
        final note = (tx.note ?? '').replaceAll(',', ';');
        buffer.writeln('$date,$type,${tx.amount},$cat,$note');
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/nexflo_export_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buffer.toString());
      return file.path;
    } catch (_) {
      return null;
    }
  }
}
