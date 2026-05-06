import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';

import 'app/config/routes/app_pages.dart';
import 'app/config/routes/app_routes.dart';
import 'app/config/theme/app_theme.dart';
import 'app/config/theme/app_theme_controller.dart';
import 'app/data/database/app_database.dart';
import 'app/services/auth_service.dart';
import 'app/services/biometric_service.dart';
import 'app/services/connectivity_service.dart';
import 'app/services/currency_service.dart';
import 'app/services/notification_service.dart';
import 'app/services/ocr_service.dart';
import 'app/services/recurring_service.dart';
import 'app/services/sync_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final db = AppDatabase();
    final syncService = SyncService(db);
    await syncService.sync();
    await db.close();
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    'nexflo-background-sync',
    'backgroundSync',
    frequency: const Duration(minutes: 30),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  await _initServices();
  runApp(const NexFloApp());
}

Future<void> _initServices() async {
  final db = Get.put(AppDatabase());
  await Get.putAsync(() async => ConnectivityService().init());
  await Get.putAsync(() async => AuthService().init());
  await Get.putAsync(() async => CurrencyService(db).init());
  await Get.putAsync(() async => SyncService(db).init());
  await Get.putAsync(() async => RecurringService(db).init());
  await Get.putAsync(() async => NotificationService().init());
  await Get.putAsync(() async => BiometricService().init());
  Get.put(OcrService());
  Get.put(AppThemeController());
}

class NexFloApp extends StatelessWidget {
  const NexFloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppThemeController>(
      builder: (themeCtrl) => GetMaterialApp(
        title: 'NexFlo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(themeCtrl.accentColor),
        darkTheme: AppTheme.darkTheme(themeCtrl.accentColor),
        themeMode: themeCtrl.themeMode,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
