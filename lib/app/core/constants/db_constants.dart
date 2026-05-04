class DbConstants {
  DbConstants._();

  static const dbName = 'nexflo_db';
  static const schemaVersion = 1;

  // Sync status values
  static const syncPending = 'pending';
  static const syncSynced = 'synced';
  static const syncFailed = 'failed';
  static const syncProcessing = 'processing';
  static const syncDone = 'done';

  // Action types for sync queue
  static const actionCreate = 'create';
  static const actionUpdate = 'update';
  static const actionDelete = 'delete';

  // Entity types for sync queue
  static const entityWallet = 'wallet';
  static const entityTransaction = 'transaction';
  static const entityCategory = 'category';
  static const entitySubcategory = 'subcategory';
  static const entityBudget = 'budget';
  static const entityGoal = 'goal';
  static const entityDebt = 'debt';
  static const entityDebtPayment = 'debt_payment';
  static const entityRecurring = 'recurring';
  static const entitySettings = 'settings';
}
