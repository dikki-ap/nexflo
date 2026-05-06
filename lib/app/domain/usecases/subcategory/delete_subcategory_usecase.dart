import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/subcategory_repository.dart';
import '../usecase.dart';

class DeleteSubcategoryUseCase extends UseCase<void, DeleteSubcategoryParams> {
  final SubcategoryRepository _repo;
  DeleteSubcategoryUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(DeleteSubcategoryParams params) =>
      _repo.deleteSubcategory(params.id);
}

class DeleteSubcategoryParams extends Equatable {
  final String id;
  const DeleteSubcategoryParams(this.id);

  @override
  List<Object?> get props => [id];
}
