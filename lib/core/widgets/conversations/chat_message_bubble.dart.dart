import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class ChatMessageBubble extends StatelessWidget {
  final String content;
  final bool isMine;
  final bool isRead;
  final bool isSystem;
  final String timeText;
  final VoidCallback? onLongPress;

  const ChatMessageBubble({
    super.key,
    required this.content,
    required this.isMine,
    required this.isRead,
    required this.isSystem,
    required this.timeText,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (isSystem) {
      return _SystemMessage(
        content: content,
      );
    }

    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(
            13,
            10,
            13,
            7,
          ),
          decoration: BoxDecoration(
            color: isMine
                ? AppColors.primaryBlue
                : AppColors.cardWhite,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(
                isMine ? 18 : 5,
              ),
              bottomRight: Radius.circular(
                isMine ? 5 : 18,
              ),
            ),
            border: isMine
                ? null
                : Border.all(
                    color: AppColors.textGrey.withOpacity(0.12),
                  ),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: TextStyle(
                  color: isMine
                      ? AppColors.cardWhite
                      : AppColors.textDark,
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeText,
                    style: TextStyle(
                      color: isMine
                          ? AppColors.cardWhite.withOpacity(0.70)
                          : AppColors.textGrey,
                      fontSize: 9.5,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 5),
                    Icon(
                      isRead
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 15,
                      color: isRead
                          ? AppColors.cardWhite
                          : AppColors.cardWhite.withOpacity(0.60),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  final String content;

  const _SystemMessage({
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 24,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          content,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 11.5,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}