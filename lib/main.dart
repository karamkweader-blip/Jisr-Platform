import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/app_theme_controller.dart';
import 'package:jisr_platform/core/theme/app_theme.dart';
import 'package:jisr_platform/firebase_options.dart';
import 'package:jisr_platform/routes/app_pages.dart';
import 'package:jisr_platform/services/auth/token&role_manage/initial_route_service.dart';
import 'package:jisr_platform/services/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // تحميل المظهر قبل تشغيل الواجهة لمنع ظهور Light Theme للحظة.
  final appThemeController =
      await AppThemeController().initialize();

  Get.put<AppThemeController>(
    appThemeController,
    permanent: true,
  );

  final initialRoute =
      await InitialRouteService().getInitialRoute();

  runApp(
    MyApp(
      initialRoute: initialRoute,
    ),
  );

  await NotificationService.instance.initialize();
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    final themeController =
        Get.find<AppThemeController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jisr Platform',
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode.value,
    );
  }
}