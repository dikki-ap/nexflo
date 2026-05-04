import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/wallet_repository.dart';
import '../../entities/wallet_entity.dart';
import '../usecase.dart';

class AdjustWalletBalanceUseCase
    extends UseCase<WalletEntity, AdjustBalanceParams> {
  final WalletRepository _repo;
  AdjustWalletBalanceUseCase(this._repo);

  @override
  Future<Either<Failure, WalletEntity>> call(AdjustBalanceParams params) =>
      _repo.adjustBalance(
        walletId: params.walletId,
        newBalance: params.newBalance,
      );
}

class AdjustBalanceParams extends Equatable {
  final String walletId;
  final double newBalance;
  const AdjustBalanceParams({required this.walletId, required this.newBalance});

  @override
  List<Object?> get props => [walletId, newBalance];
}
