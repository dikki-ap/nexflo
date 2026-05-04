import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard/pages/dashboard_page.dart';
import 'main_nav_controller.dart';

class MainNavPage extends GetView<MainNavController> {
  const MainNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              DashboardPage(),
              _PlaceholderPage('Transactions'),
              _PlaceholderPage('Statistics'),
              _PlaceholderPage('Settings'),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: (i) {
              if (i == 2) return; // FAB tap — handled separately
              controller.changePage(i);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Statistics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // TODO(phase-2): navigate to transaction add page
            },
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ));
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\n(Coming in Phase 2)',
          textAlign: TextAlign.center,
          style: TextStyle(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}
