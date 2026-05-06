import 'dart:convert';

import 'package:googleapis/sheets/v4.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/sheets_constants.dart';
import '../../../core/errors/exceptions.dart';

class SheetsRemoteDataSource {
  static const _sheetHeaders = <String, List<String>>{
    SheetsConstants.sheetMeta: [
      'app_version',
      'schema_version',
      'last_sync_at',
      'user_email',
      'created_at',
    ],
    SheetsConstants.sheetWallets: [
      'id', 'user_id', 'name', 'type', 'color_hex', 'icon_name', 'balance',
      'currency_code', 'credit_limit', 'is_exclude_total', 'sort_order',
      'is_archived', 'created_at', 'updated_at', 'deleted_at', 'version',
    ],
    SheetsConstants.sheetTransactions: [
      'id', 'user_id', 'wallet_id', 'to_wallet_id', 'category_id',
      'subcategory_id', 'type', 'amount', 'original_amount',
      'original_currency', 'exchange_rate', 'note', 'date',
      'receipt_image_path', 'is_recurring', 'recurring_id',
      'created_at', 'updated_at', 'deleted_at', 'version',
    ],
    SheetsConstants.sheetCategories: [
      'id', 'user_id', 'name', 'type', 'icon_name', 'color_hex',
      'is_default', 'sort_order', 'is_archived', 'created_at', 'updated_at',
      'deleted_at', 'version',
    ],
    SheetsConstants.sheetSubcategories: [
      'id', 'category_id', 'user_id', 'name', 'icon_name', 'color_hex',
      'is_default', 'sort_order', 'is_archived', 'created_at', 'updated_at',
      'deleted_at', 'version',
    ],
    SheetsConstants.sheetBudgets: [
      'id', 'user_id', 'name', 'amount', 'period', 'category_id', 'wallet_id',
      'is_all_categories', 'rollover', 'alert_at_percent', 'created_at',
      'updated_at', 'deleted_at', 'version',
    ],
    SheetsConstants.sheetGoals: [
      'id', 'user_id', 'wallet_id', 'name', 'icon_name', 'color_hex',
      'target_amount', 'current_amount', 'deadline', 'status', 'note',
      'created_at', 'updated_at', 'deleted_at', 'version',
    ],
    SheetsConstants.sheetDebts: [
      'id', 'user_id', 'type', 'person_name', 'amount', 'paid_amount',
      'currency_code', 'deadline', 'note', 'status', 'created_at',
      'updated_at', 'deleted_at', 'version',
    ],
    SheetsConstants.sheetDebtPayments: [
      'id', 'debt_id', 'amount', 'date', 'note', 'created_at',
    ],
    SheetsConstants.sheetRecurring: [
      'id', 'user_id', 'wallet_id', 'to_wallet_id', 'category_id',
      'subcategory_id', 'type', 'amount', 'note', 'recurrence_type',
      'recurrence_interval', 'start_date', 'end_date', 'next_due_date',
      'last_processed_date', 'is_active', 'created_at', 'updated_at',
      'deleted_at', 'version',
    ],
    SheetsConstants.sheetSettings: [
      'id', 'user_id', 'base_currency_code', 'cutoff_date', 'theme_mode',
      'theme_color', 'theme_custom_hex', 'sync_enabled',
      'notification_budget_alert', 'notification_recurring_reminder',
      'notification_debt_reminder', 'updated_at',
    ],
  };

  Future<SheetsApi> _getApi() async {
    final account = await GoogleSignIn.instance.currentUser.first;
    if (account == null) throw const AuthException('Not signed in');
    final headers = await account.authHeaders;
    final client = _AuthenticatedClient(http.Client(), headers);
    return SheetsApi(client);
  }

  Future<String> createSpreadsheet({
    required String title,
    required String userEmail,
  }) async {
    try {
      final api = await _getApi();

      // Create spreadsheet with all needed sheets
      final sheetNames = _sheetHeaders.keys.toList();
      final sheets = sheetNames.map((name) {
        return Sheet(properties: SheetProperties(title: name));
      }).toList();

      final spreadsheet = await api.spreadsheets.create(
        Spreadsheet(
          properties: SpreadsheetProperties(title: title),
          sheets: sheets,
        ),
      );

      final spreadsheetId = spreadsheet.spreadsheetId!;

      // Write headers for each sheet
      await _initializeAllHeaders(api, spreadsheetId, userEmail);

      return spreadsheetId;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw SyncException('Failed to create spreadsheet: $e');
    }
  }

  Future<void> _initializeAllHeaders(
    SheetsApi api,
    String spreadsheetId,
    String userEmail,
  ) async {
    final now = DateTime.now().toIso8601String();
    final data = <ValueRange>[];

    for (final entry in _sheetHeaders.entries) {
      data.add(ValueRange(
        range: '${entry.key}!A1',
        values: [entry.value],
      ));
    }

    // Add meta row
    data.add(ValueRange(
      range: '${SheetsConstants.sheetMeta}!A2',
      values: [['1.0.0', '1', now, userEmail, now]],
    ));

    await api.spreadsheets.values.batchUpdate(
      BatchUpdateValuesRequest(
        data: data,
        valueInputOption: 'USER_ENTERED',
      ),
      spreadsheetId,
    );
  }

  Future<List<List<String>>> getRows(
    String spreadsheetId,
    String sheetName,
  ) async {
    try {
      final api = await _getApi();
      final response = await api.spreadsheets.values.get(
        spreadsheetId,
        '$sheetName!A:ZZ',
      );

      final values = response.values ?? [];
      if (values.length <= 1) return []; // Only header or empty

      return values
          .skip(1) // Skip header row
          .map((row) => row.map((cell) => cell?.toString() ?? '').toList())
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw SyncException('Failed to get rows from $sheetName: $e');
    }
  }

  Future<void> appendRow(
    String spreadsheetId,
    String sheetName,
    List<String> row,
  ) async {
    try {
      final api = await _getApi();
      await api.spreadsheets.values.append(
        ValueRange(values: [row]),
        spreadsheetId,
        '$sheetName!A:A',
        valueInputOption: 'USER_ENTERED',
        insertDataOption: 'INSERT_ROWS',
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw SyncException('Failed to append row to $sheetName: $e');
    }
  }

  Future<void> updateRow(
    String spreadsheetId,
    String sheetName,
    int rowIndex, // 1-based, data starts at row 2
    List<String> row,
  ) async {
    try {
      final api = await _getApi();
      final sheetRow = rowIndex + 1; // +1 for header row
      await api.spreadsheets.values.update(
        ValueRange(values: [row]),
        spreadsheetId,
        '$sheetName!A$sheetRow',
        valueInputOption: 'USER_ENTERED',
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw SyncException('Failed to update row in $sheetName: $e');
    }
  }

  // Returns 1-based data row index (1 = first data row after header)
  Future<int?> findRowIndexById(
    String spreadsheetId,
    String sheetName,
    String id,
  ) async {
    final rows = await getRows(spreadsheetId, sheetName);
    for (var i = 0; i < rows.length; i++) {
      if (rows[i].isNotEmpty && rows[i][0] == id) {
        return i + 1;
      }
    }
    return null;
  }

  Future<void> upsertRow(
    String spreadsheetId,
    String sheetName,
    String id,
    List<String> row,
  ) async {
    final existingIndex = await findRowIndexById(spreadsheetId, sheetName, id);
    if (existingIndex != null) {
      await updateRow(spreadsheetId, sheetName, existingIndex, row);
    } else {
      await appendRow(spreadsheetId, sheetName, row);
    }
  }

  Future<void> updateMetaLastSync(
    String spreadsheetId,
    String lastSyncAt,
  ) async {
    try {
      final api = await _getApi();
      // Meta sheet: row 2 has data, column C (index 2) is last_sync_at
      await api.spreadsheets.values.update(
        ValueRange(values: [
          [lastSyncAt]
        ]),
        spreadsheetId,
        '${SheetsConstants.sheetMeta}!C2',
        valueInputOption: 'USER_ENTERED',
      );
    } catch (_) {
      // Non-critical — don't throw
    }
  }

  List<String> headersFor(String sheetName) =>
      _sheetHeaders[sheetName] ?? [];

  static const _enc = JsonEncoder();
  static String encode(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is bool) return v.toString();
    if (v is num) return v.toString();
    if (v is DateTime) return v.toIso8601String();
    return _enc.convert(v);
  }
}

class _AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final Map<String, String> _headers;

  _AuthenticatedClient(this._inner, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
