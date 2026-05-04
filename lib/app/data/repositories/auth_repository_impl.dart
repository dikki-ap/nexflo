import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/uuid_helper.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/user_local_ds.dart';
import '../datasources/remote/google_auth_remote_ds.dart';
import '../database/app_database.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GoogleAuthRemoteDataSource _remoteDs;
  final UserLocalDataSource _localDs;

  AuthRepositoryImpl(this._remoteDs, this._localDs);

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final account = await _remoteDs.signIn();
      final companion = UsersCompanion.insert(
        id: UuidHelper.generate(),
        googleId: account.id,
        name: account.displayName ?? account.email.split('@').first,
        email: account.email,
        photoUrl: Value(account.photoUrl),
      );
      final user = await _localDs.upsertUser(companion);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Unexpected auth error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDs.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Sign out failed: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final account = await _remoteDs.signInSilently();
      if (account == null) return const Right(null);
      final user = await _localDs.getUserByGoogleId(account.id);
      return Right(user);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to get current user: $e'));
    }
  }
}
