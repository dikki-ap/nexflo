import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories(String userId);
  Future<Either<Failure, CategoryEntity>> createCategory({
    required String userId,
    required String name,
    required String type,
    required String iconName,
    required String colorHex,
  });
  Future<Either<Failure, CategoryEntity>> updateCategory(
      CategoryEntity category);
  Future<Either<Failure, void>> deleteCategory(String id);
  Future<Either<Failure, void>> archiveCategory(String id, bool archive);
}
