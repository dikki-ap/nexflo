import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/wallet_repository.dart';
import '../../entities/wallet_entity.dart';
import '../usecase.dart';

class CreateWalletUseCase extends UseCase<WalletEntity, CreateWalletParams> {
  final WalletRepository _repo;
  CreateWalletUseCase(this._repo);

  @override
  Future<Either<Failure, WalletEntity>> call(CreateWalletParams params) =>
      _repo.createWallet(
        userId: params.userId,
        name: params.name,
        type: params.type,
        colorHex: params.colorHex,
        iconName: params.iconName,
        currencyCode: params.currencyCode,
        initialBalance: params.initialBalance,
        creditLimit: params.creditLimit,
        isExcludeTotal: params.isExcludeTotal,
      );
}

class CreateWalletParams extends Equatable {
  final String userId;
  final String name;
  final String type;
  final String colorHex;
  final String iconName;
  final String currencyCode;
  final double initialBalance;
  final double? creditLimit;
  final bool isExcludeTotal;

  const CreateWalletParams({
    required this.userId,
    required this.name,
    required this.type,
    required this.colorHex,
    required this.iconName,
    required this.currencyCode,
    required this.initialBalance,
    this.creditLimit,
    required this.isExcludeTotal,
  });

  @override
  List<Object?> get props =>
      [userId, name, type, currencyCode, initialBalance];
}
