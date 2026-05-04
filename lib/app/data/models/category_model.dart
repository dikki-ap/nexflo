import 'package:drift/drift.dart' show Value;
import '../../core/enums/category_type.dart';
import '../../core/utils/uuid_helper.dart';
import '../../domain/entities/category_entity.dart';
import '../database/app_database.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.iconName,
    required super.colorHex,
    required super.isDefault,
    required super.sortOrder,
    required super.isArchived,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required super.syncStatus,
  });

  factory CategoryModel.fromDrift(Category c) => CategoryModel(
        id: c.id,
        userId: c.userId,
        name: c.name,
        type: CategoryType.fromValue(c.type),
        iconName: c.iconName,
        colorHex: c.colorHex,
        isDefault: c.isDefault,
        sortOrder: c.sortOrder,
        isArchived: c.isArchived,
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
        deletedAt: c.deletedAt,
        syncStatus: c.syncStatus,
      );

  static CategoryModel create({
    required String userId,
    required String name,
    required String type,
    required String iconName,
    required String colorHex,
    required int sortOrder,
  }) {
    final now = DateTime.now();
    return CategoryModel(
      id: UuidHelper.generate(),
      userId: userId,
      name: name,
      type: CategoryType.fromValue(type),
      iconName: iconName,
      colorHex: colorHex,
      isDefault: false,
      sortOrder: sortOrder,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );
  }

  CategoriesCompanion toCompanion() => CategoriesCompanion(
        id: Value(id),
        userId: Value(userId),
        name: Value(name),
        type: Value(type.value),
        iconName: Value(iconName),
        colorHex: Value(colorHex),
        isDefault: Value(isDefault),
        sortOrder: Value(sortOrder),
        isArchived: Value(isArchived),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
        syncStatus: Value(syncStatus),
      );

  CategoryModel copyWith({
    String? name,
    String? iconName,
    String? colorHex,
    bool? isArchived,
    DateTime? updatedAt,
    String? syncStatus,
  }) =>
      CategoryModel(
        id: id,
        userId: userId,
        name: name ?? this.name,
        type: type,
        iconName: iconName ?? this.iconName,
        colorHex: colorHex ?? this.colorHex,
        isDefault: isDefault,
        sortOrder: sortOrder,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? 'pending',
      );
}
