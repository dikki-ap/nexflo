import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/subcategory_repository.dart';
import '../../entities/subcategory_entity.dart';
import '../usecase.dart';

class CreateSubcategoryUseCase
    extends UseCase<SubcategoryEntity, CreateSubcategoryParams> {
  final SubcategoryRepository _repo;
  CreateSubcategoryUseCase(this._repo);

  @override
  Future<Either<Failure, SubcategoryEntity>> call(
          CreateSubcategoryParams params) =>
      _repo.createSubcategory(
        userId: params.userId,
        categoryId: params.categoryId,
        name: params.name,
        iconName: params.iconName,
        colorHex: params.colorHex,
      );
}

class CreateSubcategoryParams extends Equatable {
  final String userId;
  final String categoryId;
  final String name;
  final String iconName;
  final String colorHex;

  const CreateSubcategoryParams({
    required this.userId,
    required this.categoryId,
    required this.name,
    required this.iconName,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [userId, categoryId, name];
}
