import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_progress_model.dart';

class ProgressUpdateCard extends StatelessWidget {
  final CompanyTaskProgressUpdateModel update;
  final String createdAtText;

  const ProgressUpdateCard({
    super.key,
    required this.update,
    required this.createdAtText,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = update.progress.percentage.clamp(0, 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 7),
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
                  update.progress.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _ProgressPercentageBadge(percentage: percentage),
            ],
          ),
          if (update.progress.description.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              update.progress.description,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 11.5,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 7,
              color: AppColors.primaryBlue,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.10),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 16,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  createdAtText,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (update.links.githubUrl != null ||
              update.links.demoUrl != null) ...[
            const SizedBox(height: 12),
            _LinksSection(
              githubUrl: update.links.githubUrl,
              demoUrl: update.links.demoUrl,
            ),
          ],
          if (update.attachments.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'المرفقات',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: update.attachments.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return _AttachmentPreview(
                    imageUrl: update.attachments[index].url,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressPercentageBadge extends StatelessWidget {
  final int percentage;

  const _ProgressPercentageBadge({
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        '$percentage%',
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LinksSection extends StatelessWidget {
  final String? githubUrl;
  final String? demoUrl;

  const _LinksSection({
    required this.githubUrl,
    required this.demoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          if (githubUrl != null)
            _LinkItem(
              icon: Icons.code_rounded,
              label: 'رابط GitHub',
              url: githubUrl!,
            ),
          if (githubUrl != null && demoUrl != null)
            const SizedBox(height: 8),
          if (demoUrl != null)
            _LinkItem(
              icon: Icons.language_rounded,
              label: 'رابط العرض التجريبي',
              url: demoUrl!,
            ),
        ],
      ),
    );
  }
}

class _LinkItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _LinkItem({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 16,
        ),
        const SizedBox(width: 7),
        Text(
          '$label:',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final String imageUrl;

  const _AttachmentPreview({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 82,
        height: 74,
        color: AppColors.background,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const Icon(
              Icons.attach_file_rounded,
              color: AppColors.primaryBlue,
              size: 24,
            );
          },
        ),
      ),
    );
  }
}