import '../../database/app_database.dart';
import '../../../core/errors/exceptions.dart';

class MonthlyData {
  final int year;
  final int month;
  final double income;
  final double expense;
  const MonthlyData({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
  });

  String get label {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  double get cashflow => income - expense;
}

class StatisticsLocalDataSource {
  final AppDatabase _db;
  StatisticsLocalDataSource(this._db);

  Future<Map<String, double>> getExpenseByCategory({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final rows = await (_db.select(_db.transactions)
            ..where((t) => t.userId.equals(userId))
            ..where((t) => t.type.equals('expense'))
            ..where((t) => t.deletedAt.isNull())
            ..where((t) => t.date.isBiggerOrEqualValue(start))
            ..where((t) => t.date.isSmallerOrEqualValue(end)))
          .get();

      final map = <String, double>{};
      for (final row in rows) {
        final key = row.categoryId ?? '__uncategorized__';
        map[key] = (map[key] ?? 0) + row.amount;
      }
      return map;
    } catch (e) {
      throw LocalDatabaseException('Failed to get expense by category: $e');
    }
  }

  Future<List<MonthlyData>> getMonthlyBreakdown({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final rows = await (_db.select(_db.transactions)
            ..where((t) => t.userId.equals(userId))
            ..where((t) => t.deletedAt.isNull())
            ..where((t) => t.type.isNotValue('transfer'))
            ..where((t) => t.date.isBiggerOrEqualValue(start))
            ..where((t) => t.date.isSmallerOrEqualValue(end))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

      final map = <String, MonthlyData>{};
      for (final row in rows) {
        final key = '${row.date.year}-${row.date.month}';
        final existing = map[key];
        final income =
            row.type == 'income' ? (existing?.income ?? 0) + row.amount : (existing?.income ?? 0);
        final expense =
            row.type == 'expense' ? (existing?.expense ?? 0) + row.amount : (existing?.expense ?? 0);
        map[key] = MonthlyData(
          year: row.date.year,
          month: row.date.month,
          income: income,
          expense: expense,
        );
      }

      // Fill in all months in range (even empty ones)
      final result = <MonthlyData>[];
      var cursor = DateTime(start.year, start.month, 1);
      final endMonth = DateTime(end.year, end.month, 1);
      while (!cursor.isAfter(endMonth)) {
        final key = '${cursor.year}-${cursor.month}';
        result.add(map[key] ?? MonthlyData(year: cursor.year, month: cursor.month, income: 0, expense: 0));
        cursor = DateTime(cursor.year, cursor.month + 1, 1);
      }
      return result;
    } catch (e) {
      throw LocalDatabaseException('Failed to get monthly breakdown: $e');
    }
  }

  Future<Map<String, double>> getSummary({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final rows = await (_db.select(_db.transactions)
            ..where((t) => t.userId.equals(userId))
            ..where((t) => t.deletedAt.isNull())
            ..where((t) => t.type.isNotValue('transfer'))
            ..where((t) => t.date.isBiggerOrEqualValue(start))
            ..where((t) => t.date.isSmallerOrEqualValue(end)))
          .get();

      double income = 0, expense = 0;
      for (final row in rows) {
        if (row.type == 'income') {
          income += row.amount;
        } else {
          expense += row.amount;
        }
      }
      return {'income': income, 'expense': expense};
    } catch (e) {
      throw LocalDatabaseException('Failed to get summary: $e');
    }
  }
}
