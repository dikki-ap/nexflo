import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/transaction_repository.dart';
import '../../../core/enums/filter_period.dart';
import '../usecase.dart';

class GetTransactionSummaryUseCase
    extends UseCase<Map<String, double>, GetSummaryParams> {
  final TransactionRepository _repo;
  GetTransactionSummaryUseCase(this._repo);

  @override
  Future<Either<Failure, Map<String, double>>> call(GetSummaryParams params) =>
      _repo.getSummary(
        userId: params.userId,
        period: params.period,
        customStart: params.customStart,
        customEnd: params.customEnd,
      );
}

class GetSummaryParams extends Equatable {
  final String userId;
  final FilterPeriod period;
  final DateTime? customStart;
  final DateTime? customEnd;

  const GetSummaryParams({
    required this.userId,
    required this.period,
    this.customStart,
    this.customEnd,
  });

  @override
  List<Object?> get props => [userId, period, customStart, customEnd];
}
