import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/market_analysis/market_analysis_models.dart';
import 'package:jisr_platform/services/student/market_analysis/market_analysis_service.dart';

class MarketAnalysisController extends GetxController {
  final MarketAnalysisService _service = MarketAnalysisService();
  final ScrollController scrollController = ScrollController();

  final List<MarketCareerPath> careerPaths = <MarketCareerPath>[];
  final List<MarketDemandSkill> skills = <MarketDemandSkill>[];
  final List<MarketTrendSkill> trends = <MarketTrendSkill>[];

  MarketCareerPath? selectedCareerPath;
  MarketSkillDemandResponse? demandResponse;
  MarketTrendResponse? trendResponse;
  String selectedSection = 'demand';

  bool isLoadingPaths = false;
  bool isLoadingInsights = false;
  bool isLoadingEvidence = false;
  bool isRefreshing = false;
  String? errorMessage;

  int get totalJobPostings => demandResponse?.totalJobPostings ?? selectedCareerPath?.totalJobPostings ?? 0;

  int get coreSkillsCount => skills.where((skill) => skill.demandLevel.toLowerCase() == 'core').length;

  double get averageDemand {
    if (skills.isEmpty) return 0;
    final total = skills.fold<double>(0, (sum, item) => sum + item.demandPercentage);
    return total / skills.length;
  }

  List<MarketDemandSkill> get topSkills {
    final sorted = [...skills];
    sorted.sort((a, b) => b.demandPercentage.compareTo(a.demandPercentage));
    return sorted.take(5).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchCareerPaths();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchCareerPaths({bool refresh = false, bool silent = false}) async {
    if (refresh) isRefreshing = true;
    if (!silent) {
      isLoadingPaths = true;
      errorMessage = null;
      update();
    }

    try {
      final response = await _service.getCareerPaths(onlyWithMarketData: true);
      careerPaths
        ..clear()
        ..addAll(response.careerPaths);

      if (careerPaths.isNotEmpty) {
        final oldId = selectedCareerPath?.id;
        MarketCareerPath? matched;
        if (oldId != null) {
          for (final item in careerPaths) {
            if (item.id == oldId) {
              matched = item;
              break;
            }
          }
        }
        selectedCareerPath = matched ?? careerPaths.first;
        await fetchInsights(silent: true);
      } else {
        selectedCareerPath = null;
        demandResponse = null;
        trendResponse = null;
        skills.clear();
        trends.clear();
      }
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
      isLoadingPaths = false;
      isRefreshing = false;
      update();
    }
  }

  Future<void> fetchInsights({bool silent = false}) async {
    final path = selectedCareerPath;
    if (path == null) return;

    if (!silent) {
      isLoadingInsights = true;
      errorMessage = null;
      update();
    }

    try {
      final results = await Future.wait([
        _service.getSkillDemand(careerPathId: path.id),
        _service.getTrends(careerPathId: path.id),
      ]);

      demandResponse = results[0] as MarketSkillDemandResponse;
      trendResponse = results[1] as MarketTrendResponse;

      skills
        ..clear()
        ..addAll(demandResponse?.skills ?? []);
      trends
        ..clear()
        ..addAll(trendResponse?.trends ?? []);
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
      isLoadingInsights = false;
      update();
    }
  }

  Future<void> refreshAll() async {
    await fetchCareerPaths(refresh: true, silent: true);
  }

  Future<void> selectCareerPath(MarketCareerPath path) async {
    if (selectedCareerPath?.id == path.id) return;
    selectedCareerPath = path;
    skills.clear();
    trends.clear();
    demandResponse = null;
    trendResponse = null;
    update();
    await fetchInsights();
  }

  void changeSection(String section) {
    selectedSection = section;
    update();
  }

  Future<MarketSkillEvidenceResponse?> loadEvidence(MarketDemandSkill skill) async {
    final path = selectedCareerPath;
    if (path == null) return null;

    // مهم: لا نستدعي update() هنا.
    // هذه الدالة تُستعمل داخل FutureBuilder في BottomSheet، وأي update أثناء build
    // يسبب الخطأ: setState() or markNeedsBuild() called during build.
    // FutureBuilder وحده مسؤول عن حالة التحميل والنجاح والفشل داخل نافذة الدليل.
    try {
      return await _service.getSkillEvidence(
        careerPathId: path.id,
        skillId: skill.skillId,
        limit: 10,
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'تعذر جلب الدليل',
        message: _cleanError(e),
        type: JisrSnackbarType.error,
      );
      return null;
    }
  }

  String demandLevelArabic(String value) {
    switch (value.toLowerCase().trim()) {
      case 'core':
        return 'أساسية';
      case 'important':
        return 'مهمة';
      case 'supporting':
        return 'داعمة';
      default:
        return 'غير محددة';
    }
  }

  String trendArabic(String value) {
    switch (value.toLowerCase().trim()) {
      case 'rising':
        return 'يرتفع';
      case 'stable':
        return 'مستقر';
      case 'falling':
        return 'ينخفض';
      case 'new':
        return 'جديد';
      default:
        return 'غير محدد';
    }
  }

  String sectionTitle() {
    switch (selectedSection) {
      case 'trends':
        return 'اتجاهات السوق';
      case 'categories':
        return 'حسب التصنيف';
      case 'demand':
      default:
        return 'المهارات المطلوبة';
    }
  }

  Color demandColor(String value) {
    switch (value.toLowerCase().trim()) {
      case 'core':
        return const Color(0xFF16A34A);
      case 'important':
        return const Color(0xFFF0A500);
      case 'supporting':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color trendColor(String value) {
    switch (value.toLowerCase().trim()) {
      case 'rising':
        return const Color(0xFF16A34A);
      case 'falling':
        return const Color(0xFFDC2626);
      case 'stable':
        return const Color(0xFF2563EB);
      case 'new':
        return const Color(0xFFF0A500);
      default:
        return const Color(0xFF64748B);
    }
  }

  String cleanDate(String value) {
    if (value.trim().isEmpty) return 'غير محدد';
    return value.split('T').first;
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}
