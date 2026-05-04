import 'package:get/get.dart';

class NotificationService extends GetxService {
  Future<NotificationService> init() async {
    // TODO(phase-6): implement local notifications for budget alerts,
    // recurring reminders, debt deadlines
    return this;
  }

  Future<void> showBudgetAlert(String budgetName, int percent) async {}
  Future<void> showRecurringReminder(String transactionName) async {}
  Future<void> showDebtReminder(String personName) async {}
}
