import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, List<WalletEntity>>> getAllWallets(String userId);
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
  });
  Future<Either<Failure, WalletEntity>> updateWallet(WalletEntity wallet);
  Future<Either<Failure, void>> deleteWallet(String id);
  Future<Either<Failure, void>> archiveWallet(String id, bool archive);
  Future<Either<Failure, void>> reorderWallets(
      String userId, List<String> orderedIds);
  Future<Either<Failure, WalletEntity>> adjustBalance({
    required String walletId,
    required double newBalance,
  });
}
