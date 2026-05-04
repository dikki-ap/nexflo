class DateHelper {
  DateHelper._();

  /// Returns [start, end] for "this month" based on the user's cutoff date.
  /// E.g. cutoffDate=25, today=2026-05-10 → [2026-04-25, 2026-05-24]
  static (DateTime start, DateTime end) getThisMonthRange(int cutoffDate) {
    final now = DateTime.now();
    final DateTime start;
    final DateTime end;

    if (now.day >= cutoffDate) {
      start = DateTime(now.year, now.month, cutoffDate);
      end = DateTime(now.year, now.month + 1, cutoffDate - 1, 23, 59, 59);
    } else {
      start = DateTime(now.year, now.month - 1, cutoffDate);
      end = DateTime(now.year, now.month, cutoffDate - 1, 23, 59, 59);
    }

    return (start, end);
  }

  static (DateTime start, DateTime end) getLastMonthRange(int cutoffDate) {
    final (thisStart, _) = getThisMonthRange(cutoffDate);
    final end = thisStart.subtract(const Duration(seconds: 1));
    final start = DateTime(end.year, end.month - 1, cutoffDate);
    return (start, end);
  }

  static (DateTime start, DateTime end) getRangeForMonths(int months) {
    final now = DateTime.now();
    return (
      DateTime(now.year, now.month - months, now.day),
      now,
    );
  }

  static (DateTime start, DateTime end) getRangeForYears(int years) {
    final now = DateTime.now();
    return (DateTime(now.year - years, now.month, now.day), now);
  }

  static DateTime nextDueDate({
    required DateTime current,
    required String recurrenceType,
    required int interval,
  }) {
    return switch (recurrenceType) {
      'daily' => current.add(Duration(days: interval)),
      'weekly' => current.add(Duration(days: 7 * interval)),
      'monthly' => DateTime(current.year, current.month + interval, current.day),
      'yearly' => DateTime(current.year + interval, current.month, current.day),
      _ => current,
    };
  }
}
