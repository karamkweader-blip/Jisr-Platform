import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunity_candidates_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_candidate_model.dart';

class CompanyOpportunityCandidatesView extends GetView<CompanyOpportunityCandidatesController> {
  const CompanyOpportunityCandidatesView({super.key});

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
        appBar: AppBar(title: Text('مرشحو ${controller.opportunityTitle}')),
        body: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (controller.errorMessage.value.isNotEmpty) {
            return _State(message: controller.errorMessage.value, onRetry: controller.fetchCandidates);
          }
          if (controller.candidates.isEmpty) return const _State(message: 'لا يوجد مرشحون لهذه الفرصة بعد');
          return RefreshIndicator(
            onRefresh: controller.fetchCandidates,
            child: ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: controller.candidates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = controller.candidates[index];
                return _CandidateCard(item: item, onTap: () => controller.openCandidate(item));
              },
            ),
          );
        }),
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final CompanyOpportunityCandidate item;
  final VoidCallback onTap;
  const _CandidateCard({required this.item, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: AppColors.cardWhite,
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(14),
      leading: CircleAvatar(backgroundImage: item.student.profilePictureUrl?.isNotEmpty == true ? NetworkImage(item.student.profilePictureUrl!) : null, child: item.student.profilePictureUrl?.isNotEmpty == true ? null : Text(item.student.name.isEmpty ? '؟' : item.student.name[0])),
      title: Text(item.student.name, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text('${item.student.major.isEmpty ? item.student.email : item.student.major}\n${item.displayStatus.isEmpty ? item.applicationStatus : item.displayStatus}'),
      isThreeLine: true,
      trailing: item.matchScore == null ? const Icon(Icons.chevron_left) : CircleAvatar(backgroundColor: AppColors.primaryBlue.withOpacity(.1), child: Text('${item.matchScore!.round()}%', style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.w800))),
    ),
  );
}

class _State extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _State({required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.groups_outlined, size: 50, color: AppColors.textGrey), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center), if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة'))])));
}
