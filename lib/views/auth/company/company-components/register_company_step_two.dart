import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/register_company_controller.dart';
import 'package:jisr_platform/core/validators/app_validators.dart';
import 'package:jisr_platform/core/widgets/jisr_text_field.dart';

class RegisterCompanyStepTwo
    extends GetView<RegisterCompanyController> {
  const RegisterCompanyStepTwo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Form(
      key: controller.stepTwoFormKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الشركة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف المجال والموقع الإلكتروني ومكان الشركة لإكمال الملف.',
            style: TextStyle(
              fontSize: 14,
              color:
                  colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          JisrTextField(
            controller: controller
                .companyFieldController,
            hintText: 'مجال الشركة',
            icon: Icons.work_outline,
            textInputAction:
                TextInputAction.next,
            validator:
                AppValidators.companyField,
          ),
          JisrTextField(
            controller:
                controller.locationController,
            hintText: 'الموقع',
            icon:
                Icons.location_on_outlined,
            textInputAction:
                TextInputAction.next,
            validator:
                AppValidators.location,
          ),
          JisrTextField(
            controller:
                controller.websiteController,
            hintText: 'الموقع الإلكتروني',
            icon: Icons.language,
            keyboardType:
                TextInputType.url,
            textInputAction:
                TextInputAction.done,
            validator:
                AppValidators.website,
          ),
        ],
      ),
    );
  }
}