import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/points/student_points_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/points/student_points_model.dart';

class StudentPointsView extends GetView<StudentPointsController> {
  const StudentPointsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const StudentBottomNav(currentIndex: 0),
        body: SafeArea(
          child: GetBuilder<StudentPointsController>(
            builder: (_) {
              return RefreshIndicator(
                color: AppColors.actionYellow,
                onRefresh: () => controller.fetchAll(refresh: true),
                child: CustomScrollView(
                  controller: controller.scrollController,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverToBoxAdapter(child: _PointsHeader(controller: controller)),
                    SliverToBoxAdapter(child: _HowToEarnCard(controller: controller)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'سجل النقاط',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: AppColors.primaryBlue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (controller.meta.total > 0)
                              Text(
                                '${controller.meta.total} نشاط',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (controller.isLoadingHistory && controller.history.isEmpty)
                      const SliverFillRemaining(child: _PointsLoading())
                    else if (controller.errorMessage != null && controller.history.isEmpty)
                      SliverFillRemaining(
                        child: _PointsError(
                          message: controller.errorMessage!,
                          onRetry: () => controller.fetchAll(refresh: true),
                        ),
                      )
                    else if (controller.history.isEmpty)
                      const SliverFillRemaining(child: _PointsEmpty())
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverList.separated(
                          itemCount: controller.history.length + (controller.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index >= controller.history.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(color: AppColors.actionYellow),
                                ),
                              );
                            }

                            final record = controller.history[index];
                            return _PointHistoryCard(record: record, controller: controller)
                                .animate()
                                .fadeIn(duration: 360.ms, delay: (35 * (index % 6)).ms)
                                .slideY(begin: .12, curve: Curves.easeOutCubic);
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PointsHeader extends StatelessWidget {
  final StudentPointsController controller;

  const _PointsHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.22),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -22,
              top: -24,
              child: _GlowCircle(size: 104, color: Colors.white.withOpacity(.10)),
            ),
            PositionedDirectional(
              start: -20,
              bottom: -26,
              child: _GlowCircle(size: 84, color: AppColors.actionYellow.withOpacity(.18)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'نقاطي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.isLoadingSummary || controller.isLoadingHistory
                          ? null
                          : () => controller.fetchAll(refresh: true),
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.14),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(.18)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'رصيدك الحالي',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            controller.isLoadingSummary && controller.totalPoints == 0
                                ? const SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: CircularProgressIndicator(
                                      color: AppColors.actionYellow,
                                      strokeWidth: 2.4,
                                    ),
                                  )
                                : Text(
                                    '${controller.totalPoints}',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      color: Colors.white,
                                      fontSize: 46,
                                      height: 1,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.actionYellow.withOpacity(.20),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Text(
                                'نقطة تفاعل وإنجاز',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 520.ms).slideY(begin: .18),
    );
  }
}

class _HowToEarnCard extends StatelessWidget {
  final StudentPointsController controller;

  const _HowToEarnCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(.07)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.06),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: const Row(
          children: [
            _EarnItem(icon: Icons.post_add_rounded, title: 'منشور', points: '+5'),
            SizedBox(width: 8),
            _EarnItem(icon: Icons.mode_comment_rounded, title: 'تعليق', points: '+3'),
            SizedBox(width: 8),
            _EarnItem(icon: Icons.favorite_rounded, title: 'إعجاب', points: '+1'),
          ],
        ),
      ).animate().fadeIn(delay: 80.ms).slideY(begin: .12),
    );
  }
}

class _EarnItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String points;

  const _EarnItem({required this.icon, required this.title, required this.points});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.actionYellow, size: 24),
            const SizedBox(height: 6),
            Text(
              points,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointHistoryCard extends StatelessWidget {
  final StudentPointRecord record;
  final StudentPointsController controller;

  const _PointHistoryCard({required this.record, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isPositive = record.points >= 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.07)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.045),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: _recordColor(record).withOpacity(.11),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(_recordIcon(record), color: _recordColor(record), size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.arabicDescription,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textDark,
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _SmallTag(text: record.arabicCategory),
                    if (record.reference != null)
                      _SmallTag(text: '${record.referenceTitle} #${record.reference!.id}'),
                    _SmallTag(text: controller.formatDate(record.createdAt)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: (isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626)).withOpacity(.10),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              '${isPositive ? '+' : ''}${record.points}',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _recordIcon(StudentPointRecord record) {
    final type = record.reference?.type.toLowerCase() ?? '';
    if (type.contains('comment')) return Icons.mode_comment_rounded;
    if (type.contains('like')) return Icons.favorite_rounded;
    if (type.contains('post')) return Icons.post_add_rounded;
    return Icons.auto_awesome_rounded;
  }

  Color _recordColor(StudentPointRecord record) {
    final type = record.reference?.type.toLowerCase() ?? '';
    if (type.contains('like')) return const Color(0xFFE11D48);
    if (type.contains('comment')) return AppColors.actionYellow;
    return AppColors.primaryBlue;
  }
}

class _SmallTag extends StatelessWidget {
  final String text;

  const _SmallTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.textGrey,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PointsLoading extends StatelessWidget {
  const _PointsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.actionYellow),
    );
  }
}

class _PointsEmpty extends StatelessWidget {
  const _PointsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 76,
              width: 76,
              decoration: BoxDecoration(
                color: AppColors.actionYellow.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars_rounded, color: AppColors.actionYellow, size: 40),
            ),
            const SizedBox(height: 12),
            const Text(
              'لسا ما عندك سجل نقاط. ابدأ بمنشور أو تعليق بالمجتمع التقني.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PointsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 52, color: Color(0xFFDC2626)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
