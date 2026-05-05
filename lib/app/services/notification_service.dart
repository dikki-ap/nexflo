import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  Future<NotificationService> init() async {
    return this;
  }

  void showBudgetAlert(String budgetName, int percent) {
    final isOver = percent >= 100;
    Get.snackbar(
      isOver ? '⚠️ Budget Exceeded' : '🔔 Budget Alert',
      '$budgetName is at $percent% of limit',
      snackPosition: SnackPosition.TOP,
      backgroundColor: isOver ? Colors.red.shade700 : Colors.orange.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: Icon(
        isOver ? Icons.warning_rounded : Icons.notifications_active,
        color: Colors.white,
      ),
    );
  }

  void showRecurringReminder(String transactionName) {
    Get.snackbar(
      '🔄 Recurring Transaction',
      '$transactionName has been processed',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void showDebtReminder(String personName, DateTime deadline) {
    final daysLeft = deadline.difference(DateTime.now()).inDays;
    Get.snackbar(
      '📋 Debt Reminder',
      daysLeft <= 0
          ? 'Debt with $personName is overdue!'
          : 'Debt with $personName due in $daysLeft days',
      snackPosition: SnackPosition.TOP,
      backgroundColor: daysLeft <= 0 ? Colors.red.shade700 : null,
      colorText: daysLeft <= 0 ? Colors.white : null,
      duration: const Duration(seconds: 4),
    );
  }
}
