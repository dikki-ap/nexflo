import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../usecases/usecase.dart';

class SignInGoogleUseCase extends UseCase<UserEntity, NoParams> {
  final AuthRepository repository;
  SignInGoogleUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) =>
      repository.signInWithGoogle();
}
