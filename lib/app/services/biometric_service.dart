import 'package:get/get.dart';

class BiometricService extends GetxService {
  final _isAvailable = false.obs;
  bool get isAvailable => _isAvailable.value;

  Future<BiometricService> init() async {
    // TODO(phase-6): check local_auth availability
    return this;
  }

  // TODO(phase-6): implement biometric + PIN authentication
  Future<bool> authenticate({String reason = 'Authenticate to continue'}) async =>
      true;
}
