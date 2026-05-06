import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/wallet_repository.dart';
import '../../entities/wallet_entity.dart';
import '../usecase.dart';

class GetAllWalletsUseCase
    extends UseCase<List<WalletEntity>, GetAllWalletsParams> {
  final WalletRepository _repo;
  GetAllWalletsUseCase(this._repo);

  @override
  Future<Either<Failure, List<WalletEntity>>> call(
          GetAllWalletsParams params) =>
      _repo.getAllWallets(params.userId);
}

class GetAllWalletsParams extends Equatable {
  final String userId;
  const GetAllWalletsParams(this.userId);

  @override
  List<Object?> get props => [userId];
}
