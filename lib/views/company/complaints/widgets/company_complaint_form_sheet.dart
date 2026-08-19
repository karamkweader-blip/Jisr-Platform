import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/company/complaints/company_complaint_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/complaints/company_complaint_service.dart';

Future<CompanyComplaintModel?> showCompanyComplaintForm({
  required BuildContext context,
  required String contextType,
  required int contextId,
  required String subjectName,
  Future<void> Function()? onSourceNotFound,
}) async {
  final result =
      await showModalBottomSheet<CompanyComplaintModel>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _CompanyComplaintFormSheet(
        service: Get.find<CompanyComplaintService>(),
        authService: Get.find<AuthService>(),
        contextType: contextType,
        contextId: contextId,
        subjectName: subjectName,
        onSourceNotFound: onSourceNotFound,
      );
    },
  );

  if (result != null) {
    JisrSnackbar.show(
      title: 'تم إرسال الشكوى',
      message:
          'وصلت شكواك إلى الإدارة وأصبحت قيد المراجعة',
      type: JisrSnackbarType.success,
    );
  }

  return result;
}

class _CompanyComplaintFormSheet
    extends StatefulWidget {
  final CompanyComplaintService service;
  final AuthService authService;
  final String contextType;
  final int contextId;
  final String subjectName;
  final Future<void> Function()? onSourceNotFound;

  const _CompanyComplaintFormSheet({
    required this.service,
    required this.authService,
    required this.contextType,
    required this.contextId,
    required this.subjectName,
    required this.onSourceNotFound,
  });

  @override
  State<_CompanyComplaintFormSheet> createState() {
    return _CompanyComplaintFormSheetState();
  }
}

class _CompanyComplaintFormSheetState
    extends State<_CompanyComplaintFormSheet> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _reasonController =
      TextEditingController();

  bool _isSubmitting = false;
  bool _showValidation = false;
  String? _reasonError;
  String? _generalError;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset =
        MediaQuery.viewInsetsOf(context).bottom;

    final subjectName =
        widget.subjectName.trim().isEmpty
            ? 'الطالب المحدد'
            : widget.subjectName.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: !_isSubmitting,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding:
              EdgeInsets.only(bottom: keyboardInset),
          child: Material(
            color: AppColors.background,
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  20,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _showValidation
                      ? AutovalidateMode
                          .onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.textGrey
                                .withOpacity(0.20),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors
                                  .actionYellow
                                  .withOpacity(0.11),
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                              border: Border.all(
                                color: AppColors
                                    .actionYellow
                                    .withOpacity(0.18),
                              ),
                            ),
                            child: const Icon(
                              Icons
                                  .report_gmailerrorred_rounded,
                              color:
                                  AppColors.actionYellow,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: <Widget>[
                                const Text(
                                  'إرسال شكوى',
                                  style: TextStyle(
                                    color: AppColors
                                        .textDark,
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  CompanyComplaintContextTypes
                                      .label(
                                    widget.contextType,
                                  ),
                                  style:
                                      const TextStyle(
                                    color: AppColors
                                        .textGrey,
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'إغلاق',
                            onPressed: _isSubmitting
                                ? null
                                : () {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                  },
                            icon: const Icon(
                              Icons.close_rounded,
                            ),
                            color: AppColors.textGrey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue
                              .withOpacity(0.055),
                          borderRadius:
                              BorderRadius.circular(
                            17,
                          ),
                          border: Border.all(
                            color: AppColors
                                .primaryBlue
                                .withOpacity(0.09),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.person_outline_rounded,
                              color:
                                  AppColors.primaryBlue,
                              size: 21,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: <Widget>[
                                  const Text(
                                    'سيتم الإبلاغ ضمن السياق الحالي',
                                    style: TextStyle(
                                      color: AppColors
                                          .textGrey,
                                      fontSize: 10.5,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    subjectName,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color: AppColors
                                          .textDark,
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'سبب الشكوى',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'اشرح المشكلة بوضوح لتساعد الإدارة على مراجعتها.',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 11.5,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 11),
                      TextFormField(
                        controller: _reasonController,
                        enabled: !_isSubmitting,
                        minLines: 5,
                        maxLines: 8,
                        maxLength: 5000,
                        textInputAction:
                            TextInputAction.newline,
                        validator: _validateReason,
                        onChanged: (_) {
                          if (_reasonError == null &&
                              _generalError == null) {
                            return;
                          }

                          setState(() {
                            _reasonError = null;
                            _generalError = null;
                          });
                        },
                        decoration: InputDecoration(
                          hintText:
                              'اكتب تفاصيل الموقف وما الذي تتوقعه من الإدارة...',
                          errorText: _reasonError,
                          filled: true,
                          fillColor:
                              AppColors.cardWhite,
                          alignLabelWithHint: true,
                          counterStyle:
                              const TextStyle(
                            color:
                                AppColors.textGrey,
                            fontSize: 10,
                          ),
                          hintStyle: TextStyle(
                            color: AppColors.textGrey
                                .withOpacity(0.68),
                            fontSize: 12.5,
                            height: 1.5,
                          ),
                          contentPadding:
                              const EdgeInsets.all(
                            15,
                          ),
                          enabledBorder: _border(
                            AppColors.textGrey
                                .withOpacity(0.16),
                          ),
                          disabledBorder: _border(
                            AppColors.textGrey
                                .withOpacity(0.10),
                          ),
                          focusedBorder: _border(
                            AppColors.primaryBlue,
                            width: 1.5,
                          ),
                          errorBorder: _border(
                            AppColors.dangerRed,
                          ),
                          focusedErrorBorder: _border(
                            AppColors.dangerRed,
                            width: 1.5,
                          ),
                        ),
                      ),
                      if (_generalError !=
                          null) ...<Widget>[
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(
                            12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.dangerRed
                                .withOpacity(0.06),
                            borderRadius:
                                BorderRadius.circular(
                              13,
                            ),
                            border: Border.all(
                              color: AppColors
                                  .dangerRed
                                  .withOpacity(0.13),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: <Widget>[
                              const Icon(
                                Icons
                                    .error_outline_rounded,
                                color: AppColors
                                    .dangerRed,
                                size: 19,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _generalError!,
                                  style:
                                      const TextStyle(
                                    color: AppColors
                                        .dangerRed,
                                    fontSize: 11.5,
                                    height: 1.45,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 51,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : _submit,
                          style:
                              ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                AppColors.primaryBlue,
                            foregroundColor:
                                AppColors.onPrimary,
                            disabledBackgroundColor:
                                AppColors.primaryBlue
                                    .withOpacity(0.55),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                15,
                              ),
                            ),
                          ),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors
                                        .onPrimary,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  size: 19,
                                ),
                          label: Text(
                            _isSubmitting
                                ? 'جارٍ الإرسال...'
                                : 'إرسال الشكوى',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  String? _validateReason(String? value) {
    final reason = value?.trim() ?? '';

    if (reason.isEmpty) {
      return 'سبب الشكوى مطلوب';
    }

    if (reason.length < 10) {
      return 'اكتب سببًا أوضح من 10 أحرف على الأقل';
    }

    if (reason.length > 5000) {
      return 'سبب الشكوى يجب ألا يتجاوز 5000 حرف';
    }

    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() {
      _showValidation = true;
      _reasonError = null;
      _generalError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final complaint =
          await widget.service.submitComplaint(
        contextType: widget.contextType,
        contextId: widget.contextId,
        reason: _reasonController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pop(complaint);
    } on CompanyComplaintApiException catch (error) {
      if (!mounted) return;

      if (error.statusCode == 401) {
        Navigator.of(context).pop();

        await widget.authService.removeAuthData();

        Get.offAllNamed(Routes.login);
        return;
      }

      if (error.statusCode == 404) {
        Navigator.of(context).pop();

        await widget.onSourceNotFound?.call();

        JisrSnackbar.show(
          title: 'العنصر غير متاح',
          message: error.message,
          type: JisrSnackbarType.error,
        );
        return;
      }

      setState(() {
        _reasonError =
            error.fieldMessage('reason');

        _generalError = _reasonError == null
            ? error.message
            : null;
      });

      if (error.statusCode == 429) {
        JisrSnackbar.show(
          title: 'محاولات متكررة',
          message: error.message,
          type: JisrSnackbarType.warning,
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _generalError = error
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst(
              'TimeoutException: ',
              '',
            );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}