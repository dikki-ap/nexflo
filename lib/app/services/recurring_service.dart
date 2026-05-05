import 'package:get/get.dart';
import '../core/enums/transaction_type.dart';
import '../core/utils/date_helper.dart';
import '../data/database/app_database.dart';
import '../data/datasources/local/recurring_local_ds.dart';
import '../data/datasources/local/transaction_local_ds.dart';
import '../data/datasources/local/wallet_local_ds.dart';
import '../data/models/transaction_model.dart';
import '../services/auth_service.dart';

class RecurringService extends GetxService {
  final AppDatabase _db;
  RecurringService(this._db);

  Future<RecurringService> init() async {
    await processDue();
    return this;
  }

  Future<void> processDue() async {
    final authService = Get.find<AuthService>();
    final userId = authService.currentUser?.id;
    if (userId == null) return;

    final recurringDs = RecurringLocalDataSource(_db);
    final txDs = TransactionLocalDataSource(_db);
    final walletDs = WalletLocalDataSource(_db);

    final dueList = await recurringDs.getDueByUserId(userId);
    final now = DateTime.now();

    for (final recurring in dueList) {
      if (recurring.endDate != null && now.isAfter(recurring.endDate!)) {
        await recurringDs.updateNextDue(recurring.id, recurring.nextDueDate, now, false);
        continue;
      }

      final tx = TransactionModel.create(
        userId: recurring.userId,
        walletId: recurring.walletId,
        toWalletId: recurring.toWalletId,
        categoryId: recurring.categoryId,
        type: recurring.type.value,
        amount: recurring.amount,
        note: recurring.note,
        date: recurring.nextDueDate,
        isRecurring: true,
        recurringId: recurring.id,
      );
      await txDs.insert(tx);

      final wallet = await walletDs.getById(recurring.walletId);
      final updatedBalance = recurring.type == TransactionType.expense
          ? wallet.balance - recurring.amount
          : wallet.balance + recurring.amount;
      await walletDs.updateBalance(recurring.walletId, updatedBalance);

      if (recurring.toWalletId != null) {
        final toWallet = await walletDs.getById(recurring.toWalletId!);
        await walletDs.updateBalance(
            recurring.toWalletId!, toWallet.balance + recurring.amount);
      }

      final nextDue = DateHelper.nextDueDate(
        current: recurring.nextDueDate,
        recurrenceType: recurring.recurrenceType.value,
        interval: recurring.recurrenceInterval,
      );
      final stillActive = recurring.endDate == null ||
          nextDue.isBefore(recurring.endDate!);
      await recurringDs.updateNextDue(recurring.id, nextDue, now, stillActive);
    }
  }
}
