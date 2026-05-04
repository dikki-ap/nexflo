enum DebtStatus {
  active,
  partiallyPaid,
  settled;

  String get value => switch (this) {
        DebtStatus.partiallyPaid => 'partially_paid',
        _ => name,
      };

  static DebtStatus fromValue(String value) => switch (value) {
        'partially_paid' => DebtStatus.partiallyPaid,
        _ => DebtStatus.values.firstWhere((e) => e.name == value),
      };
}
