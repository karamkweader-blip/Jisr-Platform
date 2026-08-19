import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunity_interview_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class CompanyOpportunityInterviewView extends GetView<CompanyOpportunityInterviewController> {
  const CompanyOpportunityInterviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final blueContainer = baseTheme.brightness == Brightness.dark
        ? const Color(0xFF123F5E)
        : const Color(0xFFDCEFFD);

    return Theme(
      data: baseTheme.copyWith(
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: AppColors.primaryBlue,
          onPrimary: Colors.white,
          primaryContainer: blueContainer,
          onPrimaryContainer: AppColors.primaryBlue,
          secondary: AppColors.primaryBlue,
          onSecondary: Colors.white,
          secondaryContainer: blueContainer,
          onSecondaryContainer: AppColors.primaryBlue,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(controller.isReschedule ? 'إعادة جدولة المقابلة' : 'جدولة مقابلة')),
        body: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text('نوع المقابلة', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Obx(() => SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'online', label: Text('أونلاين'), icon: Icon(Icons.videocam_outlined)),
                      ButtonSegment(value: 'onsite', label: Text('حضوري'), icon: Icon(Icons.location_on_outlined)),
                      ButtonSegment(value: 'phone', label: Text('هاتف'), icon: Icon(Icons.phone_outlined)),
                    ],
                    selected: {controller.meetingType.value},
                    onSelectionChanged: (value) => controller.setMeetingType(value.first),
                  )),
              const SizedBox(height: 16),
              Obx(() => ListTile(
                    tileColor: AppColors.cardWhite,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    leading: const Icon(Icons.schedule_rounded, color: AppColors.primaryBlue),
                    title: const Text('التاريخ والوقت'),
                    subtitle: Text(controller.formattedSchedule),
                    onTap: () => controller.pickSchedule(context),
                  )),
              const SizedBox(height: 12),
              Obx(() => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: controller.meetingType.value == 'online'
                        ? _field(controller.linkController, 'رابط الاجتماع', validator: controller.validateLink, keyboard: TextInputType.url, key: const ValueKey('link'))
                        : controller.meetingType.value == 'onsite'
                            ? _field(controller.locationController, 'موقع المقابلة', validator: controller.validateLocation, key: const ValueKey('location'))
                            : const SizedBox.shrink(key: ValueKey('phone')),
                  )),
              _field(controller.notesController, 'ملاحظات (اختياري)', lines: 4),
              const SizedBox(height: 18),
              Obx(() => FilledButton(
                    onPressed: controller.isSubmitting.value ? null : controller.submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: controller.isSubmitting.value
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(controller.isReschedule ? 'حفظ الموعد الجديد' : 'جدولة وفتح المحادثة'),
                    ),
                  )),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController textController, String label, {String? Function(String?)? validator, int lines = 1, TextInputType? keyboard, Key? key}) => Padding(
    key: key,
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(controller: textController, maxLines: lines, keyboardType: keyboard, validator: validator, decoration: InputDecoration(labelText: label, filled: true, fillColor: AppColors.cardWhite, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
  );
}
