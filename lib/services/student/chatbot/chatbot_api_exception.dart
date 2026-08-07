class ChatbotApiException implements Exception {
  const ChatbotApiException({
    required this.statusCode,
    required this.message,
    this.fieldErrors = const {},
    this.isTimeout = false,
  });

  final int statusCode;
  final String message;
  final Map<String, List<String>> fieldErrors;
  final bool isTimeout;

  bool get canRetry => isTimeout || statusCode >= 500 || statusCode == 0;

  String get displayMessage {
    if (statusCode == 401) return 'انتهت الجلسة، يرجى تسجيل الدخول من جديد';
    if (statusCode == 403) return 'هذه الميزة متاحة لحساب الطالب فقط';
    if (statusCode == 404) return 'المحادثة غير موجودة أو تم حذفها';
    if (statusCode == 422 && fieldErrors.isNotEmpty) return fieldErrors.values.first.first;
    return message;
  }

  @override
  String toString() => displayMessage;
}
