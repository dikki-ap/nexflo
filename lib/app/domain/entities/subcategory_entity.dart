import 'package:equatable/equatable.dart';

class SubcategoryEntity extends Equatable {
  final String id;
  final String categoryId;
  final String userId;
  final String name;
  final String iconName;
  final String colorHex;
  final bool isDefault;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;

  const SubcategoryEntity({
    required this.id,
    required this.categoryId,
    required this.userId,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.isDefault,
    required this.sortOrder,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });

  @override
  List<Object?> get props => [id, categoryId, name];
}
