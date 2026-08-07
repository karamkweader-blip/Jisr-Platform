import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class MessageInfoSheet extends StatelessWidget {
  final String sentAt;
  final String readStatus;
  final String? readAt;
  final bool canEdit;
  final VoidCallback? onEdit;

  const MessageInfoSheet({
    super.key,
    required this.sentAt,
    required this.readStatus,
    required this.readAt,
    required this.canEdit,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textGrey.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'معلومات الرسالة',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _InfoRow(
                icon: Icons.schedule_rounded,
                title: 'تم الإرسال',
                value: sentAt.isEmpty
                    ? 'غير متوفر'
                    : sentAt,
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Icons.done_all_rounded,
                title: 'حالة القراءة',
                value: readStatus,
              ),
              if (readAt != null &&
                  readAt!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.visibility_outlined,
                  title: 'وقت القراءة',
                  value: readAt!,
                ),
              ],
              if (canEdit && onEdit != null) ...[
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    label: const Text(
                      'تعديل الرسالة',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          AppColors.primaryBlue,
                      side: BorderSide(
                        color: AppColors.primaryBlue
                            .withOpacity(0.30),
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 19,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}