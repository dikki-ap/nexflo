import 'package:get/get.dart';
import 'main_nav_controller.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainNavController());
  }
}
