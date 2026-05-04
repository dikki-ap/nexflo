import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/subcategory_repository.dart';
import '../../entities/subcategory_entity.dart';
import '../usecase.dart';

class UpdateSubcategoryUseCase
    extends UseCase<SubcategoryEntity, SubcategoryEntity> {
  final SubcategoryRepository _repo;
  UpdateSubcategoryUseCase(this._repo);

  @override
  Future<Either<Failure, SubcategoryEntity>> call(SubcategoryEntity params) =>
      _repo.updateSubcategory(params);
}
