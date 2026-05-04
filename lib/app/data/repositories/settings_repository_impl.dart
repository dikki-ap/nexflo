import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/settings_local_ds.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDs;
  SettingsRepositoryImpl(this._localDs);

  @override
  Future<Either<Failure, SettingsEntity>> getSettings(String userId) async {
    try {
      final settings = await _localDs.getByUserId(userId);
      if (settings == null) return createDefaultSettings(userId);
      return Right(settings);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> createDefaultSettings(
      String userId) async {
    try {
      final settings = await _localDs.createDefault(userId);
      return Right(settings);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> updateSettings(
      SettingsEntity settings) async {
    try {
      final model = SettingsModel(
        id: settings.id,
        userId: settings.userId,
        baseCurrencyCode: settings.baseCurrencyCode,
        cutoffDate: settings.cutoffDate,
        themeMode: settings.themeMode,
        themeColor: settings.themeColor,
        themeCustomHex: settings.themeCustomHex,
        isBiometricEnabled: settings.isBiometricEnabled,
        isPinEnabled: settings.isPinEnabled,
        pinHash: settings.pinHash,
        sheetsSpreadsheetId: settings.sheetsSpreadsheetId,
        lastSyncAt: settings.lastSyncAt,
        syncEnabled: settings.syncEnabled,
        notificationBudgetAlert: settings.notificationBudgetAlert,
        notificationRecurringReminder: settings.notificationRecurringReminder,
        notificationDebtReminder: settings.notificationDebtReminder,
      );
      final updated = await _localDs.update(model);
      return Right(updated);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }
}
