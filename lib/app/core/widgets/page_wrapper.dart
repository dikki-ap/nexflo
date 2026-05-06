import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Consistent page scaffold with gradient or flat background.
/// Handles safe area, keyboard avoidance, and optional gradient bg.
class PageWrapper extends StatelessWidget {
  const PageWrapper({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
    this.withGradientBg = false,
    this.padding,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final bool withGradientBg;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget body = padding != null ? Padding(padding: padding!, child: child) : child;

    if (withGradientBg) {
      body = DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.darkBg, const Color(0xFF0D2B3D), AppColors.darkBg]
                : [AppColors.lightBg, const Color(0xFFE0F7FA), AppColors.lightBg],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: body,
      );
    }

    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: withGradientBg
          ? (isDark ? AppColors.darkBg : AppColors.lightBg)
          : null,
    );
  }
}
