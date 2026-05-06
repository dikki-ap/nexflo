import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/wallet_repository.dart';
import '../usecase.dart';

class DeleteWalletUseCase extends UseCase<void, DeleteWalletParams> {
  final WalletRepository _repo;
  DeleteWalletUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(DeleteWalletParams params) =>
      _repo.deleteWallet(params.id);
}

class DeleteWalletParams extends Equatable {
  final String id;
  const DeleteWalletParams(this.id);

  @override
  List<Object?> get props => [id];
}
