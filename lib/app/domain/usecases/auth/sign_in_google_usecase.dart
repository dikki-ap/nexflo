import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class SignInGoogleUseCase extends UseCase<UserEntity, NoParams> {
  final AuthRepository repository;
  SignInGoogleUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) =>
      repository.signInWithGoogle();
}
