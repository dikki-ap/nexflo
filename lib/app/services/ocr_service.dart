import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrParseResult {
  final double? amount;
  final DateTime? date;
  final String? merchant;
  final String rawText;

  const OcrParseResult({
    this.amount,
    this.date,
    this.merchant,
    this.rawText = '',
  });
}

class OcrService extends GetxService {
  Future<OcrParseResult> recognizeAndParse(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final result = await recognizer.processImage(inputImage);
      return parseReceipt(result.text);
    } finally {
      await recognizer.close();
    }
  }

  OcrParseResult parseReceipt(String recognizedText) {
    final amount = _parseAmount(recognizedText);
    final date = _parseDate(recognizedText);
    final merchant = _parseMerchant(recognizedText);

    return OcrParseResult(
      amount: amount,
      date: date,
      merchant: merchant,
      rawText: recognizedText,
    );
  }

  double? _parseAmount(String text) {
    // Match largest currency-like number (e.g. 12,500.00 / 12.500,00 / 12500)
    final patterns = [
      RegExp(r'(?:total|amount|grand total|subtotal)[^\d]*(\d[\d,. ]+)', caseSensitive: false),
      RegExp(r'(\d{1,3}(?:[,.]\d{3})*(?:[,.]\d{2}))'),
      RegExp(r'(\d+[.,]\d{2})'),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      if (matches.isNotEmpty) {
        final raw = matches.last.group(1)?.replaceAll(' ', '').replaceAll(',', '.') ?? '';
        // Handle European format: 1.234,56 → 1234.56
        if (raw.contains(',') && raw.lastIndexOf(',') > raw.lastIndexOf('.')) {
          final normalized = raw.replaceAll('.', '').replaceAll(',', '.');
          final parsed = double.tryParse(normalized);
          if (parsed != null && parsed > 0) return parsed;
        }
        final parsed = double.tryParse(raw);
        if (parsed != null && parsed > 0) return parsed;
      }
    }
    return null;
  }

  DateTime? _parseDate(String text) {
    final patterns = [
      // dd/mm/yyyy or mm/dd/yyyy
      RegExp(r'\b(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})\b'),
      // yyyy/mm/dd
      RegExp(r'\b(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})\b'),
      // dd Month yyyy or Month dd yyyy
      RegExp(
        r'\b(\d{1,2})\s*(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s*(\d{4})\b',
        caseSensitive: false,
      ),
      RegExp(
        r'\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s*(\d{1,2}),?\s*(\d{4})\b',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final parsed = _tryParseMatch(match, pattern.pattern);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  DateTime? _tryParseMatch(RegExpMatch match, String pattern) {
    try {
      if (pattern.startsWith(r'\b(\d{4})')) {
        // yyyy/mm/dd
        final year = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        final day = int.parse(match.group(3)!);
        return DateTime(year, month, day);
      } else if (pattern.contains(r'Jan|Feb')) {
        if (pattern.startsWith(r'\b(\d{1,2})')) {
          // dd Mon yyyy
          final day = int.parse(match.group(1)!);
          final month = _monthFromAbbr(match.group(2)!);
          final year = int.parse(match.group(3)!);
          return month > 0 ? DateTime(year, month, day) : null;
        } else {
          // Mon dd yyyy
          final month = _monthFromAbbr(match.group(1)!);
          final day = int.parse(match.group(2)!);
          final year = int.parse(match.group(3)!);
          return month > 0 ? DateTime(year, month, day) : null;
        }
      } else {
        // dd/mm/yyyy — assume day-first for most locales
        final a = int.parse(match.group(1)!);
        final b = int.parse(match.group(2)!);
        final year = int.parse(match.group(3)!);
        if (a > 12) return DateTime(year, b, a); // must be day first
        return DateTime(year, b, a); // default: dd/mm/yyyy
      }
    } catch (_) {
      return null;
    }
  }

  int _monthFromAbbr(String abbr) {
    const months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };
    return months[abbr.toLowerCase().substring(0, 3)] ?? 0;
  }

  String? _parseMerchant(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !RegExp(r'^\d').hasMatch(l))
        .toList();
    return lines.isNotEmpty ? lines.first : null;
  }
}
