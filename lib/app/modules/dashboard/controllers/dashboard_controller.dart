import 'package:get/get.dart';
import '../../../core/enums/filter_period.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../services/auth_service.dart';

class DashboardController extends GetxController {
  final selectedPeriod = FilterPeriod.thisMonth.obs;
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final netWorth = 0.0.obs;
  final isLoading = false.obs;

  UserEntity? get currentUser => Get.find<AuthService>().currentUser;

  @override
  void onInit() {
    super.onInit();
    // TODO(phase-2): load real wallet + transaction data
  }

  void changePeriod(FilterPeriod period) {
    selectedPeriod.value = period;
    // TODO(phase-2): reload data for selected period
  }
}
