import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/conversations/student_conversation_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_empty_state.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_error_state.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_loading_state.dart';
import 'package:jisr_platform/core/widgets/conversations/conversation_card.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/core/widgets/student/student_drawer.dart';
import 'package:jisr_platform/core/widgets/student/student_shell_app_bar.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentConversationsView
    extends GetView<StudentConversationController> {
  const StudentConversationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: const StudentDrawer(),
        drawerScrimColor: Colors.black.withOpacity(.32),
        appBar: const StudentShellAppBar(),
        bottomNavigationBar: const StudentBottomNav(currentIndex: 3),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearch(),
              _buildFilters(),
              const SizedBox(height: 6),
              Expanded(child: Obx(_buildContent)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المحادثات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  final unread = controller.totalUnreadMessages;
                  return Text(
                    unread > 0
                        ? '$unread رسالة غير مقروءة'
                        : 'تواصل مع الشركات بعد قبولك في المهام',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 12.5,
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.forum_outlined,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontFamily: 'Cairo'),
        decoration: InputDecoration(
          hintText: 'ابحث باسم الشركة أو المهمة...',
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textGrey.withOpacity(0.75),
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryBlue,
            size: 21,
          ),
          filled: true,
          fillColor: AppColors.cardWhite,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.textGrey.withOpacity(0.10),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.textGrey.withOpacity(0.10),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryBlue,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 51,
      child: Obx(
        () => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          scrollDirection: Axis.horizontal,
          children: [
            _FilterChip(
              label: 'المهام',
              icon: Icons.task_alt_rounded,
              selected:
                  controller.selectedTab.value == ConversationTabType.task,
              onTap: () => controller.changeTab(ConversationTabType.task),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'الكل',
              icon: Icons.chat_bubble_outline_rounded,
              selected:
                  controller.selectedTab.value == ConversationTabType.all,
              onTap: () => controller.changeTab(ConversationTabType.all),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'المغلقة',
              icon: Icons.lock_outline_rounded,
              selected:
                  controller.selectedTab.value == ConversationTabType.closed,
              onTap: () => controller.changeTab(ConversationTabType.closed),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (controller.isLoadingConversations.value &&
        controller.conversations.isEmpty) {
      return const JisrLoadingState(message: 'جارٍ تحميل المحادثات...');
    }

    final error = controller.conversationsError.value;
    if (error != null && controller.conversations.isEmpty) {
      return JisrErrorState(
        message: error,
        onRetry: () {
          controller.fetchCurrentConversations();
        },
      );
    }

    final visible = controller.visibleConversations;
    if (visible.isEmpty) {
      if (controller.searchQuery.value.isNotEmpty &&
          controller.conversations.isNotEmpty) {
        return const JisrEmptyState(
          icon: Icons.search_off_rounded,
          title: 'لا توجد نتائج',
          message: 'لم نعثر على محادثة مطابقة لبحثك.',
        );
      }
      return _emptyState();
    }

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: controller.fetchCurrentConversations,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 180) {
            unawaited(controller.loadMore());
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          itemCount: visible.length + (controller.isLoadingMore.value ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 11),
          itemBuilder: (context, index) {
            if (index >= visible.length) {
              return const Padding(
                padding: EdgeInsets.all(14),
                child: Center(
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              );
            }

            final conversation = visible[index];
            final participant = controller.otherParticipant(conversation);
            final latest = conversation.latestMessage;

            return ConversationCard(
              taskTitle: conversation.displayTaskTitle,
              participantName: controller.participantName(conversation),
              profilePictureUrl: participant?.profilePictureUrl,
              latestMessage: controller.latestMessageText(conversation),
              timeText: controller.relativeTime(latest?.createdAt),
              unreadCount: conversation.unreadMessagesCount,
              isClosed: conversation.isClosed,
              isLatestMessageMine:
                  controller.isLatestMessageMine(conversation),
              onTap: () {
                unawaited(controller.openConversation(conversation));
                Get.toNamed(Routes.studentChat, arguments: conversation);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState() {
    switch (controller.selectedTab.value) {
      case ConversationTabType.task:
        return const JisrEmptyState(
          icon: Icons.forum_outlined,
          title: 'لا توجد محادثات مهام',
          message: 'ستظهر المحادثات هنا بعد قبولك في إحدى مهام الشركات.',
        );
      case ConversationTabType.all:
        return const JisrEmptyState(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'لا توجد محادثات',
          message: 'لا توجد محادثات متاحة لك حاليًا.',
        );
      case ConversationTabType.closed:
        return const JisrEmptyState(
          icon: Icons.lock_open_rounded,
          title: 'لا توجد محادثات مغلقة',
          message: 'المحادثات المنتهية ستظهر هنا للرجوع إليها لاحقًا.',
        );
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue
                  : AppColors.textGrey.withOpacity(0.14),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? AppColors.cardWhite : AppColors.textGrey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: selected ? AppColors.cardWhite : AppColors.textDark,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
