import 'package:get/get.dart';
import '../../config/routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../data/datasources/local/settings_local_ds.dart';
import '../../data/database/app_database.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    final authService = Get.find<AuthService>();

    if (!authService.isLoggedIn) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final user = authService.currentUser!;
    final db = Get.find<AppDatabase>();
    final settingsDs = SettingsLocalDataSource(db);
    final settings = await settingsDs.getByUserId(user.id);

    if (settings == null) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    // TODO(phase-6): check biometric/PIN lock
    Get.offAllNamed(AppRoutes.main);
  }
}
