import 'package:get/get.dart';
import '../../core/enums/filter_period.dart';

class SharedFilterController extends GetxController {
  final selectedPeriod = FilterPeriod.thisMonth.obs;
  final customStart = Rxn<DateTime>();
  final customEnd = Rxn<DateTime>();

  void changePeriod(FilterPeriod p) {
    if (p != FilterPeriod.custom) {
      customStart.value = null;
      customEnd.value = null;
    }
    selectedPeriod.value = p;
  }

  void applyCustomRange(DateTime start, DateTime end) {
    customStart.value = start;
    customEnd.value = end;
    selectedPeriod.value = FilterPeriod.custom;
  }
}
