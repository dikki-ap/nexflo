import 'package:get/get.dart';
import 'main_nav_controller.dart';
import '../dashboard/controllers/dashboard_controller.dart';
import '../statistics/controllers/statistics_controller.dart';
import '../settings/controllers/settings_controller.dart';
import '../transaction/controllers/transaction_controller.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainNavController());
    // IndexedStack renders all 3 tab pages on first build — controllers must
    // be available before that. TransactionController is also registered here
    // (fenix) so the transaction-add FAB route works without a separate binding.
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => StatisticsController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(() => TransactionController(), fenix: true);
  }
}
