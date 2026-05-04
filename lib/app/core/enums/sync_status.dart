enum SyncStatus {
  pending,
  synced,
  failed;

  String get value => name;

  static SyncStatus fromValue(String value) =>
      SyncStatus.values.firstWhere((e) => e.name == value);
}
