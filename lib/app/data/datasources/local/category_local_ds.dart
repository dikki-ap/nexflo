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

    // (name, type, icon, colorHex, sort) — indices 0-11 expense, 12-17 income, 18 transfer
    final allCatDefs = [
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
      ('Salary', 'income', 'work', '#4CAF50', 0),
      ('Freelance', 'income', 'laptop', '#8BC34A', 1),
      ('Investment Return', 'income', 'trending_up', '#00BCD4', 2),
      ('Gift', 'income', 'card_giftcard', '#FF9800', 3),
      ('Bonus', 'income', 'star', '#FFC107', 4),
      ('Others', 'income', 'more_horiz', '#9E9E9E', 5),
      ('Transfer', 'both', 'swap_horiz', '#00BCD4', 0),
    ];

    // Pre-generate IDs so subcategories can reference them by index
    final catIds = List.generate(allCatDefs.length, (_) => UuidHelper.generate());

    final catCompanions = List.generate(allCatDefs.length, (i) {
      final (name, type, icon, color, sort) = allCatDefs[i];
      return CategoriesCompanion.insert(
        id: catIds[i],
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
    });
    await insertMany(catCompanions);

    // (catIndex, subName, icon, colorHex, sort)
    final subDefs = [
      (0, 'Dine Out', 'restaurant', '#FF5722', 0),
      (0, 'Groceries', 'local_grocery_store', '#FF7043', 1),
      (0, 'Coffee', 'coffee', '#FF5722', 2),
      (0, 'Fast Food', 'fastfood', '#FF8A65', 3),
      (1, 'Fuel', 'local_gas_station', '#2196F3', 0),
      (1, 'Public Transit', 'directions_bus', '#1E88E5', 1),
      (1, 'Taxi / Ride', 'local_taxi', '#42A5F5', 2),
      (1, 'Car Service', 'car_repair', '#1976D2', 3),
      (2, 'Clothing', 'shopping_bag', '#E91E63', 0),
      (2, 'Electronics', 'tv', '#EC407A', 1),
      (2, 'Household', 'home', '#F06292', 2),
      (3, 'Rent / Mortgage', 'home', '#795548', 0),
      (3, 'Electricity', 'electric_bolt', '#8D6E63', 1),
      (3, 'Water', 'water_drop', '#A1887F', 2),
      (3, 'Internet', 'wifi', '#6D4C41', 3),
      (4, 'Medical', 'local_hospital', '#F44336', 0),
      (4, 'Gym', 'fitness_center', '#EF5350', 1),
      (4, 'Pharmacy', 'local_pharmacy', '#E53935', 2),
      (4, 'Wellness', 'spa', '#EF9A9A', 3),
      (5, 'Cinema', 'movie', '#9C27B0', 0),
      (5, 'Streaming', 'tv', '#AB47BC', 1),
      (5, 'Sports', 'sports', '#BA68C8', 2),
      (5, 'Music', 'music_note', '#CE93D8', 3),
      (6, 'Tuition', 'school', '#3F51B5', 0),
      (6, 'Books', 'menu_book', '#5C6BC0', 1),
      (6, 'Online Course', 'laptop', '#7986CB', 2),
      (7, 'Haircut', 'content_cut', '#FF9800', 0),
      (7, 'Skincare', 'spa', '#FFA726', 1),
      (7, 'Laundry', 'cleaning_services', '#FFB74D', 2),
      (8, 'Flights', 'flight', '#00BCD4', 0),
      (8, 'Hotel', 'hotel', '#26C6DA', 1),
      (8, 'Food Abroad', 'restaurant', '#4DD0E1', 2),
      (9, 'Electricity', 'electric_bolt', '#607D8B', 0),
      (9, 'Water', 'water_drop', '#78909C', 1),
      (9, 'Phone', 'phone', '#90A4AE', 2),
      (9, 'Internet', 'wifi', '#B0BEC5', 3),
      (10, 'Streaming', 'movie', '#009688', 0),
      (10, 'Music', 'music_note', '#26A69A', 1),
      (10, 'Premium', 'star', '#4DB6AC', 2),
      (12, 'Monthly', 'work', '#4CAF50', 0),
      (12, 'Contract', 'laptop', '#66BB6A', 1),
      (13, 'Project', 'laptop', '#8BC34A', 0),
      (13, 'Consulting', 'work', '#9CCC65', 1),
      (14, 'Dividends', 'bar_chart', '#00BCD4', 0),
      (14, 'Capital Gains', 'trending_up', '#26C6DA', 1),
      (15, 'Birthday', 'card_giftcard', '#FF9800', 0),
      (15, 'Special Occasion', 'favorite', '#FFA726', 1),
      (16, 'Performance', 'star', '#FFC107', 0),
      (16, 'Year-End', 'attach_money', '#FFCA28', 1),
    ];

    final subCompanions = subDefs.map((s) {
      final (catIdx, name, icon, color, sort) = s;
      return SubcategoriesCompanion.insert(
        id: UuidHelper.generate(),
        userId: userId,
        categoryId: catIds[catIdx],
        name: name,
        iconName: icon,
        colorHex: color,
        isDefault: const Value(true),
        sortOrder: Value(sort),
        createdAt: Value(now),
        updatedAt: Value(now),
      );
    }).toList();

    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.subcategories, subCompanions);
    });
  }
}
