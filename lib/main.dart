import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:jisr_platform/core/app_colors.dart';
import 'package:jisr_platform/routes/app_pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Jisr Platform",
      initialRoute: '/login',
      getPages: AppPages.pages,
      theme: ThemeData(
   primaryColor: AppColors.primaryBlue,
  fontFamily: 'Cairo', 
  scaffoldBackgroundColor: AppColors.background,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textDark, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.4),
  ),
      ),
    );
}
}

