import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/debt_repository.dart';
import '../../entities/debt_entity.dart';
import '../usecase.dart';

class UpdateDebtUseCase extends UseCase<DebtEntity, DebtEntity> {
  final DebtRepository _repo;
  UpdateDebtUseCase(this._repo);

  @override
  Future<Either<Failure, DebtEntity>> call(DebtEntity params) =>
      _repo.updateDebt(params);
}
