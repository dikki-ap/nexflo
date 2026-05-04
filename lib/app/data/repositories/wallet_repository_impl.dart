import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/local/wallet_local_ds.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource _local;
  WalletRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<WalletEntity>>> getAllWallets(
      String userId) async {
    try {
      return Right(await _local.getAllByUserId(userId));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> createWallet({
    required String userId,
    required String name,
    required String type,
    required String colorHex,
    required String iconName,
    required String currencyCode,
    required double initialBalance,
    double? creditLimit,
    required bool isExcludeTotal,
  }) async {
    try {
      final sortOrder = await _local.getNextSortOrder(userId);
      final model = WalletModel.create(
        userId: userId,
        name: name,
        type: type,
        colorHex: colorHex,
        iconName: iconName,
        currencyCode: currencyCode,
        initialBalance: initialBalance,
        creditLimit: creditLimit,
        isExcludeTotal: isExcludeTotal,
        sortOrder: sortOrder,
      );
      return Right(await _local.insert(model));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> updateWallet(
      WalletEntity wallet) async {
    try {
      return Right(await _local.update(wallet));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWallet(String id) async {
    try {
      await _local.softDelete(id);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> archiveWallet(String id, bool archive) async {
    try {
      await _local.setArchived(id, archive);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> reorderWallets(
      String userId, List<String> orderedIds) async {
    try {
      await _local.reorder(userId, orderedIds);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> adjustBalance({
    required String walletId,
    required double newBalance,
  }) async {
    try {
      return Right(await _local.updateBalance(walletId, newBalance));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }
}
