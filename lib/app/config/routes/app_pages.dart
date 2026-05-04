import 'package:get/get.dart';

import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/splash_page.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/pages/login_page.dart';
import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/pages/onboarding_page.dart';
import '../../modules/main_nav/main_nav_binding.dart';
import '../../modules/main_nav/main_nav_page.dart';
import '../../modules/wallet/bindings/wallet_binding.dart';
import '../../modules/wallet/pages/wallet_list_page.dart';
import '../../modules/wallet/pages/wallet_form_page.dart';
import '../../modules/wallet/pages/wallet_detail_page.dart';
import '../../modules/category/bindings/category_binding.dart';
import '../../modules/category/pages/category_list_page.dart';
import '../../modules/category/pages/category_form_page.dart';
import '../../modules/transaction/bindings/transaction_binding.dart';
import '../../modules/transaction/pages/transaction_list_page.dart';
import '../../modules/transaction/pages/transaction_form_page.dart';
import '../../modules/transaction/pages/transaction_detail_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainNavPage(),
      binding: MainNavBinding(),
    ),
    // Wallets
    GetPage(
      name: AppRoutes.wallets,
      page: () => const WalletListPage(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.walletAdd,
      page: () => const WalletFormPage(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.walletDetail,
      page: () => const WalletDetailPage(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.walletEdit,
      page: () => const WalletFormPage(),
      binding: WalletBinding(),
    ),
    // Categories
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoryListPage(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.categoryAdd,
      page: () => const CategoryFormPage(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.categoryEdit,
      page: () => const CategoryFormPage(),
      binding: CategoryBinding(),
    ),
    // Transactions
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionListPage(),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.transactionAdd,
      page: () => const TransactionFormPage(),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.transactionDetail,
      page: () => const TransactionDetailPage(),
    ),
    GetPage(
      name: AppRoutes.transactionEdit,
      page: () => const TransactionFormPage(),
      binding: TransactionBinding(),
    ),
  ];
}
