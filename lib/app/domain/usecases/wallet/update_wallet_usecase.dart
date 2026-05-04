import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/wallet_repository.dart';
import '../../entities/wallet_entity.dart';
import '../usecase.dart';

class UpdateWalletUseCase extends UseCase<WalletEntity, WalletEntity> {
  final WalletRepository _repo;
  UpdateWalletUseCase(this._repo);

  @override
  Future<Either<Failure, WalletEntity>> call(WalletEntity params) =>
      _repo.updateWallet(params);
}
