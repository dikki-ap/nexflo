import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ThemeColor {
  teal,
  blue,
  purple,
  green,
  orange,
  pink,
  custom;

  String get value => name;

  static ThemeColor fromValue(String value) =>
      ThemeColor.values.firstWhere((e) => e.name == value,
          orElse: () => ThemeColor.teal);

  Color get color => switch (this) {
        ThemeColor.teal => AppColors.teal,
        ThemeColor.blue => AppColors.blue,
        ThemeColor.purple => AppColors.purple,
        ThemeColor.green => AppColors.green,
        ThemeColor.orange => AppColors.orange,
        ThemeColor.pink => AppColors.pink,
        ThemeColor.custom => AppColors.teal,
      };
}
