import 'package:get/get.dart';
import '../data/database/app_database.dart';

enum SyncState { idle, syncing, success, error }

class SyncService extends GetxService {
  final AppDatabase _db;
  SyncService(this._db);

  final _syncState = SyncState.idle.obs;
  SyncState get syncState => _syncState.value;
  bool get isSyncing => _syncState.value == SyncState.syncing;

  Future<SyncService> init() async {
    return this;
  }

  // TODO(phase-5): implement full sync orchestrator
  Future<void> sync() async {
    if (_syncState.value == SyncState.syncing) return;
    _syncState.value = SyncState.syncing;
    await Future.delayed(const Duration(milliseconds: 500));
    _syncState.value = SyncState.success;
  }
}
