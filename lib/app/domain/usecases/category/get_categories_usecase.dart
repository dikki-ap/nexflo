import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/category_repository.dart';
import '../../entities/category_entity.dart';
import '../usecase.dart';

class GetCategoriesUseCase
    extends UseCase<List<CategoryEntity>, GetCategoriesParams> {
  final CategoryRepository _repo;
  GetCategoriesUseCase(this._repo);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(
          GetCategoriesParams params) =>
      _repo.getCategories(params.userId);
}

class GetCategoriesParams extends Equatable {
  final String userId;
  const GetCategoriesParams(this.userId);

  @override
  List<Object?> get props => [userId];
}
