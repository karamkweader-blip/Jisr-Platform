import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_candidate_model.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyOpportunityCandidateService {
  final AuthService _authService;

  CompanyOpportunityCandidateService(
    this._authService,
  );

  Future<Map<String, String>> _headers() async {
    final token =
        (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw Exception(
        'انتهت الجلسة، يرجى تسجيل الدخول مجددًا',
      );
    }

    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _printCandidatesResponse({
    required int opportunityId,
    required Uri requestUrl,
    required http.Response response,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('');
    debugPrint(
      '========== OPPORTUNITY CANDIDATES RESPONSE ==========',
    );
    debugPrint(
      'OPPORTUNITY ID: $opportunityId',
    );
    debugPrint(
      'REQUEST URL: $requestUrl',
    );
    debugPrint(
      'STATUS CODE: ${response.statusCode}',
    );
    debugPrint(
      'RESPONSE HEADERS: ${response.headers}',
    );
    debugPrint(
      'RESPONSE BODY:',
    );

    if (response.body.trim().isEmpty) {
      debugPrint(
        '[EMPTY RESPONSE BODY]',
      );
    } else {
      debugPrint(
        response.body,
        wrapWidth: 1024,
      );
    }

    debugPrint(
      '=====================================================',
    );
    debugPrint('');
  }

  Future<List<CompanyOpportunityCandidate>> getCandidates(
    int opportunityId,
  ) async {
    if (opportunityId <= 0) {
      throw Exception(
        'معرف الفرصة غير صالح',
      );
    }

    final body = await _get(
      ApiLinks.companyOpportunityCandidates(
        opportunityId,
      ),
      printCandidatesResponse: true,
      opportunityId: opportunityId,
    );

    return opportunityList(body['data'])
        .map(
          (item) => CompanyOpportunityCandidate.fromJson(
            opportunityMap(item),
          ),
        )
        .where(
          (candidate) => candidate.applicationId > 0,
        )
        .toList();
  }

  Future<CompanyOpportunityCandidate> getCandidate(
    int opportunityId,
    int applicationId,
  ) async {
    if (opportunityId <= 0 ||
        applicationId <= 0) {
      throw Exception(
        'بيانات المرشح غير صالحة',
      );
    }

    final body = await _get(
      ApiLinks.companyOpportunityCandidateDetails(
        opportunityId,
        applicationId,
      ),
    );

    final data = opportunityMap(
      body['data'],
    );

    if (data.isEmpty) {
      throw Exception(
        'استجابة بيانات المرشح غير صالحة',
      );
    }

    return CompanyOpportunityCandidate.fromJson(
      data,
    );
  }

  Future<Map<String, dynamic>> _get(
    String url, {
    bool printCandidatesResponse = false,
    int? opportunityId,
  }) async {
    try {
      final requestUrl = Uri.parse(url);

      final response = await http
          .get(
            requestUrl,
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (printCandidatesResponse) {
        _printCandidatesResponse(
          opportunityId: opportunityId ?? 0,
          requestUrl: requestUrl,
          response: response,
        );
      }

      final decoded = response.body.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);

      if (decoded is! Map) {
        throw const FormatException();
      }

      final body = Map<String, dynamic>.from(
        decoded,
      );

      final hasSuccessfulStatusCode =
          response.statusCode >= 200 &&
              response.statusCode < 300;

      final hasSuccessfulResponseBody =
          body['status'] != false &&
              body['success'] != false;

      if (hasSuccessfulStatusCode &&
          hasSuccessfulResponseBody) {
        return body;
      }

      throw Exception(
        body['message']?.toString() ??
            'تعذر تحميل المرشحين',
      );
    } on TimeoutException {
      throw Exception(
        'انتهت مهلة الاتصال بالخادم',
      );
    } on FormatException {
      throw Exception(
        'تعذر قراءة استجابة المرشحين',
      );
    } catch (error) {
      throw Exception(
        error
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    }
  }
}