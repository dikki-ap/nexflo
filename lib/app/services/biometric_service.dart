import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService extends GetxService {
  final _localAuth = LocalAuthentication();
  final _isSupported = false.obs;
  final _isAvailable = false.obs;

  bool get isSupported => _isSupported.value;
  bool get isAvailable => _isAvailable.value;

  Future<BiometricService> init() async {
    _isSupported.value = await _localAuth.isDeviceSupported();
    if (_isSupported.value) {
      _isAvailable.value = await _localAuth.canCheckBiometrics;
    }
    return this;
  }

  Future<bool> authenticate({
    String reason = 'Authenticate to continue',
  }) async {
    if (!_isSupported.value) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
      );
    } catch (_) {
      return false;
    }
  }
}
