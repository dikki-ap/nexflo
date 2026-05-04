import 'package:flutter/material.dart';

class ColorHelper {
  ColorHelper._();

  static Color fromHex(String hex) {
    final sanitized = hex.replaceAll('#', '').trim();
    if (sanitized.length == 6) {
      return Color(int.parse('FF$sanitized', radix: 16));
    }
    if (sanitized.length == 8) {
      return Color(int.parse(sanitized, radix: 16));
    }
    return Colors.grey;
  }

  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
