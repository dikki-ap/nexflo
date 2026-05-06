import 'package:flutter/material.dart';

// isDarkMode, theme, textTheme are provided by GetX's BuildContext extension.
// Defining them here too causes ambiguity errors — keep them out of this file.
extension ContextExtension on BuildContext {
  // ── Screen metrics ───────────────────────────────────────
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  // ── Responsive breakpoints ───────────────────────────────
  bool get isSmallPhone => screenWidth < 360;
  bool get isTablet => screenWidth >= 600;

  double get horizontalPadding => isSmallPhone ? 16.0 : isTablet ? 32.0 : 20.0;
  double get cardBorderRadius => isSmallPhone ? 16.0 : 20.0;

  int get planningGridCount => isTablet ? 4 : 2;

  double responsiveValue(double small, double medium, {double? large}) {
    if (isSmallPhone) return small;
    if (isTablet) return large ?? medium;
    return medium;
  }

  // ── Snackbar ─────────────────────────────────────────────
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Theme.of(this).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(
          bottom: 16,
          left: horizontalPadding,
          right: horizontalPadding,
        ),
      ),
    );
  }
}
