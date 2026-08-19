import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/complaints/complaint_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';

typedef ComplaintContextNotFoundCallback = Future<void> Function();

class ComplaintDialog extends GetView<ComplaintController> {
  final String contextType;
  final int contextId;
  final String subjectLabel;
  final ComplaintContextNotFoundCallback? onContextNotFound;

  const ComplaintDialog({
    super.key,
    required this.contextType,
    required this.contextId,
    required this.subjectLabel,
    this.onContextNotFound,
  });

  static Future<bool?> show({
    required String contextType,
    required int contextId,
    required String subjectLabel,
    ComplaintContextNotFoundCallback? onContextNotFound,
  }) {
    if (contextId <= 0) {
      JisrSnackbar.show(
        title: 'تعذر فتح الشكوى',
        message: 'لم يرسل الخادم معرّفاً صالحاً لهذا السياق',
        type: JisrSnackbarType.error,
      );
      return Future<bool?>.value(false);
    }

    final controller = Get.find<ComplaintController>();
    controller.prepare();
    return Get.dialog<bool>(
      ComplaintDialog(
        contextType: contextType,
        contextId: contextId,
        subjectLabel: subjectLabel,
        onContextNotFound: onContextNotFound,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
        contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
        actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.report_problem_rounded,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'إرسال شكوى',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الشكوى على: $subjectLabel',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'اكتب السبب بوضوح. سيتم تحديد الجهة المبلّغ عنها تلقائياً من السياق المختار.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 11.5,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.reasonController,
                    validator: controller.validateReason,
                    onChanged: controller.onReasonChanged,
                    minLines: 4,
                    maxLines: 8,
                    maxLength: 5000,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textDark,
                      fontSize: 13,
                      height: 1.55,
                    ),
                    decoration: InputDecoration(
                      hintText: 'اكتب سبب الشكوى (10 أحرف على الأقل)',
                      hintStyle: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      counterText: '',
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: AppColors.primaryBlue.withOpacity(.10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        '${controller.reasonLength.value}/5000',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textGrey,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.errorMessage.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withOpacity(.08),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: Color(0xFFB91C1C),
                          fontSize: 11.5,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        actions: [
          Obx(
            () => Column(
              children: [
                JisrPrimaryButton(
                  text: controller.isRateLimited
                      ? 'حاول بعد ${controller.cooldownSeconds.value} ثانية'
                      : 'إرسال الشكوى',
                  icon: Icons.send_rounded,
                  height: 52,
                  fontSize: 14,
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.isRateLimited ||
                          controller.isSubmitting.value
                      ? null
                      : () => _submit(context),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pop(false),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final outcome = await controller.submitComplaint(
      contextType: contextType,
      contextId: contextId,
    );

    if (!context.mounted ||
        outcome == ComplaintSubmitOutcome.authenticationRequired) {
      return;
    }
    if (outcome == ComplaintSubmitOutcome.success) {
      Navigator.of(context, rootNavigator: true).pop(true);
      return;
    }
    if (outcome == ComplaintSubmitOutcome.contextNotFound) {
      Navigator.of(context, rootNavigator: true).pop(false);
      await onContextNotFound?.call();
    }
  }
}

class ComplaintActionButton extends StatelessWidget {
  final String contextType;
  final int contextId;
  final String subjectLabel;
  final String label;
  final ComplaintContextNotFoundCallback? onContextNotFound;

  const ComplaintActionButton({
    super.key,
    required this.contextType,
    required this.contextId,
    required this.subjectLabel,
    this.label = 'إرسال شكوى',
    this.onContextNotFound,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: contextId <= 0
            ? null
            : () => ComplaintDialog.show(
                  contextType: contextType,
                  contextId: contextId,
                  subjectLabel: subjectLabel,
                  onContextNotFound: onContextNotFound,
                ),
        icon: const Icon(Icons.report_problem_outlined, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          disabledForegroundColor: AppColors.textGrey.withOpacity(.45),
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(
            color: contextId > 0
                ? const Color(0xFFDC2626).withOpacity(.28)
                : AppColors.textGrey.withOpacity(.12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
