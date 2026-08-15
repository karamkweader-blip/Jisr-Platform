import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/assigned_tasks/student_assigned_task_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/student/assigned_tasks/student_assigned_task_model.dart';

class StudentEvaluationAppealsView
    extends GetView<StudentAssignedTaskController> {
  const StudentEvaluationAppealsView({super.key});

  static const Map<String, String> _filters = <String, String>{
    'all': 'الكل',
    'pending': 'قيد المراجعة',
    'accepted': 'مقبول',
    'rejected': 'مرفوض',
    'cancelled': 'ملغي',
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          title: const Text(
            'اعتراضاتي',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'تحديث الاعتراضات',
              onPressed: controller.fetchMyAppeals,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 54,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final entry = _filters.entries.elementAt(index);
                  return Obx(() {
                    final selected =
                        controller.appealStatusFilter.value == entry.key;
                    return ChoiceChip(
                      selected: selected,
                      label: Text(
                        entry.value,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: selected
                              ? Colors.white
                              : AppColors.primaryBlue,
                        ),
                      ),
                      selectedColor: AppColors.primaryBlue,
                      backgroundColor: AppColors.cardWhite,
                      side: BorderSide(
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.primaryBlue.withOpacity(.12),
                      ),
                      onSelected: (_) =>
                          controller.selectAppealStatus(entry.key),
                    );
                  });
                },
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingAppeals.value &&
                    controller.myAppeals.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.actionYellow,
                    ),
                  );
                }

                if (controller.myAppeals.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.actionYellow,
                    onRefresh: controller.fetchMyAppeals,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 150),
                        Icon(
                          Icons.fact_check_outlined,
                          size: 64,
                          color: AppColors.actionYellow,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد اعتراضات ضمن هذا التصنيف',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.actionYellow,
                  onRefresh: controller.fetchMyAppeals,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                    itemCount: controller.myAppeals.length +
                        (controller.hasMoreAppeals ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.myAppeals.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Obx(
                            () => OutlinedButton(
                              onPressed: controller.isLoadingMoreAppeals.value
                                  ? null
                                  : () => controller.fetchMyAppeals(
                                        loadMore: true,
                                      ),
                              child: controller.isLoadingMoreAppeals.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryBlue,
                                      ),
                                    )
                                  : const Text(
                                      'تحميل المزيد',
                                      style: TextStyle(fontFamily: 'Cairo'),
                                    ),
                            ),
                          ),
                        );
                      }

                      return _EvaluationAppealCard(
                        controller.myAppeals[index],
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvaluationAppealCard extends GetView<StudentAssignedTaskController> {
  final ProjectEvaluationAppealModel appeal;

  const _EvaluationAppealCard(this.appeal);

  Color get statusColor {
    switch (appeal.status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return AppColors.textGrey;
      default:
        return AppColors.actionYellow;
    }
  }

  String get valueOrFallback {
    final grade = appeal.evaluation?.finalGrade.trim() ?? '';
    return grade.isEmpty ? 'غير محدد' : grade;
  }

  @override
  Widget build(BuildContext context) {
    final evaluation = appeal.evaluation;
    final projectTitle = evaluation?.assignment?.projectTitle.trim() ?? '';
    final supervisorName = evaluation?.supervisor?.name.trim() ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  projectTitle.isEmpty ? 'مشروع غير محدد' : projectTitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.appealStatusText(appeal.status),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appeal.reason,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textDark,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 12),
          _AppealInfoRow(
            label: 'تاريخ التقديم',
            value: controller.dateTimeText(appeal.createdAt),
          ),
          _AppealInfoRow(label: 'التقييم النهائي', value: valueOrFallback),
          _AppealInfoRow(
            label: 'المشرف',
            value: supervisorName.isEmpty ? 'غير محدد' : supervisorName,
          ),
          if (appeal.reviewNotes != null)
            _AppealInfoRow(
              label: 'ملاحظات المراجعة',
              value: appeal.reviewNotes!,
            ),
          if (appeal.reviewedAt != null)
            _AppealInfoRow(
              label: 'تاريخ المراجعة',
              value: controller.dateTimeText(appeal.reviewedAt),
            ),
        ],
      ),
    );
  }
}

class _AppealInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _AppealInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                fontSize: 10,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
