import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/community/community_post_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CommunityPostService {
  final AuthService _authService = AuthService();
  static const Duration _timeout = Duration(seconds: 18);

  Future<Map<String, String>> _headers() async {
    final token = (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول من جديد');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<CommunityPostsResponse> getPosts({
    int page = 1,
    int perPage = 10,
    String? search,
    String? type,
  }) async {
    final uri = Uri.parse(ApiLinks.communityPosts).replace(
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
      },
    );

    final response = await http.get(uri, headers: await _headers()).timeout(_timeout);
    final data = _decode(response.body);

    if (response.statusCode == 200) {
      return CommunityPostsResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب منشورات المجتمع التقني');
  }

  Future<CommunityPostResponse> getPostDetails(int postId) async {
    final response = await http.get(
      Uri.parse(ApiLinks.communityPostDetails(postId)),
      headers: await _headers(),
    ).timeout(_timeout);

    final data = _decode(response.body);

    if (response.statusCode == 200) {
      return CommunityPostResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب تفاصيل المنشور');
  }

  Future<CommunityPostResponse> createPost({
    required String content,
    required String type,
  }) async {
    final response = await http.post(
      Uri.parse(ApiLinks.communityPosts),
      headers: await _headers(),
      body: jsonEncode({'content': content.trim(), 'type': type.trim()}),
    ).timeout(_timeout);

    final data = _decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CommunityPostResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل إنشاء المنشور');
  }

  Future<CommunityPostResponse> updatePost({
    required int postId,
    required String content,
    required String type,
  }) async {
    final response = await http.put(
      Uri.parse(ApiLinks.communityPostDetails(postId)),
      headers: await _headers(),
      body: jsonEncode({'content': content.trim(), 'type': type.trim()}),
    ).timeout(_timeout);

    final data = _decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CommunityPostResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل تعديل المنشور');
  }

  Future<String> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse(ApiLinks.communityPostDetails(postId)),
      headers: await _headers(),
    ).timeout(_timeout);

    final data = _decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return data['message']?.toString() ?? 'تم حذف المنشور بنجاح';
    }

    throw Exception(data['message'] ?? 'فشل حذف المنشور');
  }

  Future<CommunityLikeResponse> toggleLike(int postId) async {
    final response = await http.post(
      Uri.parse(ApiLinks.communityPostLike(postId)),
      headers: await _headers(),
    ).timeout(_timeout);

    final data = _decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CommunityLikeResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل تحديث الإعجاب');
  }

  Future<CommunityCommentsResponse> getComments({
    required int postId,
    String filter = 'latest',
  }) async {
    final uri = Uri.parse(ApiLinks.communityPostComments(postId)).replace(
      queryParameters: {
        if (filter.trim().isNotEmpty) 'filter': filter.trim(),
      },
    );

    final response = await http.get(uri, headers: await _headers()).timeout(_timeout);
    final data = _decode(response.body);

    if (response.statusCode == 200) {
      return CommunityCommentsResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب التعليقات');
  }

  Future<CommunityCommentResponse> addComment({
    required int postId,
    required String content,
    int? parentCommentId,
  }) async {
    final response = await http.post(
      Uri.parse(ApiLinks.communityPostComments(postId)),
      headers: await _headers(),
      body: jsonEncode({
        'content': content.trim(),
        if (parentCommentId != null) 'parent_comment_id': parentCommentId,
      }),
    ).timeout(_timeout);

    final data = _decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CommunityCommentResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل إضافة التعليق');
  }

  Future<CommunityCommentResponse> updateComment({
    required int commentId,
    required String content,
  }) async {
    final response = await http.put(
      Uri.parse(ApiLinks.communityCommentDetails(commentId)),
      headers: await _headers(),
      body: jsonEncode({'content': content.trim()}),
    ).timeout(_timeout);

    final data = _decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CommunityCommentResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل تعديل التعليق');
  }

  Future<String> deleteComment(int commentId) async {
    final response = await http.delete(
      Uri.parse(ApiLinks.communityCommentDetails(commentId)),
      headers: await _headers(),
    ).timeout(_timeout);

    final data = _decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return data['message']?.toString() ?? 'تم حذف التعليق بنجاح';
    }

    throw Exception(data['message'] ?? 'فشل حذف التعليق');
  }

  Future<CommunityCommentsResponse> getReplies(int commentId) async {
    final response = await http.get(
      Uri.parse(ApiLinks.communityCommentReplies(commentId)),
      headers: await _headers(),
    ).timeout(_timeout);

    final data = _decode(response.body);

    if (response.statusCode == 200) {
      return CommunityCommentsResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب الردود');
  }


  Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return {};
    return Map<String, dynamic>.from(jsonDecode(body));
  }
}
