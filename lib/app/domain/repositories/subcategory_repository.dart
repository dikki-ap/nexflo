import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/subcategory_entity.dart';

abstract class SubcategoryRepository {
  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories(
      String categoryId);
  Future<Either<Failure, SubcategoryEntity>> createSubcategory({
    required String userId,
    required String categoryId,
    required String name,
    required String iconName,
    required String colorHex,
  });
  Future<Either<Failure, SubcategoryEntity>> updateSubcategory(
      SubcategoryEntity subcategory);
  Future<Either<Failure, void>> deleteSubcategory(String id);
}
