import 'package:drift/drift.dart' show Value;
import '../../core/utils/uuid_helper.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../database/app_database.dart';

class SubcategoryModel extends SubcategoryEntity {
  const SubcategoryModel({
    required super.id,
    required super.categoryId,
    required super.userId,
    required super.name,
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

  factory SubcategoryModel.fromDrift(Subcategory s) => SubcategoryModel(
        id: s.id,
        categoryId: s.categoryId,
        userId: s.userId,
        name: s.name,
        iconName: s.iconName,
        colorHex: s.colorHex,
        isDefault: s.isDefault,
        sortOrder: s.sortOrder,
        isArchived: s.isArchived,
        createdAt: s.createdAt,
        updatedAt: s.updatedAt,
        deletedAt: s.deletedAt,
        syncStatus: s.syncStatus,
      );

  static SubcategoryModel create({
    required String userId,
    required String categoryId,
    required String name,
    required String iconName,
    required String colorHex,
    required int sortOrder,
  }) {
    final now = DateTime.now();
    return SubcategoryModel(
      id: UuidHelper.generate(),
      categoryId: categoryId,
      userId: userId,
      name: name,
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

  SubcategoriesCompanion toCompanion() => SubcategoriesCompanion(
        id: Value(id),
        categoryId: Value(categoryId),
        userId: Value(userId),
        name: Value(name),
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

  SubcategoryModel copyWith({
    String? name,
    String? iconName,
    String? colorHex,
    bool? isArchived,
    DateTime? updatedAt,
    String? syncStatus,
  }) =>
      SubcategoryModel(
        id: id,
        categoryId: categoryId,
        userId: userId,
        name: name ?? this.name,
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
