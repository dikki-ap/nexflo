import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/uuid_helper.dart';
import '../../models/category_model.dart';
import '../../../domain/entities/category_entity.dart';

class CategoryLocalDataSource {
  final AppDatabase _db;
  CategoryLocalDataSource(this._db);

  Future<void> insertMany(List<CategoriesCompanion> companions) async {
    try {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.categories, companions);
      });
    } catch (e) {
      throw LocalDatabaseException('Failed to insert categories: $e');
    }
  }

  Future<bool> hasDefaultCategories(String userId) async {
    try {
      final count = await (_db.select(_db.categories)
            ..where((c) => c.userId.equals(userId))
            ..where((c) => c.isDefault.equals(true)))
          .get();
      return count.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<CategoryModel>> getAllByUserId(String userId) async {
    try {
      final rows = await (_db.select(_db.categories)
            ..where((c) => c.userId.equals(userId))
            ..where((c) => c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .get();
      return rows.map(CategoryModel.fromDrift).toList();
    } catch (e) {
      throw LocalDatabaseException('Failed to get categories: $e');
    }
  }

  Future<CategoryModel> insert(CategoryModel model) async {
    try {
      await _db.into(_db.categories).insert(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to create category: $e');
    }
  }

  Future<CategoryModel> update(CategoryEntity cat) async {
    try {
      final model = CategoryModel(
        id: cat.id,
        userId: cat.userId,
        name: cat.name,
        type: cat.type,
        iconName: cat.iconName,
        colorHex: cat.colorHex,
        isDefault: cat.isDefault,
        sortOrder: cat.sortOrder,
        isArchived: cat.isArchived,
        createdAt: cat.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: cat.deletedAt,
        syncStatus: 'pending',
      );
      await (_db.update(_db.categories)..where((c) => c.id.equals(cat.id)))
          .write(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to update category: $e');
    }
  }

  Future<void> softDelete(String id) async {
    try {
      await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(
          deletedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
    } catch (e) {
      throw LocalDatabaseException('Failed to delete category: $e');
    }
  }

  Future<void> setArchived(String id, bool archive) async {
    try {
      await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(
          isArchived: Value(archive),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
    } catch (e) {
      throw LocalDatabaseException('Failed to archive category: $e');
    }
  }

  Future<int> getNextSortOrder(String userId) async {
    final cats = await getAllByUserId(userId);
    return cats.isEmpty ? 0 : cats.last.sortOrder + 1;
  }

  Future<void> seedDefaultCategories(String userId) async {
    if (await hasDefaultCategories(userId)) return;

    final now = DateTime.now();
    final expenseCategories = [
      ('Food & Drink', 'expense', 'restaurant', '#FF5722', 0),
      ('Transport', 'expense', 'directions_car', '#2196F3', 1),
      ('Shopping', 'expense', 'shopping_bag', '#E91E63', 2),
      ('Housing', 'expense', 'home', '#795548', 3),
      ('Health', 'expense', 'favorite', '#F44336', 4),
      ('Entertainment', 'expense', 'movie', '#9C27B0', 5),
      ('Education', 'expense', 'school', '#3F51B5', 6),
      ('Personal Care', 'expense', 'spa', '#FF9800', 7),
      ('Travel', 'expense', 'flight', '#00BCD4', 8),
      ('Bills & Utilities', 'expense', 'receipt_long', '#607D8B', 9),
      ('Subscription', 'expense', 'repeat', '#009688', 10),
      ('Others', 'expense', 'more_horiz', '#9E9E9E', 11),
    ];

    final incomeCategories = [
      ('Salary', 'income', 'work', '#4CAF50', 0),
      ('Freelance', 'income', 'laptop', '#8BC34A', 1),
      ('Investment Return', 'income', 'trending_up', '#00BCD4', 2),
      ('Gift', 'income', 'card_giftcard', '#FF9800', 3),
      ('Bonus', 'income', 'star', '#FFC107', 4),
      ('Others', 'income', 'more_horiz', '#9E9E9E', 5),
    ];

    final transferCategory = [
      ('Transfer', 'both', 'swap_horiz', '#00BCD4', 0),
    ];

    final allCategories = [
      ...expenseCategories,
      ...incomeCategories,
      ...transferCategory,
    ];

    final companions = allCategories.map((c) {
      final (name, type, icon, color, sort) = c;
      return CategoriesCompanion.insert(
        id: UuidHelper.generate(),
        userId: userId,
        name: name,
        type: type,
        iconName: icon,
        colorHex: color,
        isDefault: const Value(true),
        sortOrder: Value(sort),
        createdAt: Value(now),
        updatedAt: Value(now),
      );
    }).toList();

    await insertMany(companions);
  }
}
