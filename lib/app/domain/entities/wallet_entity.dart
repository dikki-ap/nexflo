import 'package:equatable/equatable.dart';
import '../../core/enums/wallet_type.dart';

class WalletEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final WalletType type;
  final String colorHex;
  final String iconName;
  final double balance;
  final String currencyCode;
  final double? creditLimit;
  final bool isExcludeTotal;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;

  const WalletEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.colorHex,
    required this.iconName,
    required this.balance,
    required this.currencyCode,
    this.creditLimit,
    required this.isExcludeTotal,
    required this.sortOrder,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });

  @override
  List<Object?> get props => [id, name, balance, currencyCode];
}
