import 'package:get/get.dart';
import '../../../core/enums/filter_period.dart';
import '../../../data/datasources/local/wallet_local_ds.dart';
import '../../../data/datasources/local/transaction_local_ds.dart';
import '../../../data/datasources/local/category_local_ds.dart';
import '../../../data/repositories/wallet_repository_impl.dart';
import '../../../data/repositories/transaction_repository_impl.dart';
import '../../../data/repositories/category_repository_impl.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/wallet_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/wallet/get_all_wallets_usecase.dart';
import '../../../domain/usecases/transaction/get_transactions_usecase.dart';
import '../../../domain/usecases/transaction/get_transaction_summary_usecase.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../services/auth_service.dart';

class DashboardController extends GetxController {
  final selectedPeriod = FilterPeriod.thisMonth.obs;
  final wallets = <WalletEntity>[].obs;
  final recentTransactions = <TransactionEntity>[].obs;
  final categories = <CategoryEntity>[].obs;
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final isLoading = false.obs;

  late final GetAllWalletsUseCase _getWallets;
  late final GetTransactionsUseCase _getTransactions;
  late final GetTransactionSummaryUseCase _getSummary;
  late final GetCategoriesUseCase _getCategories;

  UserEntity? get currentUser => Get.find<AuthService>().currentUser;

  double get netWorth => wallets
      .where((w) => !w.isExcludeTotal && !w.isArchived && w.deletedAt == null)
      .fold(0.0, (s, w) => s + w.balance);

  @override
  void onInit() {
    super.onInit();
    final db = Get.find<AppDatabase>();

    _getWallets = GetAllWalletsUseCase(WalletRepositoryImpl(WalletLocalDataSource(db)));
    _getTransactions = GetTransactionsUseCase(
        TransactionRepositoryImpl(TransactionLocalDataSource(db)));
    _getSummary = GetTransactionSummaryUseCase(
        TransactionRepositoryImpl(TransactionLocalDataSource(db)));
    _getCategories = GetCategoriesUseCase(
        CategoryRepositoryImpl(CategoryLocalDataSource(db)));

    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    final uid = currentUser?.id;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    final futures = await Future.wait([
      _getWallets(GetAllWalletsParams(uid)),
      _getTransactions(GetTransactionsParams(
          userId: uid, period: selectedPeriod.value)),
      _getSummary(GetSummaryParams(userId: uid, period: selectedPeriod.value)),
      _getCategories(GetCategoriesParams(uid)),
    ]);

    futures[0].fold((_) {}, (list) => wallets.value = list as List<WalletEntity>);
    futures[1].fold((_) {}, (list) {
      final txs = list as List<TransactionEntity>;
      recentTransactions.value = txs.take(5).toList();
    });
    futures[2].fold((_) {}, (m) {
      final map = m as Map<String, double>;
      totalIncome.value = map['income'] ?? 0;
      totalExpense.value = map['expense'] ?? 0;
    });
    futures[3].fold((_) {}, (list) => categories.value = list as List<CategoryEntity>);

    isLoading.value = false;
  }

  void changePeriod(FilterPeriod period) {
    selectedPeriod.value = period;
    loadAll();
  }

  CategoryEntity? categoryById(String? id) =>
      id == null ? null : categories.firstWhereOrNull((c) => c.id == id);

  WalletEntity? walletById(String? id) =>
      id == null ? null : wallets.firstWhereOrNull((w) => w.id == id);
}
