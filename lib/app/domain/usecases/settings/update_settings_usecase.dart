import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../usecases/usecase.dart';

class UpdateSettingsUseCase extends UseCase<SettingsEntity, SettingsEntity> {
  final SettingsRepository repository;
  UpdateSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, SettingsEntity>> call(SettingsEntity settings) =>
      repository.updateSettings(settings);
}
