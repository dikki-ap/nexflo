enum WalletType {
  cash,
  bank,
  ewallet,
  creditCard,
  investment,
  savings;

  String get value => switch (this) {
        WalletType.creditCard => 'credit_card',
        _ => name,
      };

  static WalletType fromValue(String value) => switch (value) {
        'credit_card' => WalletType.creditCard,
        _ => WalletType.values.firstWhere((e) => e.name == value),
      };

  String get label => switch (this) {
        WalletType.cash => 'Cash',
        WalletType.bank => 'Bank Account',
        WalletType.ewallet => 'E-Wallet',
        WalletType.creditCard => 'Credit Card',
        WalletType.investment => 'Investment',
        WalletType.savings => 'Savings',
      };

  String get iconName => switch (this) {
        WalletType.cash => 'wallet',
        WalletType.bank => 'account_balance',
        WalletType.ewallet => 'phone_android',
        WalletType.creditCard => 'credit_card',
        WalletType.investment => 'trending_up',
        WalletType.savings => 'savings',
      };
}
