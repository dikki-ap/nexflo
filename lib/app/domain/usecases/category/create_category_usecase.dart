import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/category_repository.dart';
import '../../entities/category_entity.dart';
import '../usecase.dart';

class CreateCategoryUseCase
    extends UseCase<CategoryEntity, CreateCategoryParams> {
  final CategoryRepository _repo;
  CreateCategoryUseCase(this._repo);

  @override
  Future<Either<Failure, CategoryEntity>> call(CreateCategoryParams params) =>
      _repo.createCategory(
        userId: params.userId,
        name: params.name,
        type: params.type,
        iconName: params.iconName,
        colorHex: params.colorHex,
      );
}

class CreateCategoryParams extends Equatable {
  final String userId;
  final String name;
  final String type;
  final String iconName;
  final String colorHex;

  const CreateCategoryParams({
    required this.userId,
    required this.name,
    required this.type,
    required this.iconName,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [userId, name, type];
}
