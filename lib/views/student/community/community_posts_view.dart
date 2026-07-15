import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/community/community_posts_controller.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/controllers/student/points/student_points_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/community/community_post_model.dart';

class CommunityPostsView extends GetView<CommunityPostsController> {
  const CommunityPostsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'create-community-post',
          elevation: 12,
          backgroundColor: AppColors.actionYellow,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.edit_rounded),
          label: const Text(
            'منشور جديد',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            controller.prepareCreate(initialType: controller.selectedType);
            _showPostFormSheet(context);
          },
        ),
        body: SafeArea(
          child: GetBuilder<CommunityPostsController>(
            builder: (_) {
              return RefreshIndicator(
                color: AppColors.actionYellow,
                onRefresh: () => controller.fetchPosts(refresh: true),
                child: CustomScrollView(
                  controller: controller.scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    const SliverToBoxAdapter(child: _CommunityHeader()),
                    const SliverToBoxAdapter(child: _CommunityPointsStrip()),
                    SliverToBoxAdapter(child: _SearchAndFilters(controller: controller)),
                    if (controller.isLoading)
                      const SliverFillRemaining(child: _CommunityLoading())
                    else if (controller.errorMessage != null && controller.posts.isEmpty)
                      SliverFillRemaining(
                        child: _CommunityError(
                          message: controller.errorMessage!,
                          onRetry: controller.fetchPosts,
                        ),
                      )
                    else if (controller.posts.isEmpty)
                      const SliverFillRemaining(child: _CommunityEmpty())
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
                        sliver: SliverList.separated(
                          itemCount: controller.posts.length +
                              (controller.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            if (index >= controller.posts.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.actionYellow,
                                  ),
                                ),
                              );
                            }

                            final post = controller.posts[index];
                            return _PostCard(
                              post: post,
                              controller: controller,
                              onDetails: () {
                                controller.prepareDetailsPreview(post);
                                _showDetailsSheet(context);
                                Future.delayed(const Duration(milliseconds: 120), () {
                                  controller.fetchComments(post.id);
                                });
                              },
                              onEdit: () {
                                controller.prepareEdit(post);
                                _showPostFormSheet(context);
                              },
                              onDelete: () => _confirmDelete(context, post.id),
                            )
                                .animate()
                                .fadeIn(
                                  duration: 420.ms,
                                  delay: (45 * (index % 5)).ms,
                                )
                                .slideY(begin: .16, curve: Curves.easeOutCubic);
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

  void _showPostFormSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PostFormSheet(),
    );
  }

  void _showDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PostDetailsSheet(),
    );
  }

  void _confirmDelete(BuildContext context, int postId) {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'حذف المنشور؟',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'هل أنت متأكد؟ ما فينا نرجّع المنشور بعد الحذف.',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            GetBuilder<CommunityPostsController>(
              builder: (_) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: controller.isDeleting
                    ? null
                    : () async {
                        final deleted = await controller.deletePost(postId);
                        if (deleted && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                child: controller.isDeleting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'حذف',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityHeader extends StatelessWidget {
  const _CommunityHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
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
              end: -18,
              top: -22,
              child: _GlowCircle(size: 94, color: Colors.white.withOpacity(.10)),
            ),
            PositionedDirectional(
              start: -16,
              bottom: -26,
              child: _GlowCircle(size: 76, color: AppColors.actionYellow.withOpacity(.18)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(.20)),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 31,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المجتمع التقني',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'اسأل، ناقش، ساعد، وانشر فائدة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _HeaderChip(label: 'أسئلة'),
                    _HeaderChip(label: 'نقاشات'),
                    _HeaderChip(label: 'مساعدة'),
                    _HeaderChip(label: 'Best Practices'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 520.ms).slideY(begin: .18),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  const _HeaderChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.13),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withOpacity(.16)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}


class _CommunityPointsStrip extends StatelessWidget {
  const _CommunityPointsStrip();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: GetBuilder<StudentPointsController>(
        builder: (pointsController) {
          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Get.toNamed(Routes.studentPoints),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.actionYellow.withOpacity(.18)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(.06),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.actionYellow, Color(0xFFFFC857)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.actionYellow.withOpacity(.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.white, size: 29),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'نقاطك في جسور',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.primaryBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          pointsController.isLoadingSummary && pointsController.totalPoints == 0
                              ? 'عم نجيب رصيدك...'
                              : 'كل منشور وتعليق وتفاعل بيقربك أكتر',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textGrey,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  pointsController.isLoadingSummary && pointsController.totalPoints == 0
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.actionYellow,
                            strokeWidth: 2.3,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.actionYellow.withOpacity(.12),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${pointsController.totalPoints}',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  color: AppColors.primaryBlue,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'نقطة',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: AppColors.textGrey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textGrey, size: 16),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 90.ms, duration: 430.ms).slideY(begin: .12);
  }
}

class _SearchAndFilters extends StatelessWidget {
  final CommunityPostsController controller;
  const _SearchAndFilters({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(.06),
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontFamily: 'Cairo'),
              decoration: InputDecoration(
                hintText: 'ابحث عن Laravel، Flutter، API...',
                hintStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                icon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
                suffixIcon: controller.searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: controller.clearSearch,
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _FilterPill(
                  title: 'الكل',
                  isActive: controller.selectedType == null,
                  onTap: () => controller.changeFilter(null),
                ),
                const SizedBox(width: 8),
                ...communityPostTypes.map(
                  (type) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: _FilterPill(
                      title: type.arabicTitle,
                      isActive: controller.selectedType == type.value,
                      onTap: () => controller.changeFilter(type.value),
                    ),
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

class _FilterPill extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterPill({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isActive
                ? AppColors.primaryBlue
                : AppColors.primaryBlue.withOpacity(.10),
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.primaryBlue.withOpacity(.18)
                  : AppColors.primaryBlue.withOpacity(.04),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: isActive ? Colors.white : AppColors.primaryBlue,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final CommunityPostsController controller;
  final VoidCallback onDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PostCard({
    required this.post,
    required this.controller,
    required this.onDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDetails,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _typeColor(post.type).withOpacity(.18)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.07),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(author: post.author),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              post.author.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.2,
                              ),
                            ),
                          ),
                          _TypeBadge(type: post.type),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.formatDate(post.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.isOwner)
                  PopupMenuButton<String>(
                    tooltip: 'خيارات',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('تعديل', style: TextStyle(fontFamily: 'Cairo')),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'حذف',
                          style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFDC2626)),
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_horiz_rounded, color: AppColors.textGrey),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                fontSize: 14,
                height: 1.48,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _ActionButton(
                  icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  label: '${post.likeCount}',
                  color: post.isLiked ? const Color(0xFFE11D48) : AppColors.textGrey,
                  onTap: () => controller.toggleLike(post),
                ),
                const SizedBox(width: 10),
                _ActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: '${post.commentCount}',
                  color: AppColors.textGrey,
                  onTap: onDetails,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onDetails,
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                  label: const Text(
                    'تفاصيل',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostFormSheet extends GetView<CommunityPostsController> {
  const _PostFormSheet();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .88),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              decoration: const BoxDecoration(color: Colors.white),
              child: GetBuilder<CommunityPostsController>(
                builder: (_) {
                  final isEdit = controller.selectedPost != null;
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            height: 5,
                            width: 54,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(.14),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: AppColors.actionYellow.withOpacity(.14),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                isEdit ? Icons.edit_note_rounded : Icons.add_comment_rounded,
                                color: AppColors.actionYellow,
                                size: 29,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isEdit ? 'تعديل المنشور' : 'منشور جديد',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  color: AppColors.primaryBlue,
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'نوع المنشور',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: communityPostTypes.map((type) {
                            final active = controller.formType == type.value;
                            return InkWell(
                              onTap: () => controller.changeFormType(type.value),
                              borderRadius: BorderRadius.circular(18),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: (MediaQuery.of(context).size.width - 56) / 2,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.primaryBlue
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: active
                                        ? AppColors.primaryBlue
                                        : AppColors.primaryBlue.withOpacity(.08),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      type.arabicTitle,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        color: active ? Colors.white : AppColors.primaryBlue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      type.arabicDescription,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        color: active ? Colors.white70 : AppColors.textGrey,
                                        fontSize: 10.5,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'المحتوى',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: controller.contentController,
                          minLines: 6,
                          maxLines: 9,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            height: 1.5,
                            color: AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: 'مثلاً: كيف أستخدم Form Request Validation في Laravel API؟',
                            hintStyle: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide(
                                color: AppColors.primaryBlue.withOpacity(.08),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: const BorderSide(
                                color: AppColors.actionYellow,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: controller.isSubmitting
                                ? null
                                : () async {
                                    final ok = await controller.submitPost();
                                    if (ok && context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.actionYellow,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.actionYellow.withOpacity(.55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                              shadowColor: AppColors.actionYellow.withOpacity(.24),
                            ),
                            child: controller.isSubmitting
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isEdit ? 'حفظ التعديل' : 'نشر الآن',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _PostDetailsSheet extends GetView<CommunityPostsController> {
  const _PostDetailsSheet();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Material(
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .90,
              child: GetBuilder<CommunityPostsController>(
                builder: (_) {
                  final post = controller.selectedPost;
                  if (post == null) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: _InlineCommentsEmpty(message: 'ما قدرنا نعرض المنشور'),
                    );
                  }

                  final itemCount = controller.isCommentsLoading || controller.comments.isEmpty
                      ? 3
                      : controller.comments.length + 2;

                  return Column(
                    children: [
                      _DetailsTopBar(post: post, controller: controller),
                      Expanded(
                        child: ListView.builder(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _PostDetailsHeader(post: post, controller: controller),
                              );
                            }

                            if (index == 1) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _FastCommentsFilters(controller: controller),
                              );
                            }

                            if (controller.isCommentsLoading) {
                              return const _InlineCommentsLoading();
                            }

                            if (controller.comments.isEmpty) {
                              return const _InlineCommentsEmpty(
                                message: 'لسا ما في تعليقات، كن أول واحد يشارك رأيه',
                              );
                            }

                            final comment = controller.comments[index - 2];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CommentCard(
                                comment: comment,
                                controller: controller,
                                onDelete: () => _confirmDeleteComment(context, comment),
                              ),
                            );
                          },
                        ),
                      ),
                      _CommentComposer(controller: controller),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteComment(BuildContext context, CommunityComment comment) {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            'حذف التعليق؟',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'هل أنت متأكد؟ ما فينا نرجّع التعليق بعد الحذف.',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            Builder(
              builder: (dialogContext) {
                return GetBuilder<CommunityPostsController>(
                  builder: (_) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: controller.isDeletingComment
                        ? null
                        : () async {
                            final deleted = await controller.deleteComment(comment);

                            if (deleted && dialogContext.mounted) {
                              Navigator.of(dialogContext, rootNavigator: true).pop();
                            }
                          },
                    child: controller.isDeletingComment
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'حذف',
                            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsTopBar extends StatelessWidget {
  final CommunityPost post;
  final CommunityPostsController controller;

  const _DetailsTopBar({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.primaryBlue.withOpacity(.07))),
      ),
      child: Column(
        children: [
          Container(
            height: 5,
            width: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(.14),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Avatar(author: post.author, size: 38),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      controller.formatDate(post.createdAt),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _TypeBadge(type: post.type),
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostDetailsHeader extends StatelessWidget {
  final CommunityPost post;
  final CommunityPostsController controller;

  const _PostDetailsHeader({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
          ),
          child: Text(
            post.content,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textDark,
              fontSize: 15,
              height: 1.65,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _ActionButton(
              icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              label: '${post.likeCount} إعجاب',
              color: post.isLiked ? const Color(0xFFE11D48) : AppColors.textGrey,
              onTap: () => controller.toggleLike(post),
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.mode_comment_outlined,
              label: '${post.commentCount} تعليق',
              color: AppColors.textGrey,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  final CommunityComment comment;
  final CommunityPostsController controller;
  final VoidCallback onDelete;
  final bool isReply;

  const _CommentCard({
    required this.comment,
    required this.controller,
    required this.onDelete,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    final replies = controller.repliesByComment[comment.id] ?? comment.replies;
    final isExpanded = controller.expandedReplies.contains(comment.id);
    final isLoadingReplies = controller.loadingReplies.contains(comment.id);

    return Container(
      margin: EdgeInsetsDirectional.only(start: isReply ? 28 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReply ? AppColors.background.withOpacity(.72) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isReply
              ? AppColors.primaryBlue.withOpacity(.06)
              : AppColors.primaryBlue.withOpacity(.09),
        ),
        boxShadow: isReply
            ? []
            : [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(.045),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(author: comment.user, size: isReply ? 32 : 38),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            comment.user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: isReply ? 12.5 : 13.5,
                            ),
                          ),
                        ),
                        Text(
                          controller.formatDate(comment.createdAt),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textGrey,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textDark,
                        fontSize: isReply ? 12.5 : 13.2,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (comment.isOwner)
                PopupMenuButton<String>(
                  tooltip: 'خيارات التعليق',
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) {
                    if (value == 'edit') controller.prepareEditComment(comment);
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('تعديل', style: TextStyle(fontFamily: 'Cairo')),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'حذف',
                        style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFDC2626)),
                      ),
                    ),
                  ],
                  child: const Icon(Icons.more_horiz_rounded, color: AppColors.textGrey, size: 21),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (comment.likesCount > 0) ...[
                Icon(
                  comment.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: comment.isLiked ? const Color(0xFFE11D48) : AppColors.textGrey,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  '${comment.likesCount}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => controller.prepareReply(comment),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Text(
                    'رد',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.primaryBlue,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!isReply && comment.repliesCount > 0) ...[
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () => controller.toggleReplies(comment),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoadingReplies)
                          const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.actionYellow,
                            ),
                          )
                        else
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.actionYellow,
                            size: 18,
                          ),
                        const SizedBox(width: 2),
                        Text(
                          isExpanded ? 'إخفاء الردود' : 'عرض ${comment.repliesCount} رد',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.actionYellow,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (!isReply && isExpanded && replies.isNotEmpty) ...[
            const SizedBox(height: 9),
            ...replies.map(
              (reply) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _CommentCard(
                  comment: reply,
                  controller: controller,
                  onDelete: () => _confirmReplyDelete(context, controller, reply),
                  isReply: true,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmReplyDelete(
    BuildContext context,
    CommunityPostsController controller,
    CommunityComment reply,
  ) {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            'حذف الرد؟',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'هل أنت متأكد من حذف هذا الرد؟',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            Builder(
              builder: (dialogContext) {
                return GetBuilder<CommunityPostsController>(
                  builder: (_) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: controller.isDeletingComment
                        ? null
                        : () async {
                            final deleted = await controller.deleteComment(reply);

                            if (deleted && dialogContext.mounted) {
                              Navigator.of(dialogContext, rootNavigator: true).pop();
                            }
                          },
                    child: controller.isDeletingComment
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'حذف',
                            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  final CommunityPostsController controller;

  const _CommentComposer({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.editingComment != null;
    final isReplying = controller.replyingTo != null;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.primaryBlue.withOpacity(.08))),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.08),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isReplying || isEditing)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isEditing ? AppColors.primaryBlue : AppColors.actionYellow).withOpacity(.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isEditing ? Icons.edit_note_rounded : Icons.reply_rounded,
                        color: isEditing ? AppColors.primaryBlue : AppColors.actionYellow,
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          isEditing
                              ? 'تعديل التعليق'
                              : 'رد على ${controller.replyingTo?.user.name ?? 'تعليق'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: isEditing ? controller.cancelEditComment : controller.cancelReply,
                        child: const Icon(Icons.close_rounded, color: AppColors.textGrey, size: 18),
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: isEditing
                          ? controller.editCommentController
                          : controller.commentController,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: isEditing
                            ? 'عدّل تعليقك...'
                            : isReplying
                                ? 'اكتب ردك...'
                                : 'اكتب تعليقك... ',
                        hintStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textGrey,
                          fontSize: 12.5,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: isEditing ? AppColors.primaryBlue : AppColors.actionYellow,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isEditing ? AppColors.primaryBlue : AppColors.actionYellow).withOpacity(.20),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: controller.isSubmittingComment || controller.isUpdatingComment
                          ? null
                          : isEditing
                              ? controller.submitCommentEdit
                              : controller.submitComment,
                      icon: controller.isSubmittingComment || controller.isUpdatingComment
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(
                              isEditing ? Icons.check_rounded : Icons.send_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final CommunityAuthor author;
  final double size;

  const _Avatar({required this.author, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final image = author.profilePictureUrl;
    final first = author.name.trim().isNotEmpty ? author.name.trim().substring(0, 1) : 'ج';

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: image == null || image.isEmpty
            ? const LinearGradient(
                colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : null,
        image: image == null || image.isEmpty
            ? null
            : DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: image == null || image.isEmpty
          ? Center(
              child: Text(
                first,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontSize: size * .38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(.20)),
      ),
      child: Text(
        communityTypeArabic(type),
        style: TextStyle(
          fontFamily: 'Cairo',
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: color,
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

class _CommunityLoading extends StatelessWidget {
  const _CommunityLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 96),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => Container(
        height: 168,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.05),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.actionYellow),
        ),
      ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1300.ms),
    );
  }
}

class _CommunityEmpty extends StatelessWidget {
  final String message;
  const _CommunityEmpty({this.message = 'لسا ما في منشورات هون، كن أول واحد ينشر بالمجتمع التقني'});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: AppColors.actionYellow.withOpacity(.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.forum_outlined,
                        color: AppColors.actionYellow,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        fontSize: 13.5,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CommunityError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CommunityError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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

Color _typeColor(String type) {
  switch (type) {
    case 'question':
      return const Color(0xFF2563EB);
    case 'help':
      return const Color(0xFFDC2626);
    case 'tip':
      return const Color(0xFF16A34A);
    case 'discussion':
    default:
      return AppColors.actionYellow;
  }
}


class _FastCommentsFilters extends StatelessWidget {
  final CommunityPostsController controller;

  const _FastCommentsFilters({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.06)),
      ),
      child: Row(
        children: communityCommentFilters.map((filter) {
          final active = controller.commentsFilter == filter.value;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () => controller.changeCommentsFilter(filter.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  filter.arabicTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: active ? Colors.white : AppColors.textGrey,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InlineCommentsLoading extends StatelessWidget {
  const _InlineCommentsLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        color: AppColors.actionYellow,
        strokeWidth: 2.4,
      ),
    );
  }
}

class _InlineCommentsEmpty extends StatelessWidget {
  final String message;

  const _InlineCommentsEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: AppColors.actionYellow.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mode_comment_outlined,
              color: AppColors.actionYellow,
              size: 29,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}