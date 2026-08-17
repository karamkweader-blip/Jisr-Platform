import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/complaints/complaint_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/student/complaints/complaint_service.dart';

enum ComplaintSubmitOutcome {
  success,
  failed,
  contextNotFound,
  authenticationRequired,
}

class ComplaintController extends GetxController {
  final ComplaintService _service = ComplaintService();
  final AuthService _authService = AuthService();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController reasonController = TextEditingController();
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt reasonLength = 0.obs;
  final RxInt cooldownSeconds = 0.obs;

  Timer? _cooldownTimer;

  bool get isRateLimited => cooldownSeconds.value > 0;

  void prepare() {
    reasonController.clear();
    reasonLength.value = 0;
    errorMessage.value = '';
  }

  void onReasonChanged(String value) {
    reasonLength.value = value.trim().length;
    if (errorMessage.value.isNotEmpty) errorMessage.value = '';
  }

  String? validateReason(String? value) {
    final reason = value?.trim() ?? '';
    if (reason.isEmpty) return 'سبب الشكوى مطلوب';
    if (reason.length < 10) return 'يجب ألا يقل سبب الشكوى عن 10 أحرف';
    if (reason.length > 5000) return 'يجب ألا يزيد سبب الشكوى عن 5000 حرف';
    return null;
  }

  Future<ComplaintSubmitOutcome> submitComplaint({
    required String contextType,
    required int contextId,
  }) async {
    if (isSubmitting.value || isRateLimited) {
      return ComplaintSubmitOutcome.failed;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) {
      return ComplaintSubmitOutcome.failed;
    }
    if (!ComplaintContextTypes.values.contains(contextType) || contextId <= 0) {
      errorMessage.value = 'لا يمكن إرسال الشكوى لأن معرّف السياق غير صالح';
      return ComplaintSubmitOutcome.failed;
    }

    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      final response = await _service.submitComplaint(
        ComplaintRequestModel(
          contextType: contextType,
          contextId: contextId,
          reason: reasonController.text,
        ),
      );

      JisrSnackbar.show(
        title: 'تم إرسال الشكوى',
        message: response.message,
        type: JisrSnackbarType.success,
      );
      return ComplaintSubmitOutcome.success;
    } on ComplaintApiException catch (error) {
      if (error.statusCode == 401) {
        await _authService.removeAuthData();
        Get.offAllNamed(Routes.login);
        return ComplaintSubmitOutcome.authenticationRequired;
      }

      errorMessage.value = error.message;
      if (error.statusCode == 404) {
        return ComplaintSubmitOutcome.contextNotFound;
      }
      if (error.statusCode == 429) {
        _startCooldown(error.retryAfterSeconds ?? 60);
      }
      return ComplaintSubmitOutcome.failed;
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
      return ComplaintSubmitOutcome.failed;
    } finally {
      isSubmitting.value = false;
    }
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    cooldownSeconds.value = seconds.clamp(1, 3600).toInt();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldownSeconds.value <= 1) {
        cooldownSeconds.value = 0;
        timer.cancel();
        return;
      }
      cooldownSeconds.value--;
    });
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    reasonController.dispose();
    super.onClose();
  }
}
