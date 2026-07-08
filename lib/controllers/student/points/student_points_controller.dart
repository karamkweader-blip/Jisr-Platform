import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/points/student_points_model.dart';
import 'package:jisr_platform/services/student/points/student_points_service.dart';

class StudentPointsController extends GetxController {
  final StudentPointsService _service = StudentPointsService();
  final ScrollController scrollController = ScrollController();

  int totalPoints = 0;
  final List<StudentPointRecord> history = <StudentPointRecord>[];
  StudentPointsMeta meta = StudentPointsMeta.empty();

  bool isLoadingSummary = false;
  bool isLoadingHistory = false;
  bool isLoadingMore = false;
  bool isRefreshing = false;
  String? errorMessage;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    final shouldLoad = position.pixels >= position.maxScrollExtent - 240;

    if (shouldLoad && meta.hasMore && !isLoadingMore && !isLoadingHistory) {
      fetchMoreHistory();
    }
  }

  Future<void> fetchAll({bool refresh = false, bool silent = false}) async {
    if (refresh) isRefreshing = true;
    await Future.wait([
      fetchSummary(silent: silent),
      fetchHistory(refresh: true, silent: silent),
    ]);
    isRefreshing = false;
    update();
  }

  Future<void> fetchSummary({bool silent = false}) async {
    if (!silent) {
      isLoadingSummary = true;
      errorMessage = null;
      update();
    }

    try {
      final response = await _service.getMyPoints();
      totalPoints = response.totalPoints;
    } catch (e) {
      errorMessage = _cleanError(e);
      if (!silent) {
        JisrSnackbar.show(
          title: 'خطأ',
          message: errorMessage!,
          type: JisrSnackbarType.error,
        );
      }
    } finally {
      isLoadingSummary = false;
      update();
    }
  }

  Future<void> fetchHistory({bool refresh = false, bool silent = false}) async {
    if (refresh) meta = StudentPointsMeta.empty();
    if (!silent) {
      isLoadingHistory = true;
      errorMessage = null;
      update();
    }

    try {
      final response = await _service.getPointsHistory(page: 1);
      history
        ..clear()
        ..addAll(response.records);
      meta = response.meta;
    } catch (e) {
      errorMessage = _cleanError(e);
      if (!silent) {
        JisrSnackbar.show(
          title: 'خطأ',
          message: errorMessage!,
          type: JisrSnackbarType.error,
        );
      }
    } finally {
      isLoadingHistory = false;
      update();
    }
  }

  Future<void> fetchMoreHistory() async {
    if (!meta.hasMore) return;

    isLoadingMore = true;
    update();

    try {
      final response = await _service.getPointsHistory(page: meta.currentPage + 1);
      history.addAll(response.records);
      meta = response.meta;
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

  String formatDate(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}
