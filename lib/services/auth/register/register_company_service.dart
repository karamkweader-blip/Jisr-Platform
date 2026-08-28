import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_exception.dart';
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/core/api/api_response_handler.dart';
import 'package:jisr_platform/models/auth/register_company_request.dart';

class RegisterCompanyService {
  Future<void> register(
    RegisterCompanyRequest request,
  ) async {
    try {
      final multipartRequest = http.MultipartRequest(
        'POST',
        Uri.parse(ApiLinks.register),
      );

      multipartRequest.headers.addAll(
        const {
          'Accept': 'application/json',
        },
      );

      multipartRequest.fields.addAll(
        request.toFields(),
      );

      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          'documentation_file',
          request.documentationFilePath,
        ),
      );

      final streamedResponse =
          await multipartRequest
              .send()
              .timeout(
                const Duration(seconds: 30),
              );

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.registerCompany,
      );
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.registerCompany,
      );
    }
  }
}