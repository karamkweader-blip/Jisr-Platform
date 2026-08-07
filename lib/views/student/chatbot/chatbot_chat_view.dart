import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/chatbot/chatbot_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/student/chatbot/chatbot_models.dart';

class ChatbotChatView extends StatefulWidget {
  const ChatbotChatView({super.key});

  @override
  State<ChatbotChatView> createState() => _ChatbotChatViewState();
}

class _ChatbotChatViewState extends State<ChatbotChatView> {
  final ChatbotController controller = Get.find<ChatbotController>();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late final int conversationId;

  @override
  void initState() {
    super.initState();
    conversationId = Get.arguments as int;
    scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (controller.activeConversation.value?.id != conversationId || controller.messages.isEmpty) {
        await controller.openConversation(conversationId);
      }
      _scrollToBottom();
    });
  }

  void _onScroll() async {
    if (scrollController.position.pixels <= 100 && controller.hasMoreMessages) {
      final oldExtent = scrollController.position.maxScrollExtent;
      await controller.loadOlderMessages();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        final addedExtent = scrollController.position.maxScrollExtent - oldExtent;
        scrollController.jumpTo(scrollController.offset + addedExtent);
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;
    textController.clear();
    _scrollToBottom();
    await controller.sendMessage(text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          centerTitle: true,
          title: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.activeConversation.value?.title ?? 'مساعد جسر',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primaryBlue, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (controller.activeConversation.value != null)
                    Text(controller.activeConversation.value!.mode.arabicLabel, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey, fontSize: 10.5)),
                ],
              )),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () => controller.openConversation(conversationId),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoadingMessages.value && controller.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                }
                if (controller.messages.isEmpty) {
                  return const Center(child: Text('لا توجد رسائل في هذه المحادثة', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey)));
                }
                return ListView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                  itemCount: controller.messages.length + (controller.isLoadingOlderMessages.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (controller.isLoadingOlderMessages.value && index == 0) {
                      return const Padding(padding: EdgeInsets.all(10), child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))));
                    }
                    final actualIndex = controller.isLoadingOlderMessages.value ? index - 1 : index;
                    final message = controller.messages[actualIndex];
                    return _MessageBubble(
                      message: message,
                      onRetry: message.isFailed ? () => controller.retryMessage(message) : null,
                      onAction: controller.openOpportunity,
                    );
                  },
                );
              }),
            ),
            _Composer(controller: textController, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.onAction, this.onRetry});
  final ChatbotMessage message;
  final VoidCallback? onRetry;
  final void Function(ChatbotAction) onAction;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final textDirection = message.language == 'ar' ? TextDirection.rtl : TextDirection.ltr;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onRetry,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .82),
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: message.isFailed
                ? Colors.red.shade50
                : isUser
                    ? AppColors.primaryBlue
                    : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isUser ? 18 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 18),
            ),
            border: isUser ? null : Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Directionality(
                textDirection: textDirection,
                child: Text(
                  message.content,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontFamily: 'Cairo', height: 1.55, color: isUser && !message.isFailed ? Colors.white : Colors.black87),
                ),
              ),
              if (message.isPending) ...[
                const SizedBox(height: 7),
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.8, color: Colors.white70)),
              ],
              if (message.isFailed) ...[
                const SizedBox(height: 7),
                Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.refresh_rounded, size: 16, color: Colors.redAccent),
                  SizedBox(width: 4),
                  Text('فشل الإرسال — اضغط لإعادة المحاولة', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.redAccent)),
                ]),
              ],
              if (message.actions.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...message.actions.where((action) => action.canOpenOpportunity).map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: OutlinedButton.icon(
                          onPressed: () => onAction(action),
                          icon: const Icon(Icons.open_in_new_rounded, size: 17),
                          label: Text(action.label, style: const TextStyle(fontFamily: 'Cairo')),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryBlue),
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

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 16, offset: const Offset(0, -4))]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                maxLength: 2000,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(fontFamily: 'Cairo'),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'اكتب رسالتك...',
                  hintStyle: const TextStyle(fontFamily: 'Cairo'),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Material(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onSend,
                borderRadius: BorderRadius.circular(16),
                child: const SizedBox(width: 50, height: 50, child: Icon(Icons.send_rounded, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
