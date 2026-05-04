import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String googleId;
  final String name;
  final String email;
  final String? photoUrl;
  final String? sheetsId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.googleId,
    required this.name,
    required this.email,
    this.photoUrl,
    this.sheetsId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, googleId, name, email, photoUrl, sheetsId];
}
