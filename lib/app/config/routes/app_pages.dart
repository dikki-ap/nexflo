import 'package:get/get.dart';

import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/splash_page.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/pages/login_page.dart';
import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/pages/onboarding_page.dart';
import '../../modules/main_nav/main_nav_binding.dart';
import '../../modules/main_nav/main_nav_page.dart';
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
  ];
}
