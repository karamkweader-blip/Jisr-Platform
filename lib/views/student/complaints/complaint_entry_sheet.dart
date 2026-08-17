import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class ComplaintEntrySheet extends StatelessWidget {
  const ComplaintEntrySheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ComplaintEntrySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = <_ComplaintEntry>[
      const _ComplaintEntry(
        icon: Icons.supervisor_account_outlined,
        title: 'شكوى على المشرف',
        subtitle: 'من مهام المشروع المسندة',
        route: Routes.studentAssignedTasks,
      ),
      const _ComplaintEntry(
        icon: Icons.business_center_outlined,
        title: 'شكوى على شركة مهمة',
        subtitle: 'من التاسكات المقبولة ومتابعة التقدم',
        route: Routes.studentTaskApplications,
      ),
      const _ComplaintEntry(
        icon: Icons.event_note_outlined,
        title: 'شكوى على مقابلة فرصة',
        subtitle: 'من تفاصيل تقديمات الفرص',
        route: Routes.studentOpportunityApplications,
      ),
      const _ComplaintEntry(
        icon: Icons.article_outlined,
        title: 'الإبلاغ عن منشور',
        subtitle: 'من قائمة منشورات المجتمع',
        route: Routes.studentCommunityPosts,
      ),
      const _ComplaintEntry(
        icon: Icons.mode_comment_outlined,
        title: 'الإبلاغ عن تعليق',
        subtitle: 'افتح المنشور ثم اختر التعليق',
        route: Routes.studentCommunityPosts,
      ),
      const _ComplaintEntry(
        icon: Icons.school_outlined,
        title: 'شكوى على مرشد',
        subtitle: 'من صفحة تفاصيل المرشد',
        route: Routes.studentMentors,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * .84,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textGrey.withOpacity(.25),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(22, 18, 22, 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.report_problem_outlined,
                      color: Color(0xFFDC2626),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'إرسال شكوى',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'اختر مكان الشكوى، ثم حدّد العنصر الحقيقي من بيانات حسابك.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          Navigator.of(context).pop();
                          Get.toNamed(entry.route);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626).withOpacity(.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  entry.icon,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.title,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      entry.subtitle,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        color: AppColors.textGrey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.actionYellow,
                                size: 17,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComplaintEntry {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _ComplaintEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}
