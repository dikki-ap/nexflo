import 'package:drift/drift.dart' show Value;
import '../../core/enums/wallet_type.dart';
import '../../core/utils/uuid_helper.dart';
import '../../domain/entities/wallet_entity.dart';
import '../database/app_database.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.colorHex,
    required super.iconName,
    required super.balance,
    required super.currencyCode,
    super.creditLimit,
    required super.isExcludeTotal,
    required super.sortOrder,
    required super.isArchived,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required super.syncStatus,
  });

  factory WalletModel.fromDrift(Wallet w) => WalletModel(
        id: w.id,
        userId: w.userId,
        name: w.name,
        type: WalletType.fromValue(w.type),
        colorHex: w.colorHex,
        iconName: w.iconName,
        balance: w.balance,
        currencyCode: w.currencyCode,
        creditLimit: w.creditLimit,
        isExcludeTotal: w.isExcludeTotal,
        sortOrder: w.sortOrder,
        isArchived: w.isArchived,
        createdAt: w.createdAt,
        updatedAt: w.updatedAt,
        deletedAt: w.deletedAt,
        syncStatus: w.syncStatus,
      );

  static WalletModel create({
    required String userId,
    required String name,
    required String type,
    required String colorHex,
    required String iconName,
    required String currencyCode,
    required double initialBalance,
    double? creditLimit,
    required bool isExcludeTotal,
    required int sortOrder,
  }) {
    final now = DateTime.now();
    return WalletModel(
      id: UuidHelper.generate(),
      userId: userId,
      name: name,
      type: WalletType.fromValue(type),
      colorHex: colorHex,
      iconName: iconName,
      balance: initialBalance,
      currencyCode: currencyCode,
      creditLimit: creditLimit,
      isExcludeTotal: isExcludeTotal,
      sortOrder: sortOrder,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );
  }

  WalletsCompanion toCompanion() => WalletsCompanion(
        id: Value(id),
        userId: Value(userId),
        name: Value(name),
        type: Value(type.value),
        colorHex: Value(colorHex),
        iconName: Value(iconName),
        balance: Value(balance),
        currencyCode: Value(currencyCode),
        creditLimit: Value(creditLimit),
        isExcludeTotal: Value(isExcludeTotal),
        sortOrder: Value(sortOrder),
        isArchived: Value(isArchived),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
        syncStatus: Value(syncStatus),
      );

  WalletModel copyWith({
    String? name,
    String? colorHex,
    String? iconName,
    double? balance,
    double? creditLimit,
    bool? isExcludeTotal,
    bool? isArchived,
    int? sortOrder,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? syncStatus,
  }) =>
      WalletModel(
        id: id,
        userId: userId,
        name: name ?? this.name,
        type: type,
        colorHex: colorHex ?? this.colorHex,
        iconName: iconName ?? this.iconName,
        balance: balance ?? this.balance,
        currencyCode: currencyCode,
        creditLimit: creditLimit ?? this.creditLimit,
        isExcludeTotal: isExcludeTotal ?? this.isExcludeTotal,
        sortOrder: sortOrder ?? this.sortOrder,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        deletedAt: deletedAt ?? this.deletedAt,
        syncStatus: syncStatus ?? 'pending',
      );
}
