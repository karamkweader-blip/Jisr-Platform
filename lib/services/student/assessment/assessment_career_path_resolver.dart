import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/services/student/assessment/assessment_learning_plan_cache.dart';
import 'package:jisr_platform/services/student/market_analysis/market_analysis_service.dart';

class AssessmentCareerPathResolver {
  final MarketAnalysisService _marketService = MarketAnalysisService();
  final AssessmentLearningPlanCache _learningPlanCache =
      AssessmentLearningPlanCache();

  Future<int?> resolveForCv({required int cvId}) async {
    if (cvId <= 0) {
      throw Exception('تعذر تحديد السيرة الذاتية المطلوبة للاختبار.');
    }

    final response = await _marketService.getCareerPaths(
      onlyWithMarketData: false,
    );

    final paths = response.careerPaths
        .where((path) => path.id > 0)
        .toList(growable: false);

    if (paths.isEmpty) {
      throw Exception('لا توجد مسارات مهنية متاحة لبدء الاختبار حالياً.');
    }

    // إذا كانت نفس السيرة قد استُخدمت سابقاً مع مسار صالح وما زال موجوداً
    // في بيانات الباك، نعيد استخدامه بدون أي ID ثابت.
    final cached = await _learningPlanCache.read();
    if (cached != null && cached.cvId == cvId && cached.careerPathId > 0) {
      for (final path in paths) {
        if (path.id == cached.careerPathId) return path.id;
      }
    }

    if (paths.length == 1) return paths.first.id;

    return Get.dialog<int>(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'اختاري المسار المهني',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: paths.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final path = paths[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    path.name,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: path.description.trim().isEmpty
                      ? null
                      : Text(
                          path.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                  trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  onTap: () => Get.back(result: path.id),
                );
              },
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
