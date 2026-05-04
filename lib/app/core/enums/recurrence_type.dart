enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly;

  String get value => name;

  static RecurrenceType fromValue(String value) =>
      RecurrenceType.values.firstWhere((e) => e.name == value);

  String get label => switch (this) {
        RecurrenceType.daily => 'Daily',
        RecurrenceType.weekly => 'Weekly',
        RecurrenceType.monthly => 'Monthly',
        RecurrenceType.yearly => 'Yearly',
      };
}
