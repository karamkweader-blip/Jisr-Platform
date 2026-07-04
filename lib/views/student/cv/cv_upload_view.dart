import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/cv/cv_upload_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';
import 'package:jisr_platform/core/widgets/jisr_bottom_nav.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';

class CvUploadView extends GetView<CvUploadController> {
  const CvUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        bottomNavigationBar: const StudentBottomNav(currentIndex: 2),
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          title: const Text(
            'رفع السيرة الذاتية',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: -35,
                        top: -35,
                        child: _GlowCircle(size: 120),
                      ),
                      Positioned(
                        right: -20,
                        bottom: -35,
                        child: _GlowCircle(size: 90),
                      ),
                      Column(
                        children: [
                          Container(
                            height: 96,
                            width: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: AppColors.actionYellow,
                              size: 52,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'خلّي فرصك أقرب',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'ارفع CV الخاص بك بصيغة PDF أو Word ليكون جاهزاً عند التقديم على الفرص.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Obx(
                  () => GestureDetector(
                    onTap: controller.isLoading.value
                        ? null
                        : controller.pickCvFile,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          width: 1.4,
                          color: controller.selectedFile.value == null
                              ? AppColors.primaryBlue.withOpacity(0.12)
                              : AppColors.actionYellow,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: controller.selectedFile.value == null
                          ? const _EmptyFileState()
                          : _SelectedFileState(
                              fileName: controller.selectedFile.value!.name,
                              onRemove: controller.removeFile,
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                Obx(
                  () => JisrPrimaryButton(
                    text: 'إرسال السيرة الذاتية',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.uploadCv,
                  ),
                ),

                const SizedBox(height: 20),

                Obx(() {
                  final cv = controller.uploadedCv.value;

                  if (cv == null) return const SizedBox.shrink();

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.actionYellow.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.actionYellow.withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.actionYellow,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'تم رفع CV بنجاح - رقم الملف: ${cv.cvId}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;

  const _GlowCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.08),
      ),
    );
  }
}

class _EmptyFileState extends StatelessWidget {
  const _EmptyFileState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 82,
          width: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryBlue.withOpacity(0.08),
          ),
          child: const Icon(
            Icons.cloud_upload_rounded,
            color: AppColors.primaryBlue,
            size: 46,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'اضغطي لاختيار ملف CV',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.primaryBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          '',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textGrey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _SelectedFileState extends StatelessWidget {
  final String fileName;
  final VoidCallback onRemove;

  const _SelectedFileState({required this.fileName, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 62,
          width: 62,
          decoration: BoxDecoration(
            color: AppColors.actionYellow.withOpacity(0.15),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.insert_drive_file_outlined,
            color: AppColors.actionYellow,
            size: 32,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            fileName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
        ),
      ],
    );
  }
}
