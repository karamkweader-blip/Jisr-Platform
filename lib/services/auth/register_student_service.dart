import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/auth/register_student_model.dart';

class RegisterStudentService {
  Future<Map<String, dynamic>> register(RegisterStudentModel model) async {
    final response = await http.post(
      Uri.parse(ApiLinks.register),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(model.toJson()),
    );

    return {
      'statusCode': response.statusCode,
      'data': jsonDecode(response.body),
    };
  }
}
