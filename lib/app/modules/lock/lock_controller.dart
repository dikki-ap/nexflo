import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../config/routes/app_routes.dart';
import '../../data/database/app_database.dart';
import '../../data/datasources/local/settings_local_ds.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';

class LockController extends GetxController {
  final _pin = ''.obs;
  final _isError = false.obs;
  final _isBiometricAttempting = false.obs;
  final _isPinEnabled = false.obs;
  final _isBiometricEnabled = false.obs;

  String get pin => _pin.value;
  bool get isError => _isError.value;
  bool get isBiometricAttempting => _isBiometricAttempting.value;
  bool get isPinEnabled => _isPinEnabled.value;
  bool get isBiometricEnabled => _isBiometricEnabled.value;

  String? _storedPinHash;

  BiometricService get _biometric => Get.find<BiometricService>();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final auth = Get.find<AuthService>();
    if (auth.currentUser == null) return;

    final db = Get.find<AppDatabase>();
    final settingsDs = SettingsLocalDataSource(db);
    final settings = await settingsDs.getByUserId(auth.currentUser!.id);

    _storedPinHash = settings?.pinHash;
    _isPinEnabled.value = settings?.isPinEnabled ?? false;
    _isBiometricEnabled.value = settings?.isBiometricEnabled ?? false;

    if (_isBiometricEnabled.value && _biometric.isAvailable) {
      await _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    _isBiometricAttempting.value = true;
    final success = await _biometric.authenticate(reason: 'Unlock NexFlo');
    _isBiometricAttempting.value = false;
    if (success) _unlock();
  }

  void addDigit(String digit) {
    if (_pin.value.length >= 6) return;
    _isError.value = false;
    _pin.value = _pin.value + digit;
    HapticFeedback.selectionClick();
    if (_pin.value.length >= 4) {
      _verifyPin();
    }
  }

  void removeDigit() {
    if (_pin.value.isEmpty) return;
    _pin.value = _pin.value.substring(0, _pin.value.length - 1);
  }

  void _verifyPin() {
    if (_storedPinHash == null) {
      _unlock();
      return;
    }
    final inputHash = sha256.convert(utf8.encode(_pin.value)).toString();
    if (inputHash == _storedPinHash) {
      _unlock();
    } else if (_pin.value.length >= 4) {
      _pin.value = '';
      _isError.value = true;
      HapticFeedback.vibrate();
    }
  }

  Future<void> retryBiometric() => _tryBiometric();

  void _unlock() => Get.offAllNamed(AppRoutes.main);
}
