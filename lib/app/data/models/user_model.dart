import '../../domain/entities/user_entity.dart';

// NOTE: fromDrift() references Drift-generated type 'User'.
// Run: dart run build_runner build --delete-conflicting-outputs
// ignore: depend_on_referenced_packages
import '../database/app_database.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.googleId,
    required super.name,
    required super.email,
    super.photoUrl,
    super.sheetsId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromDrift(User user) => UserModel(
        id: user.id,
        googleId: user.googleId,
        name: user.name,
        email: user.email,
        photoUrl: user.photoUrl,
        sheetsId: user.sheetsId,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      );

  UsersCompanion toCompanion() => UsersCompanion.insert(
        id: id,
        googleId: googleId,
        name: name,
        email: email,
        photoUrl: Value(photoUrl),
        sheetsId: Value(sheetsId),
      );
}
