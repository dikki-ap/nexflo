import 'package:get/get.dart';
import 'lock_controller.dart';

class LockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LockController());
  }
}
