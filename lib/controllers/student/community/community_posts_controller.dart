import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/controllers/student/points/student_points_controller.dart';
import 'package:jisr_platform/models/student/community/community_post_model.dart';
import 'package:jisr_platform/services/student/community/community_post_service.dart';

class CommunityPostsController extends GetxController {
  final CommunityPostService _service = CommunityPostService();

  final List<CommunityPost> posts = <CommunityPost>[];
  final List<CommunityComment> comments = <CommunityComment>[];
  final Map<int, List<CommunityComment>> repliesByComment = <int, List<CommunityComment>>{};
  final Set<int> expandedReplies = <int>{};
  final Set<int> loadingReplies = <int>{};
  CommunityPagination pagination = CommunityPagination.empty();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController editCommentController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String? selectedType;
  String formType = 'question';
  String commentsFilter = 'latest';
  CommunityPost? selectedPost;
  CommunityComment? replyingTo;
  CommunityComment? editingComment;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool isRefreshing = false;
  bool isSubmitting = false;
  bool isDeleting = false;
  bool isDetailsLoading = false;
  bool isCommentsLoading = false;
  bool isSubmittingComment = false;
  bool isUpdatingComment = false;
  bool isDeletingComment = false;
  String? errorMessage;

  int _page = 1;
  final int _perPage = 10;
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    contentController.dispose();
    commentController.dispose();
    editCommentController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    final shouldLoad = position.pixels >= position.maxScrollExtent - 280;

    if (shouldLoad && pagination.hasMore && !isLoadingMore && !isLoading) {
      fetchMorePosts();
    }
  }

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      isRefreshing = true;
    } else {
      isLoading = true;
    }
    errorMessage = null;
    _page = 1;
    update();

    try {
      final response = await _service.getPosts(
        page: _page,
        perPage: _perPage,
        search: searchController.text,
        type: selectedType,
      );

      posts
        ..clear()
        ..addAll(response.posts);
      pagination = response.pagination;
    } catch (e) {
      errorMessage = _cleanError(e);
      JisrSnackbar.show(
        title: 'خطأ',
        message: errorMessage!,
        type: JisrSnackbarType.error,
      );
    } finally {
      isLoading = false;
      isRefreshing = false;
      update();
    }
  }

  Future<void> fetchMorePosts() async {
    if (!pagination.hasMore) return;

    isLoadingMore = true;
    update();

    try {
      final nextPage = _page + 1;
      final response = await _service.getPosts(
        page: nextPage,
        perPage: _perPage,
        search: searchController.text,
        type: selectedType,
      );

      _page = response.pagination.currentPage;
      pagination = response.pagination;
      posts.addAll(response.posts);
    } catch (e) {
      JisrSnackbar.show(
        title: 'تنبيه',
        message: _cleanError(e),
        type: JisrSnackbarType.warning,
      );
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      fetchPosts();
    });
  }

  void clearSearch() {
    searchController.clear();
    fetchPosts();
  }

  void changeFilter(String? type) {
    selectedType = type;
    fetchPosts();
  }

  void prepareCreate({String? initialType}) {
    selectedPost = null;
    formType = initialType ?? selectedType ?? 'question';
    contentController.clear();
    update();
  }

  void prepareEdit(CommunityPost post) {
    selectedPost = post;
    formType = post.type;
    contentController.text = post.content;
    update();
  }

  void changeFormType(String type) {
    formType = type;
    update();
  }


  void prepareDetailsPreview(CommunityPost post) {
    selectedPost = post;
    comments.clear();
    repliesByComment.clear();
    expandedReplies.clear();
    loadingReplies.clear();
    replyingTo = null;
    editingComment = null;
    commentController.clear();
    editCommentController.clear();
    isDetailsLoading = false;
    isCommentsLoading = true;
    update();
  }

  Future<bool> submitPost() async {
    final content = contentController.text.trim();

    if (content.length < 5) {
      JisrSnackbar.show(
        title: 'انتبه',
        message: 'اكتب محتوى أوضح للمنشور، أقل شيء 5 أحرف',
        type: JisrSnackbarType.warning,
      );
      return false;
    }

    isSubmitting = true;
    update();

    try {
      if (selectedPost == null) {
        final response = await _service.createPost(content: content, type: formType);
        if (response.post != null) {
          posts.insert(0, response.post!);
          pagination = CommunityPagination(
            currentPage: pagination.currentPage,
            lastPage: pagination.lastPage,
            perPage: pagination.perPage,
            total: pagination.total + 1,
            hasMore: pagination.hasMore,
          );
        }
        _refreshPointsSilently();
        JisrSnackbar.show(
          title: 'تم النشر',
          message: 'منشورك صار بالمجتمع التقني',
          type: JisrSnackbarType.success,
        );
      } else {
        final response = await _service.updatePost(
          postId: selectedPost!.id,
          content: content,
          type: formType,
        );
        if (response.post != null) {
          _replacePost(response.post!);
          if (selectedPost?.id == response.post!.id) selectedPost = response.post!;
        }
        JisrSnackbar.show(
          title: 'تم التعديل',
          message: 'تم تحديث المنشور بنجاح',
          type: JisrSnackbarType.success,
        );
      }
      contentController.clear();
      selectedPost = null;
      return true;
    } catch (e) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: _cleanError(e),
        type: JisrSnackbarType.error,
      );
      return false;
    } finally {
      isSubmitting = false;
      update();
    }
  }

  Future<void> getDetails(int postId, {CommunityPost? fallbackPost}) async {
    isDetailsLoading = fallbackPost == null;
    if (fallbackPost != null) {
      selectedPost = fallbackPost;
      isCommentsLoading = true;
    } else {
      selectedPost = null;
    }
    update();

    try {
      final response = await _service.getPostDetails(postId);
      final loadedPost = response.post ?? fallbackPost;
      selectedPost = loadedPost;
      if (loadedPost != null) {
        _replacePost(loadedPost);
        await fetchComments(loadedPost.id, filter: commentsFilter);
      } else {
        comments.clear();
      }
    } catch (e) {
      if (fallbackPost != null) selectedPost = fallbackPost;
      comments.clear();
      JisrSnackbar.show(
        title: 'خطأ',
        message: _cleanError(e),
        type: JisrSnackbarType.error,
      );
    } finally {
      isDetailsLoading = false;
      isCommentsLoading = false;
      update();
    }
  }

  Future<void> toggleLike(CommunityPost post) async {
    final index = posts.indexWhere((item) => item.id == post.id);
    if (index == -1) return;

    final oldPost = posts[index];
    final optimisticPost = oldPost.copyWith(
      isLiked: !oldPost.isLiked,
      likeCount: oldPost.isLiked
          ? (oldPost.likeCount > 0 ? oldPost.likeCount - 1 : 0)
          : oldPost.likeCount + 1,
    );

    posts[index] = optimisticPost;
    if (selectedPost?.id == oldPost.id) selectedPost = optimisticPost;
    update();

    try {
      final response = await _service.toggleLike(post.id);
      final updated = optimisticPost.copyWith(
        isLiked: response.liked,
        likeCount: response.likeCount,
      );
      posts[index] = updated;
      if (selectedPost?.id == updated.id) selectedPost = updated;
    } catch (e) {
      posts[index] = oldPost;
      if (selectedPost?.id == oldPost.id) selectedPost = oldPost;
      JisrSnackbar.show(
        title: 'خطأ',
        message: _cleanError(e),
        type: JisrSnackbarType.error,
      );
    } finally {
      update();
    }
  }

  Future<bool> deletePost(int postId) async {
    isDeleting = true;
    update();

    try {
      await _service.deletePost(postId);
      posts.removeWhere((post) => post.id == postId);
      if (selectedPost?.id == postId) selectedPost = null;
      JisrSnackbar.show(
        title: 'تم الحذف',
        message: 'تم حذف المنشور بنجاح',
        type: JisrSnackbarType.success,
      );
      return true;
    } catch (e) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: _cleanError(e),
        type: JisrSnackbarType.error,
      );
      return false;
    } finally {
      isDeleting = false;
      update();
    }
  }

  Future<void> fetchComments(int postId, {String? filter}) async {
    isCommentsLoading = true;
    commentsFilter = filter ?? commentsFilter;
    replyingTo = null;
    editingComment = null;
    commentController.clear();
    editCommentController.clear();
    update();

    try {
      final response = await _service.getComments(
        postId: postId,
        filter: commentsFilter,
      );
      comments
        ..clear()
        ..addAll(response.comments);
      repliesByComment.clear();
      expandedReplies.clear();
    } catch (e) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: _cleanError(e),
        type: JisrSnackbarType.error,
      );
    } finally {
      isCommentsLoading = false;
      update();
    }
  }

  Future<void> changeCommentsFilter(String filter) async {
    final post = selectedPost;
    if (post == null || commentsFilter == filter) return;
    await fetchComments(post.id, filter: filter);
  }

  void prepareReply(CommunityComment comment) {
    replyingTo = comment;
    editingComment = null;
    editCommentController.clear();
    commentController.clear();
    update();
  }

  void cancelReply() {
    replyingTo = null;
    commentController.clear();
    update();
  }

  void prepareEditComment(CommunityComment comment) {
    editingComment = comment;
    replyingTo = null;
    editCommentController.text = comment.content;
    commentController.clear();
    update();
  }

  void cancelEditComment() {
    editingComment = null;
    editCommentController.clear();
    update();
  }

  Future<void> submitComment() async {
    final post = selectedPost;
    if (post == null) return;

    final content = commentController.text.trim();
    if (content.length < 2) {
      JisrSnackbar.show(
        title: 'انتبه',
        message: 'اكتب تعليق أو رد أوضح',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    isSubmittingComment = true;
    update();

    try {
      final parentId = replyingTo?.id;
      final response = await _service.addComment(
        postId: post.id,
        content: content,
        parentCommentId: parentId,
      );

      final newComment = response.comment;
      if (newComment != null) {
        if (parentId == null) {
          _insertTopLevelComment(newComment);
        } else {
          final oldReplies = List<CommunityComment>.from(repliesByComment[parentId] ?? []);
          oldReplies.insert(0, newComment);
          repliesByComment[parentId] = oldReplies;
          expandedReplies.add(parentId);
          _replaceCommentById(
            parentId,
            (old) => old.copyWith(repliesCount: old.repliesCount + 1),
          );
        }
        _changePostCommentsCount(post.id, 1);
      }

      replyingTo = null;
      commentController.clear();
      _refreshPointsSilently();
      JisrSnackbar.show(
        title: 'تم',
        message: parentId == null ? 'تمت إضافة تعليقك' : 'تمت إضافة ردك',
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: _cleanError(e),
        type: JisrSnackbarType.error,
      );
    } finally {
      isSubmittingComment = false;
      update();
    }
  }

  Future<void> submitCommentEdit() async {
    final comment = editingComment;
    if (comment == null) return;

    final content = editCommentController.text.trim();
    if (content.length < 2) {
      JisrSnackbar.show(
        title: 'انتبه',
        message: 'اكتب تعديل أوضح للتعليق',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    isUpdatingComment = true;
    update();

    try {
      final response = await _service.updateComment(
        commentId: comment.id,
        content: content,
      );
      if (response.comment != null) {
        _replaceConcreteComment(response.comment!);
      }
      editingComment = null;
      editCommentController.clear();
      JisrSnackbar.show(
        title: 'تم التعديل',
        message: 'تم تحديث التعليق بنجاح',
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: _cleanError(e),
        type: JisrSnackbarType.error,
      );
    } finally {
      isUpdatingComment = false;
      update();
    }
  }

  Future<bool> deleteComment(CommunityComment comment) async {
    isDeletingComment = true;
    update();

    try {
      await _service.deleteComment(comment.id);
      _removeComment(comment);
      _changePostCommentsCount(comment.postId, -1);
      if (editingComment?.id == comment.id) cancelEditComment();
      if (replyingTo?.id == comment.id) cancelReply();
      JisrSnackbar.show(
        title: 'تم الحذف',
        message: 'تم حذف التعليق بنجاح',
        type: JisrSnackbarType.success,
      );
      return true;
    } catch (e) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: _cleanError(e),
        type: JisrSnackbarType.error,
      );
      return false;
    } finally {
      isDeletingComment = false;
      update();
    }
  }

  Future<void> toggleReplies(CommunityComment comment) async {
    if (expandedReplies.contains(comment.id)) {
      expandedReplies.remove(comment.id);
      update();
      return;
    }

    expandedReplies.add(comment.id);
    if (repliesByComment.containsKey(comment.id)) {
      update();
      return;
    }

    loadingReplies.add(comment.id);
    update();

    try {
      final response = await _service.getReplies(comment.id);
      repliesByComment[comment.id] = response.comments;
    } catch (e) {
      expandedReplies.remove(comment.id);
      JisrSnackbar.show(
        title: 'خطأ',
        message: _cleanError(e),
        type: JisrSnackbarType.error,
      );
    } finally {
      loadingReplies.remove(comment.id);
      update();
    }
  }

  void _insertTopLevelComment(CommunityComment comment) {
    if (commentsFilter == 'oldest') {
      comments.add(comment);
    } else {
      comments.insert(0, comment);
    }
  }

  void _replaceConcreteComment(CommunityComment updated) {
    final topIndex = comments.indexWhere((item) => item.id == updated.id);
    if (topIndex != -1) {
      comments[topIndex] = updated;
      return;
    }

    for (final entry in repliesByComment.entries) {
      final replyIndex = entry.value.indexWhere((item) => item.id == updated.id);
      if (replyIndex != -1) {
        entry.value[replyIndex] = updated;
        return;
      }
    }
  }

  void _replaceCommentById(int commentId, CommunityComment Function(CommunityComment old) updateComment) {
    final index = comments.indexWhere((item) => item.id == commentId);
    if (index != -1) {
      comments[index] = updateComment(comments[index]);
    }
  }

  void _removeComment(CommunityComment comment) {
    if (comment.parentCommentId == null) {
      comments.removeWhere((item) => item.id == comment.id);
      repliesByComment.remove(comment.id);
      expandedReplies.remove(comment.id);
      return;
    }

    final parentId = comment.parentCommentId!;
    final replies = repliesByComment[parentId];
    replies?.removeWhere((item) => item.id == comment.id);
    _replaceCommentById(
      parentId,
      (old) => old.copyWith(
        repliesCount: old.repliesCount > 0 ? old.repliesCount - 1 : 0,
      ),
    );
  }

  void _changePostCommentsCount(int postId, int delta) {
    final index = posts.indexWhere((post) => post.id == postId);
    CommunityPost? updatedPost;

    if (index != -1) {
      final old = posts[index];
      updatedPost = old.copyWith(
        commentCount: (old.commentCount + delta) < 0 ? 0 : old.commentCount + delta,
      );
      posts[index] = updatedPost;
    }

    if (selectedPost?.id == postId) {
      final old = selectedPost!;
      selectedPost = updatedPost ??
          old.copyWith(
            commentCount: (old.commentCount + delta) < 0 ? 0 : old.commentCount + delta,
          );
    }
  }


  void _replacePost(CommunityPost newPost) {
    final index = posts.indexWhere((post) => post.id == newPost.id);
    if (index != -1) {
      posts[index] = newPost;
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'الآن';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';

    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }


  void _refreshPointsSilently() {
    if (Get.isRegistered<StudentPointsController>()) {
      Get.find<StudentPointsController>().fetchAll(silent: true);
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}
