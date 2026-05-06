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

  // 4 visible nav items — center FAB slot handled by ModernBottomNav (onFabTap).
  // With 4 items, items.length ~/ 2 = 2, so index 2 becomes the FAB slot.
  // Pages: 0=Dashboard, 1=Transactions, 2=Statistics, 3=Settings
  // Nav slots: 0=Home, 1=Transactions, [2=FAB], 3=Statistics (items[2]), 4=Settings (items[3])
  // We pass only 4 items; FAB replaces slot 2 visually.
  // To keep Statistics/Settings selectable, we remap page indices ↔ nav active indices.
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

  /// Map page index (0–3) → nav highlight index (0–4, skipping slot 2 = FAB).
  static int _pageToNav(int page) => page < 2 ? page : page + 1;

  /// Map nav tap index → page index. Returns -1 for the FAB slot (index 2).
  static int _navToPage(int nav) {
    if (nav == 2) return -1; // FAB slot
    return nav < 2 ? nav : nav - 1;
  }

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
            currentIndex: _pageToNav(controller.currentIndex.value),
            onTap: (navIdx) {
              final page = _navToPage(navIdx);
              if (page >= 0) {
                HapticFeedback.selectionClick();
                controller.changePage(page);
              }
            },
            onFabTap: () {
              HapticFeedback.mediumImpact();
              Get.toNamed(AppRoutes.transactionAdd);
            },
          )),
    );
  }
}
