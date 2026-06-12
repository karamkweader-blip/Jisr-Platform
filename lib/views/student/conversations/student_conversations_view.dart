import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/conversations/student_conversation_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/conversations/student_conversation_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentConversationsView extends StatefulWidget {
  const StudentConversationsView({super.key});

  @override
  State<StudentConversationsView> createState() =>
      _StudentConversationsViewState();
}

class _StudentConversationsViewState extends State<StudentConversationsView> {
  final StudentConversationController controller =
      Get.find<StudentConversationController>();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        controller.fetchCurrentConversations(refresh: true);
      }
    });
  }

  void _openFilterSheet() {
    Get.bottomSheet(
      const _ConversationFilterSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          title: const Text(
            'محادثاتي',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _openFilterSheet,
              icon: const Icon(
                Icons.tune_rounded,
                color: AppColors.primaryBlue,
              ),
            ),
            Obx(
              () => IconButton(
                onPressed: controller.isLoadingConversations.value
                    ? null
                    : () => controller.fetchCurrentConversations(refresh: true),
                icon: controller.isLoadingConversations.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.actionYellow,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.actionYellow,
                      ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          color: AppColors.actionYellow,
          onRefresh: () => controller.fetchCurrentConversations(refresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            child: Column(
              children: [
                const _ConversationsHero()
                    .animate()
                    .fadeIn(duration: 520.ms)
                    .slideY(begin: .22, curve: Curves.easeOutBack)
                    .scale(begin: Offset(.96, .96)),

                const SizedBox(height: 16),

                _CurrentFilterCard(onTap: _openFilterSheet)
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 420.ms)
                    .slideY(begin: .18),

                const SizedBox(height: 18),

                Obx(() {
                  if (controller.isLoadingConversations.value) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: CircularProgressIndicator(
                        color: AppColors.actionYellow,
                      ),
                    );
                  }

                  if (controller.conversations.isEmpty) {
                    return _EmptyConversations(
                      title: controller.emptyMessageTitle(),
                      subtitle: controller.emptyMessageSubtitle(),
                    );
                  }

                  return Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.conversations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final conversation = controller.conversations[index];

                          return _ConversationCard(
                                conversation: conversation,
                                onTap: () {
                                  Get.toNamed(
                                    Routes.studentChat,
                                    arguments: conversation,
                                  );
                                },
                              )
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 70 * index),
                                duration: 430.ms,
                              )
                              .slideY(begin: .22, curve: Curves.easeOutCubic)
                              .scale(begin: const Offset(.97, .97));
                        },
                      ),

                      const SizedBox(height: 18),

                      if (controller.canLoadMoreConversations)
                        Obx(
                          () => _LoadMoreButton(
                            isLoading:
                                controller.isLoadingMoreConversations.value,
                            onTap: controller.loadMoreConversations,
                          ),
                        ),
                    ],
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

class _ConversationsHero extends StatelessWidget {
  const _ConversationsHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
                Icons.forum_rounded,
                color: AppColors.actionYellow,
                size: 52,
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 1800.ms,
              ),
          const SizedBox(height: 12),
          const Text(
            'شات الشركات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'تواصل مع الشركة بعد قبولك في التاسك.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentFilterCard extends GetView<StudentConversationController> {
  final VoidCallback onTap;

  const _CurrentFilterCard({required this.onTap});

  IconData _iconForTab(ConversationTabType tab) {
    switch (tab) {
      case ConversationTabType.task:
        return Icons.task_alt_rounded;
      case ConversationTabType.all:
        return Icons.forum_rounded;
      case ConversationTabType.closed:
        return Icons.lock_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tab = controller.selectedTab.value;

      return InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(.07),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.actionYellow.withOpacity(.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _iconForTab(tab),
                  color: AppColors.actionYellow,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'طريقة العرض الحالية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.selectedTabTitle(),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primaryBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textGrey,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ConversationFilterSheet extends GetView<StudentConversationController> {
  const _ConversationFilterSheet();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textGrey.withOpacity(.25),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'اختار نوع المحادثات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'بدّل طريقة العرض      .',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              _FilterOption(
                title: 'محادثات التاسكات',
                subtitle: 'المحادثات المرتبطة بتاسكات الشركات',
                icon: Icons.task_alt_rounded,
                tab: ConversationTabType.task,
              ),
              const SizedBox(height: 12),
              _FilterOption(
                title: 'كل المحادثات',
                subtitle: 'عرض كل المحادثات المتاحة',
                icon: Icons.forum_rounded,
                tab: ConversationTabType.all,
              ),
              const SizedBox(height: 12),
              _FilterOption(
                title: 'المحادثات المغلقة',
                subtitle: 'المحادثات التي تم إغلاقها',
                icon: Icons.lock_rounded,
                tab: ConversationTabType.closed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterOption extends GetView<StudentConversationController> {
  final String title;
  final String subtitle;
  final IconData icon;
  final ConversationTabType tab;

  const _FilterOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tab,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = controller.selectedTab.value == tab;

      return InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          Get.back();

          await Future.delayed(const Duration(milliseconds: 120));
          await controller.changeConversationTab(tab);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive
                  ? AppColors.primaryBlue
                  : AppColors.primaryBlue.withOpacity(.08),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(.06),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withOpacity(.14)
                      : AppColors.actionYellow.withOpacity(.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : AppColors.actionYellow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: isActive ? Colors.white : AppColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: isActive ? Colors.white70 : AppColors.textGrey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isActive
                    ? Icons.check_circle_rounded
                    : Icons.arrow_back_ios_new_rounded,
                color: isActive ? Colors.white : AppColors.textGrey,
                size: isActive ? 22 : 16,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ConversationCard extends GetView<StudentConversationController> {
  final StudentConversationModel conversation;
  final VoidCallback onTap;

  const _ConversationCard({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final taskTitle = controller.conversationTaskTitle(conversation);
    final companyName = controller.conversationCompanyName(conversation);
    final latest = controller.latestMessageText(conversation);

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.07),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.actionYellow.withOpacity(.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: AppColors.actionYellow,
                    size: 30,
                  ),
                ),
                if (conversation.unreadMessagesCount > 0)
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        conversation.unreadMessagesCount.toString(),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    taskTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.primaryBlue,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    latest,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _MiniBadge(
                        icon: Icons.circle_rounded,
                        text: conversation.status == 'open'
                            ? 'مفتوحة'
                            : 'مغلقة',
                        color: conversation.status == 'open'
                            ? Colors.green
                            : AppColors.textGrey,
                      ),
                      _MiniBadge(
                        icon: Icons.business_rounded,
                        text: companyName,
                        color: AppColors.actionYellow,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textGrey,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MiniBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final shownText = text.trim().isEmpty ? 'غير محدد' : text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(
            shownText,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _LoadMoreButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.actionYellow,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'تحميل المزيد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

class _EmptyConversations extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyConversations({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 35),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.mark_chat_unread_outlined,
            color: AppColors.actionYellow,
            size: 70,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
