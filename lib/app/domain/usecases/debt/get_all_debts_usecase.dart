import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/debt_repository.dart';
import '../../entities/debt_entity.dart';
import '../usecase.dart';

class GetAllDebtsUseCase extends UseCase<List<DebtEntity>, GetAllDebtsParams> {
  final DebtRepository _repo;
  GetAllDebtsUseCase(this._repo);

  @override
  Future<Either<Failure, List<DebtEntity>>> call(GetAllDebtsParams params) =>
      _repo.getAllDebts(params.userId);
}

class GetAllDebtsParams extends Equatable {
  final String userId;
  const GetAllDebtsParams(this.userId);

  @override
  List<Object> get props => [userId];
}
