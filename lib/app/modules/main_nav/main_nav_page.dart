import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../dashboard/pages/dashboard_page.dart';
import '../transaction/pages/transaction_list_page.dart';
import '../statistics/pages/statistics_page.dart';
import '../settings/pages/settings_page.dart';
import '../../config/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/modern_bottom_nav.dart';
import 'main_nav_controller.dart';

class MainNavPage extends GetView<MainNavController> {
  const MainNavPage({super.key});

  static const _pages = [
    DashboardPage(),
    TransactionListPage(),
    StatisticsPage(),
    SettingsPage(),
  ];

  static const _navItems = [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Transactions',
    ),
    NavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Statistics',
    ),
    NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: _pages,
          )),
      bottomNavigationBar: Obx(() => ModernBottomNav(
            items: _navItems,
            currentIndex: controller.currentIndex.value,
            onTap: (i) {
              HapticFeedback.selectionClick();
              controller.changePage(i);
            },
            onFabTap: () {
              HapticFeedback.mediumImpact();
              Get.toNamed(AppRoutes.transactionAdd);
            },
          )),
    );
  }
}
