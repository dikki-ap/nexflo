import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/enums/theme_color.dart';
import '../../core/utils/color_helper.dart';

class AppThemeController extends GetxController {
  static const _keyThemeMode = 'theme_mode';
  static const _keyThemeColor = 'theme_color';
  static const _keyThemeCustomHex = 'theme_custom_hex';

  final _themeMode = ThemeMode.system.obs;
  final _themeColor = ThemeColor.teal.obs;
  final _customHex = ''.obs;

  ThemeMode get themeMode => _themeMode.value;
  ThemeColor get themeColorEnum => _themeColor.value;
  Color get accentColor {
    if (_themeColor.value == ThemeColor.custom && _customHex.value.isNotEmpty) {
      return ColorHelper.fromHex(_customHex.value);
    }
    return _themeColor.value.color;
  }

  @override
  void onInit() {
    super.onInit();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_keyThemeMode) ?? 'system';
    final colorStr = prefs.getString(_keyThemeColor) ?? 'teal';
    final customHex = prefs.getString(_keyThemeCustomHex) ?? '';

    _themeMode.value = switch (modeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _themeColor.value = ThemeColor.fromValue(colorStr);
    _customHex.value = customHex;
    update();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await prefs.setString(_keyThemeMode, modeStr);
    update();
    Get.changeThemeMode(mode);
  }

  Future<void> setThemeColor(ThemeColor color, {String? customHex}) async {
    _themeColor.value = color;
    if (customHex != null) _customHex.value = customHex;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeColor, color.value);
    if (customHex != null) {
      await prefs.setString(_keyThemeCustomHex, customHex);
    }
    update();
  }

  Color get incomeColor => AppColors.income;
  Color get expenseColor => AppColors.expense;
  Color get transferColor => AppColors.transfer;
}
