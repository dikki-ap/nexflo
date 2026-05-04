import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/subcategory_repository.dart';
import '../../entities/subcategory_entity.dart';
import '../usecase.dart';

class GetSubcategoriesUseCase
    extends UseCase<List<SubcategoryEntity>, GetSubcategoriesParams> {
  final SubcategoryRepository _repo;
  GetSubcategoriesUseCase(this._repo);

  @override
  Future<Either<Failure, List<SubcategoryEntity>>> call(
          GetSubcategoriesParams params) =>
      _repo.getSubcategories(params.categoryId);
}

class GetSubcategoriesParams extends Equatable {
  final String categoryId;
  const GetSubcategoriesParams(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
