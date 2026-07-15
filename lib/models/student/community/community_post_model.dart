class CommunityPostsResponse {
  final bool status;
  final String message;
  final List<CommunityPost> posts;
  final CommunityPagination pagination;

  CommunityPostsResponse({
    required this.status,
    required this.message,
    required this.posts,
    required this.pagination,
  });

  factory CommunityPostsResponse.fromJson(Map<String, dynamic> json) {
    return CommunityPostsResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      posts: ((json['data'] as List?) ?? [])
          .map((item) => CommunityPost.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      pagination: CommunityPagination.fromJson(
        Map<String, dynamic>.from(json['pagination'] ?? {}),
      ),
    );
  }
}

class CommunityPostResponse {
  final bool status;
  final String message;
  final CommunityPost? post;

  CommunityPostResponse({
    required this.status,
    required this.message,
    required this.post,
  });

  factory CommunityPostResponse.fromJson(Map<String, dynamic> json) {
    final rawPost = json['data'];
    return CommunityPostResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      post: rawPost == null
          ? null
          : CommunityPost.fromJson(Map<String, dynamic>.from(rawPost)),
    );
  }
}

class CommunityLikeResponse {
  final bool liked;
  final int likeCount;

  CommunityLikeResponse({required this.liked, required this.likeCount});

  factory CommunityLikeResponse.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] ?? {});
    return CommunityLikeResponse(
      liked: data['liked'] == true,
      likeCount: _toInt(data['like_count']),
    );
  }
}

class CommunityPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  CommunityPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  factory CommunityPagination.fromJson(Map<String, dynamic> json) {
    return CommunityPagination(
      currentPage: _toInt(json['current_page'], fallback: 1),
      lastPage: _toInt(json['last_page'], fallback: 1),
      perPage: _toInt(json['per_page'], fallback: 10),
      total: _toInt(json['total']),
      hasMore: json['has_more'] == true,
    );
  }

  factory CommunityPagination.empty() {
    return CommunityPagination(
      currentPage: 1,
      lastPage: 1,
      perPage: 10,
      total: 0,
      hasMore: false,
    );
  }
}

class CommunityPost {
  final int id;
  final String content;
  final String type;
  final int likeCount;
  final int commentCount;
  final bool isOwner;
  final bool isLiked;
  final CommunityAuthor author;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommunityPost({
    required this.id,
    required this.content,
    required this.type,
    required this.likeCount,
    required this.commentCount,
    required this.isOwner,
    required this.isLiked,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final authorJson = json['user'] ?? json['author'] ?? {};

    return CommunityPost(
      id: _toInt(json['id']),
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'discussion',
      likeCount: _toInt(json['like_count']),
      commentCount: _toInt(json['comment_count']),
      isOwner: json['is_owner'] == true,
      isLiked: json['is_liked'] == true,
      author: CommunityAuthor.fromJson(Map<String, dynamic>.from(authorJson)),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );
  }

  CommunityPost copyWith({
    String? content,
    String? type,
    int? likeCount,
    int? commentCount,
    bool? isOwner,
    bool? isLiked,
    CommunityAuthor? author,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityPost(
      id: id,
      content: content ?? this.content,
      type: type ?? this.type,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isOwner: isOwner ?? this.isOwner,
      isLiked: isLiked ?? this.isLiked,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CommunityAuthor {
  final int id;
  final String name;
  final String? email;
  final String? profilePictureUrl;

  CommunityAuthor({
    required this.id,
    required this.name,
    this.email,
    this.profilePictureUrl,
  });

  factory CommunityAuthor.fromJson(Map<String, dynamic> json) {
    return CommunityAuthor(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? 'طالب جسور',
      email: json['email']?.toString(),
      profilePictureUrl: json['profile_picture_url']?.toString(),
    );
  }
}

class CommunityPostTypeOption {
  final String value;
  final String arabicTitle;
  final String arabicDescription;

  const CommunityPostTypeOption({
    required this.value,
    required this.arabicTitle,
    required this.arabicDescription,
  });
}

const List<CommunityPostTypeOption> communityPostTypes = [
  CommunityPostTypeOption(
    value: 'question',
    arabicTitle: 'سؤال تقني',
    arabicDescription: 'مشكلة أو مفهوم بدك جواب واضح عليه',
  ),
  CommunityPostTypeOption(
    value: 'discussion',
    arabicTitle: 'نقاش',
    arabicDescription: 'موضوع مفتوح للآراء وتجارب الطلاب',
  ),
  CommunityPostTypeOption(
    value: 'help',
    arabicTitle: 'طلب مساعدة',
    arabicDescription: 'مشكلة عملية وتحتاج حدا يساعدك',
  ),
  CommunityPostTypeOption(
    value: 'tip',
    arabicTitle: 'نصيحة',
    arabicDescription: 'فائدة قصيرة أو Best Practice',
  ),
];

String communityTypeArabic(String type) {
  return communityPostTypes
      .firstWhere(
        (item) => item.value == type,
        orElse: () => communityPostTypes[1],
      )
      .arabicTitle;
}

String communityTypeDescription(String type) {
  return communityPostTypes
      .firstWhere(
        (item) => item.value == type,
        orElse: () => communityPostTypes[1],
      )
      .arabicDescription;
}


class CommunityCommentsResponse {
  final bool status;
  final String message;
  final List<CommunityComment> comments;

  CommunityCommentsResponse({
    required this.status,
    required this.message,
    required this.comments,
  });

  factory CommunityCommentsResponse.fromJson(Map<String, dynamic> json) {
    return CommunityCommentsResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      comments: ((json['data'] as List?) ?? [])
          .map((item) => CommunityComment.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class CommunityCommentResponse {
  final bool status;
  final String message;
  final CommunityComment? comment;

  CommunityCommentResponse({
    required this.status,
    required this.message,
    required this.comment,
  });

  factory CommunityCommentResponse.fromJson(Map<String, dynamic> json) {
    final rawComment = json['data'];
    return CommunityCommentResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      comment: rawComment == null
          ? null
          : CommunityComment.fromJson(Map<String, dynamic>.from(rawComment)),
    );
  }
}

class CommunityComment {
  final int id;
  final int postId;
  final int? parentCommentId;
  final String content;
  final int repliesCount;
  final int likesCount;
  final bool isOwner;
  final bool isLiked;
  final CommunityAuthor user;
  final List<CommunityComment> replies;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommunityComment({
    required this.id,
    required this.postId,
    required this.parentCommentId,
    required this.content,
    required this.repliesCount,
    required this.likesCount,
    required this.isOwner,
    required this.isLiked,
    required this.user,
    required this.replies,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: _toInt(json['id']),
      postId: _toInt(json['post_id']),
      parentCommentId: json['parent_comment_id'] == null
          ? null
          : _toInt(json['parent_comment_id']),
      content: json['content']?.toString() ?? '',
      repliesCount: _toInt(json['replies_count']),
      likesCount: _toInt(json['likes_count'] ?? json['like_count']),
      isOwner: json['is_owner'] == true,
      isLiked: json['is_liked'] == true,
      user: CommunityAuthor.fromJson(
        Map<String, dynamic>.from(json['user'] ?? json['author'] ?? {}),
      ),
      replies: ((json['replies'] as List?) ?? [])
          .map((item) => CommunityComment.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );
  }

  CommunityComment copyWith({
    String? content,
    int? repliesCount,
    int? likesCount,
    bool? isOwner,
    bool? isLiked,
    CommunityAuthor? user,
    List<CommunityComment>? replies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityComment(
      id: id,
      postId: postId,
      parentCommentId: parentCommentId,
      content: content ?? this.content,
      repliesCount: repliesCount ?? this.repliesCount,
      likesCount: likesCount ?? this.likesCount,
      isOwner: isOwner ?? this.isOwner,
      isLiked: isLiked ?? this.isLiked,
      user: user ?? this.user,
      replies: replies ?? this.replies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CommunityCommentFilterOption {
  final String value;
  final String arabicTitle;
  final IconDataPlaceholder icon;

  const CommunityCommentFilterOption({
    required this.value,
    required this.arabicTitle,
    required this.icon,
  });
}

// Placeholder بسيط حتى يضل المودل مستقل عن Flutter Material.
class IconDataPlaceholder {
  final String name;
  const IconDataPlaceholder(this.name);
}

const List<CommunityCommentFilterOption> communityCommentFilters = [
  CommunityCommentFilterOption(
    value: 'latest',
    arabicTitle: 'الأحدث',
    icon: IconDataPlaceholder('latest'),
  ),
  CommunityCommentFilterOption(
    value: 'top',
    arabicTitle: 'الأفضل',
    icon: IconDataPlaceholder('top'),
  ),
  CommunityCommentFilterOption(
    value: 'oldest',
    arabicTitle: 'الأقدم',
    icon: IconDataPlaceholder('oldest'),
  ),
];

String communityCommentFilterArabic(String filter) {
  return communityCommentFilters
      .firstWhere(
        (item) => item.value == filter,
        orElse: () => communityCommentFilters.first,
      )
      .arabicTitle;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? fallback;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}
