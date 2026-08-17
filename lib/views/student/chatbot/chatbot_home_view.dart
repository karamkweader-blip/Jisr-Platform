import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/chatbot/chatbot_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/chatbot/chatbot_mode.dart';
import 'package:jisr_platform/models/student/chatbot/chatbot_models.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class ChatbotHomeView extends StatefulWidget {
  const ChatbotHomeView({super.key});

  @override
  State<ChatbotHomeView> createState() => _ChatbotHomeViewState();
}

class _ChatbotHomeViewState extends State<ChatbotHomeView> {
  final ChatbotController controller = Get.find<ChatbotController>();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.loadConversations(refresh: true),
    );
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 220 &&
        controller.hasMoreConversations) {
      controller.loadConversations();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _startConversation(ChatbotMode mode) async {
    final conversationId = await Get.dialog<int>(
      _StartConversationDialog(mode: mode, controller: controller),
      barrierDismissible: false,
    );
    if (!mounted || conversationId == null) return;

    await Get.toNamed(Routes.studentChatbotChat, arguments: conversationId);
  }

  Future<void> _confirmDelete(ChatbotConversation conversation) async {
    final confirmed = await Get.dialog<bool>(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'حذف المحادثة',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'سيتم حذف المحادثة من حسابك. هل أنت متأكد؟',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('تراجع', style: TextStyle(fontFamily: 'Cairo')),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(
                'حذف',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) await controller.deleteConversation(conversation);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const StudentBottomNav(currentIndex: 2),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          centerTitle: true,
          title: const Text(
            'مساعد جسر الذكي',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: RefreshIndicator(
          color: AppColors.primaryBlue,
          onRefresh: () => controller.loadConversations(refresh: true),
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'كيف يمكنني مساعدتك؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'اختر نوع المحادثة، .',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...ChatbotMode.values.map(
                      (mode) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ModeCard(
                          mode: mode,
                          onTap: () => _startConversation(mode),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'محادثاتك السابقة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
              Obx(() {
                if (controller.isLoadingConversations.value &&
                    controller.conversations.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  );
                }
                if (controller.conversations.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(
                        child: Text(
                          'لا توجد محادثات سابقة بعد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  sliver: SliverList.builder(
                    itemCount:
                        controller.conversations.length +
                        (controller.isLoadingMoreConversations.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.conversations.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        );
                      }
                      final item = controller.conversations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ConversationTile(
                          conversation: item,
                          onTap: () => Get.toNamed(
                            Routes.studentChatbotChat,
                            arguments: item.id,
                          ),
                          onDelete: () => _confirmDelete(item),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartConversationDialog extends StatefulWidget {
  const _StartConversationDialog({
    required this.mode,
    required this.controller,
  });

  final ChatbotMode mode;
  final ChatbotController controller;

  @override
  State<_StartConversationDialog> createState() =>
      _StartConversationDialogState();
}

class _StartConversationDialogState extends State<_StartConversationDialog> {
  final TextEditingController textController = TextEditingController();
  String? validationMessage;

  Future<void> _submit() async {
    final message = textController.text.trim();
    if (message.isEmpty) {
      setState(() => validationMessage = 'اكتب سؤالك الأول لبدء المحادثة');
      return;
    }

    setState(() => validationMessage = null);
    FocusManager.instance.primaryFocus?.unfocus();

    final conversation = await widget.controller.createConversation(
      mode: widget.mode,
      message: message,
    );

    if (!mounted || conversation == null) return;
    Get.back<int>(result: conversation.id);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isCreating = widget.controller.isCreatingConversation.value;
      return PopScope(
        canPop: !isCreating,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              widget.mode.arabicLabel,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: isCreating
                  ? const _CreatingConversationIndicator()
                  : TextField(
                      key: const ValueKey('conversation-message-field'),
                      controller: textController,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 2000,
                      autofocus: true,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(fontFamily: 'Cairo'),
                      decoration: InputDecoration(
                        hintText: 'اكتب أول سؤال للمساعد...',
                        hintStyle: const TextStyle(fontFamily: 'Cairo'),
                        errorText: validationMessage,
                        errorStyle: const TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onChanged: (value) {
                        if (validationMessage != null &&
                            value.trim().isNotEmpty) {
                          setState(() => validationMessage = null);
                        }
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: isCreating ? null : () => Get.back<int>(),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              FilledButton(
                onPressed: isCreating ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: AppColors.primaryBlue.withOpacity(
                    .72,
                  ),
                ),
                child: isCreating
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 9),
                          Text(
                            'جارٍ التحضير...',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ],
                      )
                    : const Text(
                        'ابدأ المحادثة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _CreatingConversationIndicator extends StatelessWidget {
  const _CreatingConversationIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      key: ValueKey('creating-conversation-indicator'),
      width: 280,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'جارٍ بدء المحادثة...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'يتم الآن تحضير رد المساعد الذكي',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.onTap});
  final ChatbotMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(.04),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(mode.icon, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.arabicLabel,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      mode.description,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.5,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Color(0xFFF4A261),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.onDelete,
  });
  final ChatbotConversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date =
        conversation.lastMessageAt?.toLocal() ??
        conversation.createdAt.toLocal();
    final formatted =
        '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryBlue.withOpacity(.10),
                child: Icon(
                  conversation.mode.icon,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conversation.lastMessagePreview ??
                          conversation.mode.arabicLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$formatted • ${conversation.mode.arabicLabel}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.5,
                        color: AppColors.primaryBlue.withOpacity(.72),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
