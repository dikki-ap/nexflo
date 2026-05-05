import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../services/ocr_service.dart';

class ReceiptScanController extends GetxController {
  final _imagePath = Rxn<String>();
  final _isProcessing = false.obs;
  final _result = Rxn<OcrParseResult>();
  final _error = ''.obs;

  String? get imagePath => _imagePath.value;
  bool get isProcessing => _isProcessing.value;
  OcrParseResult? get result => _result.value;
  String get error => _error.value;

  final _picker = ImagePicker();
  OcrService get _ocr => Get.find<OcrService>();

  Future<void> pickFromCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      Get.snackbar('Permission Denied', 'Camera access is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    await _pick(ImageSource.camera);
  }

  Future<void> pickFromGallery() async {
    await _pick(ImageSource.gallery);
  }

  Future<void> _pick(ImageSource source) async {
    _error.value = '';
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (file == null) return;

    _imagePath.value = file.path;
    _isProcessing.value = true;
    try {
      _result.value = await _ocr.recognizeAndParse(file.path);
    } catch (e) {
      _error.value = 'Could not read receipt. Try a clearer image.';
    } finally {
      _isProcessing.value = false;
    }
  }

  void useResult() {
    Get.back(result: _result.value);
  }

  void retry() {
    _imagePath.value = null;
    _result.value = null;
    _error.value = '';
  }

  Color amountConfidenceColor(BuildContext context) {
    final r = _result.value;
    if (r == null || r.amount == null) return Colors.red;
    return Colors.green;
  }
}
