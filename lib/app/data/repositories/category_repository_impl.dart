import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/category_local_ds.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _local;
  CategoryRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories(
      String userId) async {
    try {
      return Right(await _local.getAllByUserId(userId));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory({
    required String userId,
    required String name,
    required String type,
    required String iconName,
    required String colorHex,
  }) async {
    try {
      final sortOrder = await _local.getNextSortOrder(userId);
      final model = CategoryModel.create(
        userId: userId,
        name: name,
        type: type,
        iconName: iconName,
        colorHex: colorHex,
        sortOrder: sortOrder,
      );
      return Right(await _local.insert(model));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
      CategoryEntity category) async {
    try {
      return Right(await _local.update(category));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _local.softDelete(id);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> archiveCategory(String id, bool archive) async {
    try {
      await _local.setArchived(id, archive);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }
}
