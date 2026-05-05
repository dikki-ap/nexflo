import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/receipt_scan_controller.dart';

class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TransactionController());
    Get.lazyPut(() => ReceiptScanController());
  }
}
