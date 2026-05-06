import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/category_repository.dart';
import '../../entities/category_entity.dart';
import '../usecase.dart';

class UpdateCategoryUseCase extends UseCase<CategoryEntity, CategoryEntity> {
  final CategoryRepository _repo;
  UpdateCategoryUseCase(this._repo);

  @override
  Future<Either<Failure, CategoryEntity>> call(CategoryEntity params) =>
      _repo.updateCategory(params);
}
