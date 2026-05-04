enum DebtType {
  iOwe,
  owedToMe;

  String get value => switch (this) {
        DebtType.iOwe => 'i_owe',
        DebtType.owedToMe => 'owed_to_me',
      };

  static DebtType fromValue(String value) => switch (value) {
        'i_owe' => DebtType.iOwe,
        'owed_to_me' => DebtType.owedToMe,
        _ => throw ArgumentError('Unknown DebtType: $value'),
      };

  String get label => switch (this) {
        DebtType.iOwe => 'I Owe',
        DebtType.owedToMe => 'Owed to Me',
      };
}
