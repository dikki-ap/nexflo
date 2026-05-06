import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/wallet_repository.dart';
import '../usecase.dart';

class ReorderWalletsUseCase extends UseCase<void, ReorderWalletsParams> {
  final WalletRepository _repo;
  ReorderWalletsUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(ReorderWalletsParams params) =>
      _repo.reorderWallets(params.userId, params.orderedIds);
}

class ReorderWalletsParams extends Equatable {
  final String userId;
  final List<String> orderedIds;
  const ReorderWalletsParams(this.userId, this.orderedIds);

  @override
  List<Object?> get props => [userId, orderedIds];
}
