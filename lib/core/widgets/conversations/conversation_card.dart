import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class ConversationCard extends StatelessWidget {
  final String taskTitle;
  final String participantName;
  final String? profilePictureUrl;
  final String latestMessage;
  final String timeText;
  final int unreadCount;
  final bool isClosed;
  final bool isLatestMessageMine;
  final VoidCallback onTap;

  const ConversationCard({
    super.key,
    required this.taskTitle,
    required this.participantName,
    required this.profilePictureUrl,
    required this.latestMessage,
    required this.timeText,
    required this.unreadCount,
    required this.isClosed,
    required this.isLatestMessageMine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasUnread
                  ? AppColors.primaryBlue.withOpacity(0.22)
                  : AppColors.textGrey.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ParticipantAvatar(
                name: participantName,
                profilePictureUrl: profilePictureUrl,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            taskTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 15,
                              fontWeight: hasUnread
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (timeText.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            timeText,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            participantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isClosed) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textGrey.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 12,
                                  color: AppColors.textGrey,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'مغلقة',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${isLatestMessageMine ? 'أنت: ' : ''}$latestMessage',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: hasUnread
                                  ? AppColors.textDark
                                  : AppColors.textGrey,
                              fontSize: 12.5,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 10),
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 22,
                              minHeight: 22,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: AppColors.cardWhite,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  final String name;
  final String? profilePictureUrl;

  const _ParticipantAvatar({
    required this.name,
    required this.profilePictureUrl,
  });

  @override
  Widget build(BuildContext context) {
    final url = profilePictureUrl?.trim();

    final firstLetter =
        name.trim().isEmpty ? '؟' : name.trim()[0];

    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.10),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _InitialAvatar(
                  letter: firstLetter,
                );
              },
            )
          : _InitialAvatar(
              letter: firstLetter,
            ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String letter;

  const _InitialAvatar({
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        letter.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}