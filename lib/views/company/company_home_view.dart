import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/company_home_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class CompanyHomeView extends GetView<CompanyHomeController> {
  const CompanyHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Company Home',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}