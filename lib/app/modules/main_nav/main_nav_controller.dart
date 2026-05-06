import 'package:get/get.dart';
import '../dashboard/controllers/dashboard_controller.dart';

class MainNavController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    final prev = currentIndex.value;
    currentIndex.value = index;
    // Refresh dashboard data whenever the user returns to the home tab so that
    // newly added wallets, transactions, or budget changes are reflected.
    if (index == 0 && prev != 0) {
      Get.find<DashboardController>().loadAll();
    }
  }
}
