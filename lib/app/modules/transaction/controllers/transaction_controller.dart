import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/filter_period.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../data/datasources/local/transaction_local_ds.dart';
import '../../../data/datasources/local/wallet_local_ds.dart';
import '../../../data/datasources/local/category_local_ds.dart';
import '../../../data/repositories/transaction_repository_impl.dart';
import '../../../data/repositories/wallet_repository_impl.dart';
import '../../../data/repositories/category_repository_impl.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/wallet_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/usecases/transaction/get_transactions_usecase.dart';
import '../../../domain/usecases/transaction/create_transaction_usecase.dart';
import '../../../domain/usecases/transaction/update_transaction_usecase.dart';
import '../../../domain/usecases/transaction/delete_transaction_usecase.dart';
import '../../../domain/usecases/transaction/get_transaction_summary_usecase.dart';
import '../../../domain/usecases/wallet/get_all_wallets_usecase.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../services/auth_service.dart';

class TransactionController extends GetxController {
  final transactions = <TransactionEntity>[].obs;
  final wallets = <WalletEntity>[].obs;
  final categories = <CategoryEntity>[].obs;
  final isLoading = false.obs;

  // Filters
  final selectedPeriod = FilterPeriod.thisMonth.obs;
  final filterWalletId = Rxn<String>();
  final filterCategoryId = Rxn<String>();
  final filterType = Rxn<TransactionType>();
  final searchQuery = ''.obs;

  // Form fields
  final selectedTab = 0.obs; // 0=expense 1=income 2=transfer
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final selectedWalletId = Rxn<String>();
  final selectedToWalletId = Rxn<String>();
  final selectedCategoryId = Rxn<String>();
  final selectedDate = DateTime.now().obs;

  // Summary
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;

  late final GetTransactionsUseCase _getTransactions;
  late final CreateTransactionUseCase _create;
  late final UpdateTransactionUseCase _update;
  late final DeleteTransactionUseCase _delete;
  late final GetTransactionSummaryUseCase _getSummary;
  late final GetAllWalletsUseCase _getWallets;
  late final GetCategoriesUseCase _getCategories;

  String get _userId => Get.find<AuthService>().currentUser!.id;

  @override
  void onInit() {
    super.onInit();
    final db = Get.find<AppDatabase>();

    final txDs = TransactionLocalDataSource(db);
    final txRepo = TransactionRepositoryImpl(txDs);
    final walletDs = WalletLocalDataSource(db);
    final walletRepo = WalletRepositoryImpl(walletDs);
    final catDs = CategoryLocalDataSource(db);
    final catRepo = CategoryRepositoryImpl(catDs);

    _getTransactions = GetTransactionsUseCase(txRepo);
    _create = CreateTransactionUseCase(txRepo);
    _update = UpdateTransactionUseCase(txRepo);
    _delete = DeleteTransactionUseCase(txRepo);
    _getSummary = GetTransactionSummaryUseCase(txRepo);
    _getWallets = GetAllWalletsUseCase(walletRepo);
    _getCategories = GetCategoriesUseCase(catRepo);

    _loadWallets();
    _loadCategories();
    loadTransactions();
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadWallets() async {
    final r = await _getWallets(GetAllWalletsParams(_userId));
    r.fold((_) {}, (list) {
      wallets.value = list;
      if (list.isNotEmpty && selectedWalletId.value == null) {
        selectedWalletId.value = list.first.id;
      }
    });
  }

  Future<void> _loadCategories() async {
    final r = await _getCategories(GetCategoriesParams(_userId));
    r.fold((_) {}, (list) => categories.value = list);
  }

  Future<void> loadTransactions() async {
    isLoading.value = true;
    final r = await _getTransactions(GetTransactionsParams(
      userId: _userId,
      period: selectedPeriod.value,
      walletId: filterWalletId.value,
      categoryId: filterCategoryId.value,
      type: filterType.value,
      searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
    ));
    r.fold(
      (f) => Get.snackbar('Error', f.message),
      (list) => transactions.value = list,
    );

    final s = await _getSummary(GetSummaryParams(
      userId: _userId,
      period: selectedPeriod.value,
    ));
    s.fold((_) {}, (m) {
      totalIncome.value = m['income'] ?? 0;
      totalExpense.value = m['expense'] ?? 0;
    });
    isLoading.value = false;
  }

  void changePeriod(FilterPeriod p) {
    selectedPeriod.value = p;
    loadTransactions();
  }

  void applyFilter({
    String? walletId,
    String? categoryId,
    TransactionType? type,
  }) {
    filterWalletId.value = walletId;
    filterCategoryId.value = categoryId;
    filterType.value = type;
    loadTransactions();
  }

  void setSearch(String q) {
    searchQuery.value = q;
    loadTransactions();
  }

  void prepareForm([TransactionEntity? existing]) {
    if (existing != null) {
      amountCtrl.text = existing.amount.toStringAsFixed(0);
      noteCtrl.text = existing.note ?? '';
      selectedTab.value = existing.type.index;
      selectedWalletId.value = existing.walletId;
      selectedToWalletId.value = existing.toWalletId;
      selectedCategoryId.value = existing.categoryId;
      selectedDate.value = existing.date;
    } else {
      amountCtrl.clear();
      noteCtrl.clear();
      selectedTab.value = 0;
      selectedDate.value = DateTime.now();
      selectedCategoryId.value = null;
      selectedToWalletId.value = null;
      if (wallets.isNotEmpty) selectedWalletId.value = wallets.first.id;
    }
  }

  Future<void> saveTransaction([TransactionEntity? existing]) async {
    final amount = double.tryParse(amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      Get.snackbar('Validation', 'Enter a valid amount');
      return;
    }
    if (selectedWalletId.value == null) {
      Get.snackbar('Validation', 'Select a wallet');
      return;
    }

    final types = ['expense', 'income', 'transfer'];
    final type = types[selectedTab.value];

    isLoading.value = true;
    if (existing == null) {
      final r = await _create(CreateTransactionParams(
        userId: _userId,
        walletId: selectedWalletId.value!,
        toWalletId: type == 'transfer' ? selectedToWalletId.value : null,
        categoryId: selectedCategoryId.value,
        type: type,
        amount: amount,
        date: selectedDate.value,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      ));
      r.fold((f) => Get.snackbar('Error', f.message), (_) {});
    } else {
      final updated = _TxCopy(
        id: existing.id,
        userId: existing.userId,
        walletId: selectedWalletId.value!,
        toWalletId: type == 'transfer' ? selectedToWalletId.value : null,
        categoryId: selectedCategoryId.value,
        subcategoryId: existing.subcategoryId,
        type: TransactionType.fromValue(type),
        amount: amount,
        originalAmount: existing.originalAmount,
        originalCurrency: existing.originalCurrency,
        exchangeRate: existing.exchangeRate,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        date: selectedDate.value,
        receiptImagePath: existing.receiptImagePath,
        isRecurring: existing.isRecurring,
        recurringId: existing.recurringId,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: existing.deletedAt,
        syncStatus: 'pending',
        version: existing.version,
      );
      final r = await _update(updated);
      r.fold((f) => Get.snackbar('Error', f.message), (_) {});
    }
    isLoading.value = false;
    await loadTransactions();
    Get.back();
  }

  Future<void> deleteTransaction(String id) async {
    final r = await _delete(DeleteTransactionParams(id));
    r.fold(
      (f) => Get.snackbar('Error', f.message),
      (_) {
        transactions.removeWhere((t) => t.id == id);
        Get.snackbar(
          'Deleted',
          'Transaction removed',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () {}, // TODO: undo
            child: const Text('UNDO',
                style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  // Group transactions by date
  Map<String, List<TransactionEntity>> get grouped {
    final map = <String, List<TransactionEntity>>{};
    for (final tx in transactions) {
      final key = _dateKey(tx.date);
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map;
  }

  String _dateKey(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(d.year, d.month, d.day);
    final diff = today.difference(txDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${d.day} ${_month(d.month)} ${d.year}';
  }

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];

  WalletEntity? walletById(String? id) =>
      id == null ? null : wallets.firstWhereOrNull((w) => w.id == id);

  CategoryEntity? categoryById(String? id) =>
      id == null ? null : categories.firstWhereOrNull((c) => c.id == id);
}

class _TxCopy extends TransactionEntity {
  const _TxCopy({
    required super.id,
    required super.userId,
    required super.walletId,
    super.toWalletId,
    super.categoryId,
    super.subcategoryId,
    required super.type,
    required super.amount,
    super.originalAmount,
    super.originalCurrency,
    super.exchangeRate,
    super.note,
    required super.date,
    super.receiptImagePath,
    required super.isRecurring,
    super.recurringId,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required super.syncStatus,
    required super.version,
  });
}
