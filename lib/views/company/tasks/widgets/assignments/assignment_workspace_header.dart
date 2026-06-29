import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_details_model.dart';
import 'package:jisr_platform/views/company/tasks/widgets/assignments/assignment_status_chip.dart';

class AssignmentWorkspaceHeader extends StatelessWidget {
  final CompanyTaskAssignmentDetailsModel details;
  final String studentName;
  final String studentEmail;
  final String? studentProfilePictureUrl;
  final String statusLabel;
  final String deadlineText;
  final String startedAtText;

  const AssignmentWorkspaceHeader({
    super.key,
    required this.details,
    required this.studentName,
    required this.studentEmail,
    required this.studentProfilePictureUrl,
    required this.statusLabel,
    required this.deadlineText,
    required this.startedAtText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Material(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                onTap: Get.back,
                borderRadius: BorderRadius.circular(15),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primaryBlue,
                    size: 19,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مساحة عمل المهمة',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'تابع معلومات المهمة والطالب المكلف بها',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.16),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      details.task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AssignmentStatusChip(
                    status: details.assignment.status,
                    label: statusLabel,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _StudentAvatar(
                    studentName: studentName,
                    imageUrl: studentProfilePictureUrl,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (studentEmail.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            studentEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.80),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _HeaderInfoItem(
                      icon: Icons.calendar_month_outlined,
                      label: 'الموعد النهائي',
                      value: deadlineText,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeaderInfoItem(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'تاريخ البدء',
                      value: startedAtText,
                    ),
                  ),
                ],
              ),
              if (details.matching.score > 0) ...[
                const SizedBox(height: 16),
                Text(
                  'نسبة التطابق: ${details.matching.score.round()}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: details.matching.score.clamp(0, 100) / 100,
                    minHeight: 7,
                    color: AppColors.actionYellow,
                    backgroundColor: Colors.white.withOpacity(0.20),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  final String studentName;
  final String? imageUrl;

  const _StudentAvatar({
    required this.studentName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = studentName.trim().isEmpty
        ? 'ط'
        : studentName.trim().characters.first;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _InitialAvatar(letter: firstLetter);
          },
        ),
      );
    }

    return _InitialAvatar(letter: firstLetter);
  }
}

class _InitialAvatar extends StatelessWidget {
  final String letter;

  const _InitialAvatar({
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 23,
      backgroundColor: Colors.white.withOpacity(0.18),
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HeaderInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.86),
            size: 17,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}