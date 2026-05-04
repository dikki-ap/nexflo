import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/routes/app_routes.dart';
import '../../../data/database/app_database.dart';
import '../../../data/datasources/local/category_local_ds.dart';
import '../../../data/datasources/local/currency_local_ds.dart';
import '../../../data/datasources/local/settings_local_ds.dart';
import '../../../services/auth_service.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;
  final selectedCurrencyCode = 'USD'.obs;
  final selectedCutoffDate = 1.obs;
  final isLoading = false.obs;

  static const int totalPages = 5;

  List<String> get currencyCodes => [
        'USD', 'EUR', 'GBP', 'JPY', 'SGD', 'MYR', 'IDR',
        'AUD', 'CAD', 'CHF', 'CNY', 'HKD', 'KRW', 'INR',
        'THB', 'PHP', 'VND', 'TWD', 'NZD', 'AED',
      ];

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onPageChanged(int page) => currentPage.value = page;

  Future<void> complete() async {
    isLoading.value = true;
    try {
      final db = Get.find<AppDatabase>();
      final authService = Get.find<AuthService>();
      final user = authService.currentUser!;

      final settingsDs = SettingsLocalDataSource(db);
      final existing = await settingsDs.getByUserId(user.id);
      if (existing == null) {
        await settingsDs.createDefault(user.id);
      }

      await settingsDs.update(
        (await settingsDs.getByUserId(user.id))!
          ..copyWith(
            baseCurrencyCode: selectedCurrencyCode.value,
            cutoffDate: selectedCutoffDate.value,
          ),
      );

      final categoryDs = CategoryLocalDataSource(db);
      await categoryDs.seedDefaultCategories(user.id);

      final currencyDs = CurrencyLocalDataSource(db);
      await currencyDs.seedCurrencies();

      Get.offAllNamed(AppRoutes.main);
    } finally {
      isLoading.value = false;
    }
  }
}
