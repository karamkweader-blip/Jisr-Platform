import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/conversations/student_conversation_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/conversations/student_conversation_model.dart';

class StudentChatView extends StatefulWidget {
  const StudentChatView({super.key});

  @override
  State<StudentChatView> createState() => _StudentChatViewState();
}

class _StudentChatViewState extends State<StudentChatView> {
  final StudentConversationController controller =
      Get.find<StudentConversationController>();

  late final StudentConversationModel conversation;

  @override
  void initState() {
    super.initState();

    conversation = Get.arguments as StudentConversationModel;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.openConversation(conversation);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskTitle = controller.conversationTaskTitle(conversation);
    final companyName = controller.conversationCompanyName(conversation);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          title: Column(
            children: [
              Text(
                taskTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                companyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => controller.fetchMessages(conversation.id),
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.actionYellow,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoadingMessages.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.actionYellow,
                    ),
                  );
                }

                if (controller.messages.isEmpty) {
                  return const _EmptyMessages();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];

                    if (controller.isSystemMessage(message)) {
                      return _SystemMessageBubble(
                        message: message,
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: .15);
                    }

                    return _ChatBubble(message: message)
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 35 * index),
                          duration: 300.ms,
                        )
                        .slideY(begin: .12);
                  },
                );
              }),
            ),
            _MessageInput(),
          ],
        ),
      ),
    );
  }
}

class _SystemMessageBubble extends StatelessWidget {
  final ConversationMessageModel message;

  const _SystemMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.actionYellow.withOpacity(.13),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.actionYellow.withOpacity(.25)),
        ),
        child: Text(
          message.content,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.primaryBlue,
            fontSize: 12,
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends GetView<StudentConversationController> {
  final ConversationMessageModel message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final canEdit = controller.canEditMessage(message);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .76,
          minWidth: 80,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isMine ? 22 : 6),
            bottomRight: Radius.circular(isMine ? 6 : 22),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.07),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Text(
                message.sender?.name ?? 'الشركة',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.actionYellow,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (!isMine) const SizedBox(height: 5),

            Text(
              message.content,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: isMine ? Colors.white : AppColors.textDark,
                height: 1.55,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: isMine
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Text(
                  controller.timeOnly(message.createdAt),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: isMine ? Colors.white70 : AppColors.textGrey,
                    fontSize: 10,
                  ),
                ),

                if (isMine) ...[
                  const SizedBox(width: 6),

                  Icon(
                    message.readAt == null
                        ? Icons.done_rounded
                        : Icons.done_all_rounded,
                    size: 16,
                    color: message.readAt == null
                        ? Colors.white70
                        : const Color(0xFF64B5F6),
                  ),

                  if (canEdit) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openEditSheet(message),
                      child: const Padding(
                        padding: EdgeInsets.all(3),
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),

            if (isMine && message.readAt != null) ...[
              const SizedBox(height: 4),
              const Text(
                'تمت القراءة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Color(0xFFBBDEFB),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openEditSheet(ConversationMessageModel message) {
    if (!controller.canEditMessage(message)) {
      JisrSnackbar.show(
        title: 'لا يمكن التعديل',
        message: 'لا يمكن تعديل الرسالة بعد قراءتها من الطرف الآخر',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    controller.prepareEditMessage(message);

    Get.bottomSheet(
      _EditMessageSheet(message: message),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _EditMessageSheet extends GetView<StudentConversationController> {
  final ConversationMessageModel message;

  const _EditMessageSheet({required this.message});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          padding: EdgeInsets.only(
            right: 22,
            left: 22,
            top: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 22,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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

                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.actionYellow.withOpacity(.14),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.actionYellow,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'تعديل الرسالة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'يمكنك تعديل رسالتك طالما لم تتم قراءتها من الطرف الآخر.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: controller.editMessageController,
                  maxLines: 5,
                  minLines: 3,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: InputDecoration(
                    hintText: 'اكتب النص الجديد...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue.withOpacity(.08),
                      ),
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
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.isUpdating.value
                        ? null
                        : () => controller.updateMessage(message),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                    icon: controller.isUpdating.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      controller.isUpdating.value
                          ? 'جار حفظ التعديل...'
                          : 'حفظ التعديل',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: controller.isUpdating.value ? null : Get.back,
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageInput extends GetView<StudentConversationController> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.messageController,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(fontFamily: 'Cairo'),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Obx(
              () => InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: controller.isSending.value
                    ? null
                    : controller.sendMessage,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: controller.isSending.value
                        ? AppColors.textGrey
                        : AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: controller.isSending.value
                      ? const Padding(
                          padding: EdgeInsets.all(15),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'لا توجد رسائل حالياً',
        style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
      ),
    );
  }
}
