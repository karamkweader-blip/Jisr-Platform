import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/conversations/student_conversation_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_error_state.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_loading_state.dart';
import 'package:jisr_platform/core/widgets/conversations/chat_message_bubble.dart.dart';
import 'package:jisr_platform/core/widgets/conversations/message_info_sheet.dart';
import 'package:jisr_platform/models/student/conversations/student_conversation_model.dart';

class StudentChatView extends GetView<StudentConversationController> {
  const StudentChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Obx(() {
          final conversation = controller.selectedConversation.value;

          if (conversation == null) {
            return JisrErrorState(
              message: 'لم يتم تحديد المحادثة المطلوبة.',
              onRetry: () => Get.back(),
            );
          }

          return Column(
            children: [
              _buildTaskContext(),
              Expanded(child: _buildMessages(context)),
              _buildBottomArea(),
            ],
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.cardWhite,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textDark,
          size: 20,
        ),
      ),
      titleSpacing: 0,
      title: Obx(() {
        final conversation = controller.selectedConversation.value;
        if (conversation == null) return const Text('المحادثة');

        final participant = controller.otherParticipant(conversation);
        final companyName = controller.participantName(conversation);

        return Row(
          children: [
            _ChatAvatar(
              name: companyName,
              imageUrl: participant?.profilePictureUrl,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    controller.currentTaskTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        Obx(
          () => IconButton(
            tooltip: 'تحديث',
            onPressed: controller.isLoadingMessages.value
                ? null
                : () {
                    final conversation = controller.selectedConversation.value;
                    if (conversation != null) {
                      controller.fetchMessages(conversation.id);
                    }
                  },
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _buildTaskContext() {
    return Obx(() {
      final task = controller.conversationContext.value?.task;
      if (task == null) return const SizedBox.shrink();

      final deadline = controller.formatDate(task.deadline);
      final status = controller.assignmentStatusLabel(task.assignmentStatus);

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.06),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.10),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
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
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textDark,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (deadline.isNotEmpty || status.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (status.isNotEmpty) status,
                        if (deadline.isNotEmpty) 'الموعد: $deadline',
                      ].join(' • '),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMessages(BuildContext context) {
    if (controller.isLoadingMessages.value && controller.messages.isEmpty) {
      return const JisrLoadingState(message: 'جارٍ تحميل الرسائل...');
    }

    final error = controller.messagesError.value;
    if (error != null && controller.messages.isEmpty) {
      final conversation = controller.selectedConversation.value;
      return JisrErrorState(
        message: error,
        onRetry: conversation == null
            ? null
            : () => controller.fetchMessages(conversation.id),
      );
    }

    if (controller.messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: AppColors.textGrey,
              ),
              SizedBox(height: 12),
              Text(
                'ابدأ المحادثة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'يمكنك التواصل مع الشركة بخصوص تنفيذ المهمة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final reverseIndex = controller.messages.length - 1 - index;
        final message = controller.messages[reverseIndex];

        return ChatMessageBubble(
          content: controller.displayMessageContent(message),
          isMine: message.isMine,
          isRead: message.isRead,
          isSystem: message.isSystem,
          timeText: controller.formatTime(message.createdAt),
          onLongPress: message.isMine
              ? () => _showMessageInfo(context, message)
              : null,
        );
      },
    );
  }

  Widget _buildBottomArea() {
    if (controller.isConversationClosed) {
      return SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            border: Border(
              top: BorderSide(color: AppColors.textGrey.withOpacity(0.10)),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 17,
                color: AppColors.textGrey,
              ),
              SizedBox(width: 7),
              Flexible(
                child: Text(
                  'هذه المحادثة مغلقة ومتاحة للقراءة فقط',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          border: Border(
            top: BorderSide(color: AppColors.textGrey.withOpacity(0.10)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller.messageController,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontFamily: 'Cairo'),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 11,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Obx(
              () => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      controller.isSending.value ? null : controller.sendMessage,
                  borderRadius: BorderRadius.circular(50),
                  child: Ink(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: controller.isSending.value
                        ? const Padding(
                            padding: EdgeInsets.all(13),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.cardWhite,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: AppColors.cardWhite,
                            size: 20,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageInfo(
    BuildContext context,
    ConversationMessageModel message,
  ) {
    final readTime =
        message.isRead ? controller.formatTime(message.readAt) : null;
    final readRelative =
        message.isRead ? controller.relativeTime(message.readAt) : '';

    Get.bottomSheet(
      MessageInfoSheet(
        sentAt: controller.formatTime(message.createdAt),
        readStatus: controller.readStatusText(message),
        readAt: message.isRead
            ? [
                if (readTime != null && readTime.isNotEmpty) readTime,
                if (readRelative.isNotEmpty) readRelative,
              ].join(' • ')
            : null,
        canEdit: controller.canEditMessage(message),
        onEdit: () {
          Get.back();
          Future.microtask(() => _showEditSheet(context, message));
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showEditSheet(
    BuildContext context,
    ConversationMessageModel message,
  ) {
    controller.prepareEditMessage(message);

    Get.bottomSheet(
      Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
              decoration: const BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textGrey.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
                      SizedBox(width: 8),
                      Text(
                        'تعديل الرسالة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.editMessageController,
                    minLines: 2,
                    maxLines: 5,
                    autofocus: true,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      hintText: 'نص الرسالة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isUpdating.value
                            ? null
                            : () => controller.updateMessage(message),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.cardWhite,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: controller.isUpdating.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.cardWhite,
                                ),
                              )
                            : const Text(
                                'حفظ التعديل',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _ChatAvatar({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final letter = name.trim().isEmpty ? '؟' : name.trim()[0];

    return Container(
      width: 38,
      height: 38,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.10),
        shape: BoxShape.circle,
      ),
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _AvatarLetter(letter: letter),
            )
          : _AvatarLetter(letter: letter),
    );
  }
}

class _AvatarLetter extends StatelessWidget {
  final String letter;

  const _AvatarLetter({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
