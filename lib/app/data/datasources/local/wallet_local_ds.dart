import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/wallet_model.dart';
import '../../../domain/entities/wallet_entity.dart';

class WalletLocalDataSource {
  final AppDatabase _db;
  WalletLocalDataSource(this._db);

  Future<List<WalletModel>> getAllByUserId(String userId) async {
    try {
      final rows = await (_db.select(_db.wallets)
            ..where((w) => w.userId.equals(userId))
            ..where((w) => w.deletedAt.isNull())
            ..orderBy([(w) => OrderingTerm.asc(w.sortOrder)]))
          .get();
      return rows.map(WalletModel.fromDrift).toList();
    } catch (e) {
      throw LocalDatabaseException('Failed to get wallets: $e');
    }
  }

  Future<WalletModel> getById(String id) async {
    try {
      final row = await (_db.select(_db.wallets)
            ..where((w) => w.id.equals(id)))
          .getSingle();
      return WalletModel.fromDrift(row);
    } catch (e) {
      throw LocalDatabaseException('Failed to get wallet: $e');
    }
  }

  Future<WalletModel> insert(WalletModel model) async {
    try {
      await _db.into(_db.wallets).insert(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to create wallet: $e');
    }
  }

  Future<WalletModel> update(WalletEntity wallet) async {
    try {
      final model = WalletModel(
        id: wallet.id,
        userId: wallet.userId,
        name: wallet.name,
        type: wallet.type,
        colorHex: wallet.colorHex,
        iconName: wallet.iconName,
        balance: wallet.balance,
        currencyCode: wallet.currencyCode,
        creditLimit: wallet.creditLimit,
        isExcludeTotal: wallet.isExcludeTotal,
        sortOrder: wallet.sortOrder,
        isArchived: wallet.isArchived,
        createdAt: wallet.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: wallet.deletedAt,
        syncStatus: 'pending',
      );
      await (_db.update(_db.wallets)..where((w) => w.id.equals(wallet.id)))
          .write(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to update wallet: $e');
    }
  }

  Future<void> softDelete(String id) async {
    try {
      await (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
        WalletsCompanion(
          deletedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
    } catch (e) {
      throw LocalDatabaseException('Failed to delete wallet: $e');
    }
  }

  Future<void> setArchived(String id, bool archive) async {
    try {
      await (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
        WalletsCompanion(
          isArchived: Value(archive),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
    } catch (e) {
      throw LocalDatabaseException('Failed to archive wallet: $e');
    }
  }

  Future<void> reorder(String userId, List<String> orderedIds) async {
    try {
      await _db.transaction(() async {
        for (var i = 0; i < orderedIds.length; i++) {
          await (_db.update(_db.wallets)
                ..where((w) => w.id.equals(orderedIds[i])))
              .write(WalletsCompanion(sortOrder: Value(i)));
        }
      });
    } catch (e) {
      throw LocalDatabaseException('Failed to reorder wallets: $e');
    }
  }

  Future<WalletModel> updateBalance(String walletId, double newBalance) async {
    try {
      await (_db.update(_db.wallets)..where((w) => w.id.equals(walletId)))
          .write(WalletsCompanion(
        balance: Value(newBalance),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ));
      return getById(walletId);
    } catch (e) {
      throw LocalDatabaseException('Failed to update balance: $e');
    }
  }

  Future<int> getNextSortOrder(String userId) async {
    final wallets = await getAllByUserId(userId);
    return wallets.isEmpty ? 0 : wallets.last.sortOrder + 1;
  }
}
