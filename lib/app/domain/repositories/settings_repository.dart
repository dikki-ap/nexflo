import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, SettingsEntity>> getSettings(String userId);
  Future<Either<Failure, SettingsEntity>> createDefaultSettings(String userId);
  Future<Either<Failure, SettingsEntity>> updateSettings(
      SettingsEntity settings);
}
