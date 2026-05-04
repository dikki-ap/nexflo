import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final _isOnline = true.obs;
  bool get isOnline => _isOnline.value;

  Future<ConnectivityService> init() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline.value = _hasConnection(result);

    Connectivity().onConnectivityChanged.listen((results) {
      _isOnline.value = _hasConnection(results);
    });

    return this;
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
