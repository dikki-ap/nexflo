import 'package:get/get.dart';
import 'main_nav_controller.dart';
import '../dashboard/controllers/dashboard_controller.dart';
import '../transaction/controllers/transaction_controller.dart';
import '../statistics/controllers/statistics_controller.dart';
import '../settings/controllers/settings_controller.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainNavController());
    // IndexedStack renders all 4 tab pages immediately — each needs its
    // controller available before build. Individual module bindings only fire
    // when navigating to sub-routes, so we register here as well.
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => TransactionController(), fenix: true);
    Get.lazyPut(() => StatisticsController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
  }
}
