import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/category_repository.dart';
import '../usecase.dart';

class DeleteCategoryUseCase extends UseCase<void, DeleteCategoryParams> {
  final CategoryRepository _repo;
  DeleteCategoryUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(DeleteCategoryParams params) =>
      _repo.deleteCategory(params.id);
}

class DeleteCategoryParams extends Equatable {
  final String id;
  const DeleteCategoryParams(this.id);

  @override
  List<Object?> get props => [id];
}
