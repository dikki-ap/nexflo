class SheetsConstants {
  SheetsConstants._();

  static const spreadsheetName = '📊 NexFlo — My Financial Data';

  // Sheet tab names
  static const sheetMeta = '_meta';
  static const sheetWallets = 'wallets';
  static const sheetTransactions = 'transactions';
  static const sheetCategories = 'categories';
  static const sheetSubcategories = 'subcategories';
  static const sheetBudgets = 'budgets';
  static const sheetGoals = 'goals';
  static const sheetDebts = 'debts';
  static const sheetDebtPayments = 'debt_payments';
  static const sheetRecurring = 'recurring';
  static const sheetSettings = 'settings';

  // Sheets API scopes
  static const scopeSpreadsheets =
      'https://www.googleapis.com/auth/spreadsheets';
  static const scopeDriveFile =
      'https://www.googleapis.com/auth/drive.file';

  static const int batchSize = 10;
  static const int rateLimitRequestsPer100Sec = 100;
}
