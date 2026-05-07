import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/debt_type.dart';
import '../../../data/datasources/local/debt_local_ds.dart';
import '../../../data/repositories/debt_repository_impl.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/debt_entity.dart';
import '../../../domain/entities/debt_payment_entity.dart';
import '../../../domain/usecases/debt/get_all_debts_usecase.dart';
import '../../../domain/usecases/debt/create_debt_usecase.dart';
import '../../../domain/usecases/debt/update_debt_usecase.dart';
import '../../../domain/usecases/debt/delete_debt_usecase.dart';
import '../../../domain/usecases/debt/add_debt_payment_usecase.dart';
import '../../../domain/usecases/debt/get_debt_payments_usecase.dart';
import '../../../services/auth_service.dart';
import '../../../services/currency_service.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class DebtController extends GetxController {
  final debts = <DebtEntity>[].obs;
  final payments = <DebtPaymentEntity>[].obs;
  final isLoading = false.obs;

  // Form state
  final selectedType = DebtType.iOwe.obs;
  final personNameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final selectedDeadline = Rxn<DateTime>();
  final noteCtrl = TextEditingController();
  final paymentAmountCtrl = TextEditingController();
  final paymentNoteCtrl = TextEditingController();

  late final GetAllDebtsUseCase _getAll;
  late final CreateDebtUseCase _create;
  late final UpdateDebtUseCase _update;
  late final DeleteDebtUseCase _delete;
  late final AddDebtPaymentUseCase _addPayment;
  late final GetDebtPaymentsUseCase _getPayments;

  String get _userId => Get.find<AuthService>().currentUser?.id ?? '';

  List<DebtEntity> get iOweList =>
      debts.where((d) => d.type == DebtType.iOwe && d.deletedAt == null).toList();
  List<DebtEntity> get owedToMeList =>
      debts.where((d) => d.type == DebtType.owedToMe && d.deletedAt == null).toList();

  double get totalIOwe =>
      iOweList.fold(0.0, (s, d) => s + d.remaining);
  double get totalOwedToMe =>
      owedToMeList.fold(0.0, (s, d) => s + d.remaining);

  @override
  void onInit() {
    super.onInit();
    final db = Get.find<AppDatabase>();
    final ds = DebtLocalDataSource(db);
    final repo = DebtRepositoryImpl(ds);
    _getAll = GetAllDebtsUseCase(repo);
    _create = CreateDebtUseCase(repo);
    _update = UpdateDebtUseCase(repo);
    _delete = DeleteDebtUseCase(repo);
    _addPayment = AddDebtPaymentUseCase(repo);
    _getPayments = GetDebtPaymentsUseCase(repo);
    loadDebts();
  }

  @override
  void onClose() {
    personNameCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
    paymentAmountCtrl.dispose();
    paymentNoteCtrl.dispose();
    super.onClose();
  }

  Future<void> loadDebts() async {
    isLoading.value = true;
    final result = await _getAll(GetAllDebtsParams(_userId));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (list) => debts.value = list,
    );
    isLoading.value = false;
  }

  Future<void> loadPayments(String debtId) async {
    final result = await _getPayments(GetPaymentsParams(debtId));
    result.fold((_) {}, (list) => payments.value = list);
  }

  void initForm([DebtEntity? existing]) {
    if (existing != null) {
      selectedType.value = existing.type;
      personNameCtrl.text = existing.personName;
      amountCtrl.text = existing.amount.toStringAsFixed(0);
      selectedDeadline.value = existing.deadline;
      noteCtrl.text = existing.note ?? '';
    } else {
      selectedType.value = DebtType.iOwe;
      personNameCtrl.clear();
      amountCtrl.clear();
      selectedDeadline.value = null;
      noteCtrl.clear();
    }
  }

  Future<void> saveDebt([DebtEntity? existing]) async {
    final name = personNameCtrl.text.trim();
    final amount = double.tryParse(amountCtrl.text) ?? 0;
    if (name.isEmpty || amount <= 0) {
      Get.snackbar('Error', 'Name and amount are required');
      return;
    }

    isLoading.value = true;
    if (existing == null) {
      final result = await _create(CreateDebtParams(
        userId: _userId,
        type: selectedType.value.value,
        personName: name,
        amount: amount,
        currencyCode: Get.find<CurrencyService>().baseCurrency,
        deadline: selectedDeadline.value,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      ));
      result.fold((f) => Get.snackbar('Error', f.message), (_) {
        Get.back();
        loadDebts();
        _notifyDashboard();
      });
    } else {
      final updated = _DebtCopy(
        id: existing.id,
        userId: existing.userId,
        type: existing.type,
        personName: name,
        amount: amount,
        paidAmount: existing.paidAmount,
        currencyCode: existing.currencyCode,
        deadline: selectedDeadline.value,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        status: existing.status,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );
      final result = await _update(updated);
      result.fold((f) => Get.snackbar('Error', f.message), (_) {
        Get.back();
        loadDebts();
        _notifyDashboard();
      });
    }
    isLoading.value = false;
  }

  void _notifyDashboard() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadAll();
    }
  }

  Future<void> recordPayment(DebtEntity debt) async {
    final amount = double.tryParse(paymentAmountCtrl.text) ?? 0;
    if (amount <= 0) {
      Get.snackbar('Error', 'Enter a valid amount');
      return;
    }
    final result = await _addPayment(AddPaymentParams(
      debtId: debt.id,
      amount: amount,
      date: DateTime.now(),
      note: paymentNoteCtrl.text.trim().isEmpty
          ? null
          : paymentNoteCtrl.text.trim(),
    ));
    result.fold((f) => Get.snackbar('Error', f.message), (_) {
      paymentAmountCtrl.clear();
      paymentNoteCtrl.clear();
      Get.back();
      loadDebts();
      loadPayments(debt.id);
      _notifyDashboard();
    });
  }

  Future<void> deleteDebt(String id) async {
    final result = await _delete(DeleteDebtParams(id));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (_) => loadDebts(),
    );
  }
}

class _DebtCopy extends DebtEntity {
  const _DebtCopy({
    required super.id,
    required super.userId,
    required super.type,
    required super.personName,
    required super.amount,
    required super.paidAmount,
    required super.currencyCode,
    super.deadline,
    super.note,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required super.syncStatus,
  });
}
