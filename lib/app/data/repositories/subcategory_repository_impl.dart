import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/repositories/subcategory_repository.dart';
import '../datasources/local/subcategory_local_ds.dart';
import '../models/subcategory_model.dart';

class SubcategoryRepositoryImpl implements SubcategoryRepository {
  final SubcategoryLocalDataSource _local;
  SubcategoryRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories(
      String categoryId) async {
    try {
      return Right(await _local.getByCategoryId(categoryId));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SubcategoryEntity>> createSubcategory({
    required String userId,
    required String categoryId,
    required String name,
    required String iconName,
    required String colorHex,
  }) async {
    try {
      final sortOrder = await _local.getNextSortOrder(categoryId);
      final model = SubcategoryModel.create(
        userId: userId,
        categoryId: categoryId,
        name: name,
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
  Future<Either<Failure, SubcategoryEntity>> updateSubcategory(
      SubcategoryEntity subcategory) async {
    try {
      return Right(await _local.update(subcategory));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSubcategory(String id) async {
    try {
      await _local.softDelete(id);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }
}
