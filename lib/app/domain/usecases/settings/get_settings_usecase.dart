import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../usecases/usecase.dart';

class GetSettingsUseCase extends UseCase<SettingsEntity, String> {
  final SettingsRepository repository;
  GetSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, SettingsEntity>> call(String userId) =>
      repository.getSettings(userId);
}
