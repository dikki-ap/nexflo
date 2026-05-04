import 'package:get/get.dart';
import 'main_nav_controller.dart';
import '../dashboard/controllers/dashboard_controller.dart';
import '../transaction/controllers/transaction_controller.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainNavController());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => TransactionController());
  }
}
