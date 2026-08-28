import 'package:jisr_platform/core/api/api_exception.dart';
import 'package:jisr_platform/core/api/api_response_handler.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';

class ApiErrorPresenter {
  const ApiErrorPresenter._();

 static void show(
  Object error, {
  ApiOperation operation = ApiOperation.generic,
}) {
  final apiException = _normalize(
    error,
    operation: operation,
  );

  final userError = _mapError(apiException);

  JisrSnackbar.show(
    title: userError.title,
    message: userError.message,
    type: userError.type,
  );
}

static String messageFor(
  Object error, {
  ApiOperation operation = ApiOperation.generic,
}) {
  final apiException = _normalize(
    error,
    operation: operation,
  );

  return _mapError(apiException).message;
}

static ApiException _normalize(
  Object error, {
  required ApiOperation operation,
}) {
  if (error is ApiException) {
    return error;
  }

  return ApiResponseHandler.fromError(
    error,
    operation: operation,
  );
}

  static _UserApiError _mapError(ApiException error) {
    if (error.type == ApiFailureType.network) {
      return const _UserApiError(
        title: 'تعذر الاتصال',
        message:
            'تعذر الاتصال بالخادم. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
      );
    }

    if (error.type == ApiFailureType.timeout) {
      return const _UserApiError(
        title: 'انتهت مهلة الاتصال',
        message:
            'استغرق الخادم وقتًا أطول من المتوقع. يرجى المحاولة مرة أخرى.',
      );
    }

    if (error.type == ApiFailureType.invalidResponse) {
      return const _UserApiError(
        title: 'تعذر إتمام العملية',
        message:
            'تم استلام استجابة غير صحيحة من الخادم. يرجى المحاولة مرة أخرى.',
      );
    }

    final text = error.allMessages.toLowerCase();

    // =============================
    // Account states
    // =============================

    if (_containsAny(text, const [
      'pending admin verification',
      'still pending admin verification',
    ])) {
      return const _UserApiError(
        title: 'الحساب بانتظار التوثيق',
        message:
            'حساب شركتك ما زال بانتظار موافقة الإدارة. يمكنك تسجيل الدخول بعد إتمام التوثيق.',
        type: JisrSnackbarType.warning,
      );
    }

    if (_containsAny(text, const [
      'company account has been rejected',
      'account has been rejected',
    ])) {
      return const _UserApiError(
        title: 'تم رفض توثيق الحساب',
        message:
            'تم رفض توثيق حساب الشركة. يرجى التأكد من بيانات ووثائق الشركة قبل إنشاء حساب جديد.',
        type: JisrSnackbarType.warning,
      );
    }

    if (_containsAny(text, const [
      'not verified by admin',
      'company account is not verified',
    ])) {
      return const _UserApiError(
        title: 'الحساب غير موثّق',
        message:
            'لا يمكن استخدام حساب الشركة قبل موافقة الإدارة على التوثيق.',
        type: JisrSnackbarType.warning,
      );
    }

    if (_containsAny(text, const [
      'account is blocked',
      'blocked and cannot access',
    ])) {
      return const _UserApiError(
        title: 'الحساب موقوف',
        message:
            'تم إيقاف حسابك ولا يمكنك استخدام المنصة حاليًا.',
      );
    }

    // =============================
    // Login
    // =============================

    if (_containsAny(text, const [
          'invalid email or password',
          'incorrect email or password',
          'invalid credentials',
        ]) ||
        (error.operation == ApiOperation.login &&
            (error.statusCode == 401 || error.statusCode == 404))) {
      return const _UserApiError(
        title: 'بيانات الدخول غير صحيحة',
        message:
            'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      );
    }

    // =============================
    // OTP
    // =============================

    if (_containsAny(text, const [
      'otp expired or invalid',
      'invalid otp',
      'otp is invalid',
      'invalid code',
    ])) {
      return const _UserApiError(
        title: 'رمز التحقق غير صحيح',
        message:
            'رمز التحقق غير صحيح أو انتهت صلاحيته. يرجى التأكد من الرمز والمحاولة مجددًا.',
      );
    }

    if (text.contains('please wait') &&
        text.contains('before requesting another otp')) {
      return const _UserApiError(
        title: 'انتظر قليلًا',
        message:
            'تم إرسال رمز تحقق مؤخرًا. يرجى الانتظار قليلًا قبل طلب رمز جديد.',
        type: JisrSnackbarType.warning,
      );
    }

    // =============================
    // Common business rules
    // =============================

    if (_containsAny(text, const [
      'already applied',
      'already submitted an application',
      'application already exists',
    ])) {
      return const _UserApiError(
        title: 'تم التقديم مسبقًا',
        message:
            'لقد سبق لك التقديم على هذه الفرصة.',
        type: JisrSnackbarType.warning,
      );
    }

    if (text.contains('already closed')) {
      return const _UserApiError(
        title: 'مغلق مسبقًا',
        message:
            'هذا العنصر مغلق مسبقًا ولا يمكن تنفيذ هذا الإجراء عليه.',
        type: JisrSnackbarType.warning,
      );
    }

    if (text.contains('cannot cancel') &&
        text.contains('accepted student')) {
      return const _UserApiError(
        title: 'لا يمكن الإلغاء',
        message:
            'لا يمكن إلغاء المهمة لوجود طلاب تم قبولهم عليها.',
        type: JisrSnackbarType.warning,
      );
    }

    if (text.contains('pending appeal') ||
        text.contains('already have a pending appeal')) {
      return const _UserApiError(
        title: 'يوجد اعتراض قيد المراجعة',
        message:
            'لديك اعتراض قيد المراجعة بالفعل. انتظر حتى تتم مراجعته قبل إرسال اعتراض جديد.',
        type: JisrSnackbarType.warning,
      );
    }
// =============================
// Student opportunity rules
// =============================

if (_containsAny(text, const [
  'التقديم على هذه الفرصة مسبق',
  'already applied',
  'application already exists',
])) {
  return const _UserApiError(
    title: 'تم التقديم مسبقًا',
    message: 'لقد سبق لك التقديم على هذه الفرصة.',
    type: JisrSnackbarType.warning,
  );
}

if (_containsAny(text, const [
  'يجب رفع سيرة ذاتية قبل التقديم',
  'cv is required',
])) {
  return const _UserApiError(
    title: 'السيرة الذاتية مطلوبة',
    message:
        'يجب رفع سيرة ذاتية قبل التقديم على الفرصة.',
    type: JisrSnackbarType.warning,
  );
}

if (text.contains(
  'لا يمكن سحب الطلب بعد مراجعته',
)) {
  return const _UserApiError(
    title: 'لا يمكن سحب الطلب',
    message:
        'تمت مراجعة طلب التقديم، لذلك لم يعد من الممكن سحبه.',
    type: JisrSnackbarType.warning,
  );
}

if (text.contains(
  'لا يمكن سحب الطلب بعد جدولة مقابلة',
)) {
  return const _UserApiError(
    title: 'لا يمكن سحب الطلب',
    message:
        'تم تحديد مقابلة لهذا الطلب، لذلك لم يعد من الممكن سحبه.',
    type: JisrSnackbarType.warning,
  );
}

// =============================
// Company task rules
// =============================

if (text.contains(
  'only draft tasks can be published',
)) {
  return const _UserApiError(
    title: 'لا يمكن نشر المهمة',
    message:
        'يمكن نشر المهمة فقط عندما تكون في حالة مسودة.',
    type: JisrSnackbarType.warning,
  );
}

if (text.contains(
  'at least one required skill is needed before publishing',
)) {
  return const _UserApiError(
    title: 'المهارات مطلوبة',
    message:
        'يجب إضافة مهارة مطلوبة واحدة على الأقل قبل نشر المهمة.',
    type: JisrSnackbarType.warning,
  );
}

if (text.contains(
  'task deadline must be in the future',
)) {
  return const _UserApiError(
    title: 'موعد التسليم غير صالح',
    message:
        'يجب أن يكون موعد تسليم المهمة في المستقبل قبل نشرها.',
    type: JisrSnackbarType.warning,
  );
}

if (text.contains(
  'completed or cancelled tasks cannot be updated',
)) {
  return const _UserApiError(
    title: 'لا يمكن تعديل المهمة',
    message:
        'لا يمكن تعديل مهمة مكتملة أو ملغاة.',
    type: JisrSnackbarType.warning,
  );
}

if (text.contains('هذا التاسك مغلق مسبق')) {
  return const _UserApiError(
    title: 'المهمة مغلقة مسبقًا',
    message: 'هذه المهمة مغلقة بالفعل.',
    type: JisrSnackbarType.warning,
  );
}

if (text.contains(
  'لا يمكن إغلاق التاسك قبل تقييم كل الطلاب',
)) {
  return const _UserApiError(
    title: 'لا يمكن إغلاق المهمة',
    message:
        'يجب تقييم جميع الطلاب المرتبطين بالمهمة قبل إغلاقها.',
    type: JisrSnackbarType.warning,
  );
}

if (text.contains('هذا التاسك ملغى مسبق')) {
  return const _UserApiError(
    title: 'المهمة ملغاة مسبقًا',
    message: 'هذه المهمة ملغاة بالفعل.',
    type: JisrSnackbarType.warning,
  );
}

if (text.contains(
  'لا يمكن إلغاء التاسك لوجود طلاب',
)) {
  return const _UserApiError(
    title: 'لا يمكن إلغاء المهمة',
    message:
        'لا يمكن إلغاء المهمة لوجود طلاب تم قبولهم عليها.',
    type: JisrSnackbarType.warning,
  );
}

if (text.contains('لا يمكن إلغاء تاسك مغلق')) {
  return const _UserApiError(
    title: 'لا يمكن إلغاء المهمة',
    message:
        'لا يمكن إلغاء مهمة تم إغلاقها مسبقًا.',
    type: JisrSnackbarType.warning,
  );
}

if (text.contains(
  'يمكن إلغاء التاسك فقط قبل بدء التنفيذ',
)) {
  return const _UserApiError(
    title: 'لا يمكن إلغاء المهمة',
    message:
        'يمكن إلغاء المهمة فقط قبل بدء تنفيذها.',
    type: JisrSnackbarType.warning,
  );
}
    // =============================
    // Validation
    // =============================

    if (error.statusCode == 422) {
      final arabicBusinessMessage =
          _extractArabicMessage(error.firstFieldError?.value) ??
              _extractArabicMessage(error.backendMessage);

      if (arabicBusinessMessage != null) {
        return _UserApiError(
          title: _operationTitle(error.operation),
          message: arabicBusinessMessage,
          type: JisrSnackbarType.warning,
        );
      }

      final validationMessage = _validationMessage(error);

      if (validationMessage != null) {
        return _UserApiError(
          title: 'تحقق من البيانات',
          message: validationMessage,
          type: JisrSnackbarType.warning,
        );
      }
    }

    // =============================
    // HTTP statuses
    // =============================

    if (error.statusCode == 401) {
      return const _UserApiError(
        title: 'انتهت الجلسة',
        message:
            'انتهت جلسة تسجيل الدخول. يرجى تسجيل الدخول من جديد للمتابعة.',
      );
    }

    if (error.statusCode == 403) {
      return const _UserApiError(
        title: 'غير مسموح',
        message:
            'لا تملك صلاحية تنفيذ هذا الإجراء.',
      );
    }

    if (error.statusCode == 404) {
      if (error.operation == ApiOperation.forgotPassword) {
        return const _UserApiError(
          title: 'الحساب غير موجود',
          message:
              'لا يوجد حساب مرتبط بهذا البريد الإلكتروني.',
          type: JisrSnackbarType.warning,
        );
      }

      return const _UserApiError(
        title: 'العنصر غير موجود',
        message:
            'العنصر المطلوب غير موجود أو لم يعد متاحًا.',
      );
    }

    if (error.statusCode == 409) {
      return const _UserApiError(
        title: 'تعارض في العملية',
        message:
            'تعذر تنفيذ العملية بسبب تعارض مع الحالة الحالية للبيانات.',
        type: JisrSnackbarType.warning,
      );
    }

    if (error.statusCode == 413) {
      return const _UserApiError(
        title: 'الملف كبير جدًا',
        message:
            'حجم الملف المرفوع أكبر من الحجم المسموح.',
        type: JisrSnackbarType.warning,
      );
    }

    if (error.statusCode == 429) {
      return const _UserApiError(
        title: 'محاولات كثيرة',
        message:
            'تم تنفيذ عدد كبير من المحاولات خلال وقت قصير. يرجى الانتظار قليلًا ثم المحاولة مجددًا.',
        type: JisrSnackbarType.warning,
      );
    }

    if (error.statusCode != null &&
        error.statusCode! >= 500) {
      return const _UserApiError(
        title: 'مشكلة في الخادم',
        message:
            'تعذر إتمام العملية حاليًا بسبب مشكلة في الخادم. يرجى المحاولة لاحقًا.',
      );
    }

    // Backend may already contain a clear Arabic business message.
    // We take only the clean Arabic part, never the raw JSON/exception.
    final arabicMessage =
        _extractArabicMessage(error.firstFieldError?.value) ??
            _extractArabicMessage(error.backendMessage);

    if (arabicMessage != null) {
      return _UserApiError(
        title: _operationTitle(error.operation),
        message: arabicMessage,
      );
    }

    return _UserApiError(
      title: _operationTitle(error.operation),
      message:
          'تعذر إتمام العملية. يرجى المحاولة مرة أخرى.',
    );
  }

  static String? _validationMessage(ApiException error) {
    final fieldError = error.firstFieldError;

    if (fieldError == null) {
      return null;
    }

    final field = fieldError.key;
    final rawMessage = fieldError.value;
    final message = rawMessage.toLowerCase();
    final label = _fieldLabel(field);

    if (error.operation == ApiOperation.forgotPassword &&
        field == 'email' &&
        (message.contains('selected') ||
            message.contains('exists') ||
            message.contains('not exist'))) {
      return 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني.';
    }

    if (message.contains('already been taken') ||
        message.contains('already exists')) {
      if (field == 'email') {
        return 'البريد الإلكتروني مستخدم مسبقًا.';
      }

      return '$label مستخدم مسبقًا.';
    }

    if (message.contains('required')) {
      return 'حقل $label مطلوب.';
    }

    if (message.contains('valid email') ||
        (field == 'email' && message.contains('email'))) {
      return 'يرجى إدخال بريد إلكتروني صالح.';
    }

    if (message.contains('valid url') ||
        message.contains('valid url.')) {
      return 'يرجى إدخال رابط صحيح في حقل $label.';
    }

    if (message.contains('confirmed') ||
        message.contains('confirmation')) {
      return 'تأكيد كلمة المرور غير مطابق.';
    }

    if (message.contains('digits:6') ||
        (field == 'code' && message.contains('6'))) {
      return 'رمز التحقق يجب أن يتكون من 6 أرقام.';
    }

    if (field == 'password' &&
        message.contains('at least')) {
      return 'كلمة المرور قصيرة جدًا. يرجى إدخال كلمة مرور لا تقل عن 6 أحرف.';
    }

    if (field == 'new_password' &&
        message.contains('at least')) {
      return 'كلمة المرور الجديدة يجب ألا تقل عن 6 أحرف.';
    }

    if (field == 'documentation_file') {
      if (message.contains('file of type') ||
          message.contains('mimes')) {
        return 'ملف التوثيق يجب أن يكون بصيغة PDF أو JPG أو PNG أو DOC أو DOCX.';
      }

      if (message.contains('greater than') ||
          message.contains('kilobytes')) {
        return 'حجم ملف التوثيق يجب ألا يتجاوز 2 ميغابايت.';
      }
    }

    if (message.contains('selected') &&
        message.contains('invalid')) {
      return 'القيمة المختارة في حقل $label غير صالحة.';
    }

    return 'يرجى التحقق من حقل $label وإدخال قيمة صحيحة.';
  }

  static String _fieldLabel(String field) {
    const labels = <String, String>{
      'name': 'الاسم',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'password_confirmation': 'تأكيد كلمة المرور',
      'new_password': 'كلمة المرور الجديدة',
      'new_password_confirmation': 'تأكيد كلمة المرور الجديدة',
      'role': 'نوع الحساب',
      'code': 'رمز التحقق',
      'industry': 'مجال الشركة',
      'website': 'الموقع الإلكتروني',
      'documentation_file': 'ملف التوثيق',
      'location': 'الموقع',
      'phone': 'رقم الهاتف',
      'title': 'العنوان',
      'description': 'الوصف',
      'deadline': 'الموعد النهائي',
      'message': 'الرسالة',
    };

    return labels[field] ??
        field.replaceAll('_', ' ');
  }

  static String? _extractArabicMessage(String? rawMessage) {
    if (rawMessage == null) return null;

    var message = rawMessage.trim();

    if (message.isEmpty) return null;

    final lower = message.toLowerCase();

    if (lower.contains('sqlstate') ||
        lower.contains('stack trace') ||
        lower.contains('<html') ||
        message.contains('{') ||
        message.contains('}')) {
      return null;
    }

    if (message.contains('|')) {
      final parts = message.split('|');

      for (final part in parts) {
        final cleanPart = part.trim();

        if (_containsArabic(cleanPart)) {
          return cleanPart;
        }
      }
    }

    if (_containsArabic(message)) {
      return message;
    }

    return null;
  }

  static bool _containsArabic(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }

  static bool _containsAny(
    String value,
    List<String> patterns,
  ) {
    for (final pattern in patterns) {
      if (value.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  static String _operationTitle(ApiOperation operation) {
    switch (operation) {
      case ApiOperation.login:
        return 'تعذر تسجيل الدخول';

      case ApiOperation.loginOtp:
        return 'تعذر التحقق من الرمز';

      case ApiOperation.registerStudent:
      case ApiOperation.registerCompany:
        return 'تعذر إنشاء الحساب';

      case ApiOperation.forgotPassword:
      case ApiOperation.resendOtp:
        return 'تعذر إرسال رمز التحقق';

      case ApiOperation.verifyResetOtp:
        return 'تعذر التحقق من الرمز';

      case ApiOperation.resetPassword:
        return 'تعذر تغيير كلمة المرور';

      case ApiOperation.profile:
        return 'تعذر تحديث الملف الشخصي';

      case ApiOperation.task:
        return 'تعذر تنفيذ العملية على المهمة';

      case ApiOperation.opportunity:
        return 'تعذر تنفيذ العملية على الفرصة';

      case ApiOperation.application:
        return 'تعذر تنفيذ طلب التقديم';

      case ApiOperation.interview:
        return 'تعذر تنفيذ العملية على المقابلة';

      case ApiOperation.complaint:
        return 'تعذر تنفيذ العملية على الشكوى';

      case ApiOperation.mentor:
        return 'تعذر تنفيذ عملية الإرشاد';

      case ApiOperation.cv:
        return 'تعذر تنفيذ العملية على السيرة الذاتية';

      case ApiOperation.assessment:
        return 'تعذر تنفيذ عملية الاختبار';

      case ApiOperation.conversation:
        return 'تعذر تنفيذ عملية المحادثة';

      case ApiOperation.notification:
        return 'تعذر تنفيذ عملية الإشعارات';

      case ApiOperation.marketAnalysis:
        return 'تعذر جلب تحليل سوق العمل';

      case ApiOperation.chatbot:
        return 'تعذر تنفيذ العملية';

      case ApiOperation.generic:
        return 'تعذر إتمام العملية';
    }
  }
}

class _UserApiError {
  final String title;
  final String message;
  final JisrSnackbarType type;

  const _UserApiError({
    required this.title,
    required this.message,
    this.type = JisrSnackbarType.error,
  });
}