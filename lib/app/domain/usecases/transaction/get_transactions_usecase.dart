import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/transaction_repository.dart';
import '../../entities/transaction_entity.dart';
import '../../../core/enums/filter_period.dart';
import '../../../core/enums/transaction_type.dart';
import '../usecase.dart';

class GetTransactionsUseCase
    extends UseCase<List<TransactionEntity>, GetTransactionsParams> {
  final TransactionRepository _repo;
  GetTransactionsUseCase(this._repo);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(
          GetTransactionsParams params) =>
      _repo.getTransactions(
        userId: params.userId,
        period: params.period,
        walletId: params.walletId,
        categoryId: params.categoryId,
        type: params.type,
        searchQuery: params.searchQuery,
        customStart: params.customStart,
        customEnd: params.customEnd,
      );
}

class GetTransactionsParams extends Equatable {
  final String userId;
  final FilterPeriod period;
  final String? walletId;
  final String? categoryId;
  final TransactionType? type;
  final String? searchQuery;
  final DateTime? customStart;
  final DateTime? customEnd;

  const GetTransactionsParams({
    required this.userId,
    required this.period,
    this.walletId,
    this.categoryId,
    this.type,
    this.searchQuery,
    this.customStart,
    this.customEnd,
  });

  @override
  List<Object?> get props =>
      [userId, period, walletId, categoryId, type, searchQuery];
}
