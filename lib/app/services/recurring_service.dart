import 'package:get/get.dart';
import '../data/database/app_database.dart';

class RecurringService extends GetxService {
  final AppDatabase _db;
  RecurringService(this._db);

  Future<RecurringService> init() async {
    await processDue();
    return this;
  }

  // TODO(phase-4): implement full recurring transaction processing
  Future<void> processDue() async {}
}
