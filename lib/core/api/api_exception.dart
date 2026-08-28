enum ApiOperation {
  generic,

  // Auth
  login,
  loginOtp,
  registerStudent,
  registerCompany,
  forgotPassword,
  verifyResetOtp,
  resendOtp,
  resetPassword,

  // Student / Company - سنستخدمهم بالمرحلة التالية
  profile,
  cv,
  assessment,
  task,
  opportunity,
  application,
  interview,
  conversation,
  complaint,
  mentor,
  notification,
  marketAnalysis,
  chatbot,
}

enum ApiFailureType {
  http,
  network,
  timeout,
  invalidResponse,
  unknown,
}

class ApiException implements Exception {
  final int? statusCode;
  final String backendMessage;
  final Map<String, List<String>> errors;
  final ApiOperation operation;
  final ApiFailureType type;
  final Object? originalError;

  const ApiException({
    this.statusCode,
    this.backendMessage = '',
    this.errors = const <String, List<String>>{},
    this.operation = ApiOperation.generic,
    this.type = ApiFailureType.http,
    this.originalError,
  });

  MapEntry<String, String>? get firstFieldError {
    for (final entry in errors.entries) {
      if (entry.value.isNotEmpty) {
        return MapEntry(entry.key, entry.value.first);
      }
    }

    return null;
  }

  String get allMessages {
    final buffer = StringBuffer();

    if (backendMessage.trim().isNotEmpty) {
      buffer.write(backendMessage.trim());
    }

    for (final messages in errors.values) {
      for (final message in messages) {
        if (message.trim().isEmpty) continue;

        if (buffer.isNotEmpty) {
          buffer.write(' ');
        }

        buffer.write(message.trim());
      }
    }

    return buffer.toString();
  }

  @override
  String toString() => 'ApiException(statusCode: $statusCode)';
}