import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/subcategory_model.dart';
import '../../../domain/entities/subcategory_entity.dart';

class SubcategoryLocalDataSource {
  final AppDatabase _db;
  SubcategoryLocalDataSource(this._db);

  Future<void> insertMany(List<SubcategoriesCompanion> companions) async {
    try {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.subcategories, companions);
      });
    } catch (e) {
      throw LocalDatabaseException('Failed to insert subcategories: $e');
    }
  }

  Future<bool> hasDefaultSubcategories(String userId) async {
    try {
      final rows = await (_db.select(_db.subcategories)
            ..where((s) => s.userId.equals(userId))
            ..where((s) => s.isDefault.equals(true)))
          .get();
      return rows.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<SubcategoryModel>> getByCategoryId(String categoryId) async {
    try {
      final rows = await (_db.select(_db.subcategories)
            ..where((s) => s.categoryId.equals(categoryId))
            ..where((s) => s.deletedAt.isNull())
            ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
          .get();
      return rows.map(SubcategoryModel.fromDrift).toList();
    } catch (e) {
      throw LocalDatabaseException('Failed to get subcategories: $e');
    }
  }

  Future<SubcategoryModel> insert(SubcategoryModel model) async {
    try {
      await _db.into(_db.subcategories).insert(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to create subcategory: $e');
    }
  }

  Future<SubcategoryModel> update(SubcategoryEntity sub) async {
    try {
      final model = SubcategoryModel(
        id: sub.id,
        categoryId: sub.categoryId,
        userId: sub.userId,
        name: sub.name,
        iconName: sub.iconName,
        colorHex: sub.colorHex,
        isDefault: sub.isDefault,
        sortOrder: sub.sortOrder,
        isArchived: sub.isArchived,
        createdAt: sub.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: sub.deletedAt,
        syncStatus: 'pending',
      );
      await (_db.update(_db.subcategories)
            ..where((s) => s.id.equals(sub.id)))
          .write(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to update subcategory: $e');
    }
  }

  Future<void> softDelete(String id) async {
    try {
      await (_db.update(_db.subcategories)..where((s) => s.id.equals(id)))
          .write(SubcategoriesCompanion(
        deletedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ));
    } catch (e) {
      throw LocalDatabaseException('Failed to delete subcategory: $e');
    }
  }

  Future<int> getNextSortOrder(String categoryId) async {
    final subs = await getByCategoryId(categoryId);
    return subs.isEmpty ? 0 : subs.last.sortOrder + 1;
  }
}
