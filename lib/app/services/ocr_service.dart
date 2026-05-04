import 'package:get/get.dart';

class OcrParseResult {
  final double? amount;
  final DateTime? date;
  final String? merchant;

  const OcrParseResult({this.amount, this.date, this.merchant});
}

class OcrService extends GetxService {
  // TODO(phase-6): implement ML Kit OCR for receipt scanning
  Future<OcrParseResult> parseReceipt(String recognizedText) async {
    double? amount;
    DateTime? date;
    String? merchant;

    final amountMatch =
        RegExp(r'\d+[.,]\d{2}').allMatches(recognizedText).lastOrNull;
    if (amountMatch != null) {
      amount = double.tryParse(
          amountMatch.group(0)?.replaceAll(',', '.') ?? '');
    }

    final lines =
        recognizedText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) merchant = lines.first.trim();

    return OcrParseResult(amount: amount, date: date, merchant: merchant);
  }
}
