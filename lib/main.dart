import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/routes/app_pages.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/auth_service.dart';
import 'package:jisr_platform/services/home/home_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final token = await AuthService().getToken();

  runApp(MyApp(initialRoute: token == null ? Routes.login : Routes.home));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Jisr Platform",
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: AppColors.background,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.textDark,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.textGrey,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
