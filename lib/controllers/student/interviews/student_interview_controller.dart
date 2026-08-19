import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/interviews/student_interview_model.dart';
import 'package:jisr_platform/services/student/interviews/student_interview_service.dart';
import 'package:url_launcher/url_launcher.dart';

enum StudentInterviewFilter { all, upcoming, history }

class StudentInterviewController extends GetxController {
  final StudentInterviewService _service = StudentInterviewService();

  final RxBool isLoading = false.obs;
  final RxBool isOpeningLink = false.obs;
  final RxString loadError = ''.obs;
  final Rx<StudentInterviewFilter> selectedFilter =
      StudentInterviewFilter.all.obs;
  final RxList<StudentInterviewModel> interviews =
      <StudentInterviewModel>[].obs;

  @override
  void onReady() {
    super.onReady();
    fetchInterviews();
  }

  List<StudentInterviewModel> get filteredInterviews {
    final result = switch (selectedFilter.value) {
      StudentInterviewFilter.all => interviews.toList(),
      StudentInterviewFilter.upcoming =>
        interviews.where((item) => item.isUpcoming).toList(),
      StudentInterviewFilter.history =>
        interviews.where((item) => item.isHistory).toList(),
    };

    result.sort((first, second) {
      final firstDate = first.scheduledAt;
      final secondDate = second.scheduledAt;
      if (firstDate == null && secondDate == null) return 0;
      if (firstDate == null) return 1;
      if (secondDate == null) return -1;

      if (selectedFilter.value == StudentInterviewFilter.all &&
          first.isUpcoming != second.isUpcoming) {
        return first.isUpcoming ? -1 : 1;
      }

      final shouldShowNewestFirst =
          selectedFilter.value == StudentInterviewFilter.history ||
              (selectedFilter.value == StudentInterviewFilter.all &&
                  !first.isUpcoming &&
                  !second.isUpcoming);
      return shouldShowNewestFirst
          ? secondDate.compareTo(firstDate)
          : firstDate.compareTo(secondDate);
    });
    return result;
  }

  int get upcomingCount => interviews.where((item) => item.isUpcoming).length;

  int get historyCount => interviews.where((item) => item.isHistory).length;

  String get currentTitle {
    switch (selectedFilter.value) {
      case StudentInterviewFilter.all:
        return 'كل المقابلات';
      case StudentInterviewFilter.upcoming:
        return 'المقابلات القادمة';
      case StudentInterviewFilter.history:
        return 'سجل المقابلات';
    }
  }

  void selectFilter(StudentInterviewFilter filter) {
    selectedFilter.value = filter;
  }

  Future<void> fetchInterviews() async {
    try {
      isLoading.value = true;
      loadError.value = '';
      final response = await _service.getInterviews();
      interviews.assignAll(response.data);
    } catch (error) {
      loadError.value = error.toString().replaceFirst('Exception: ', '');
      if (interviews.isNotEmpty) {
        JisrSnackbar.show(
          title: 'تعذر تحديث المقابلات',
          message: loadError.value,
          type: JisrSnackbarType.error,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openMeetingLink(StudentInterviewModel interview) async {
    final value = interview.meetingLink?.trim() ?? '';
    final uri = Uri.tryParse(value);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      _showLinkError('رابط المقابلة غير صالح');
      return;
    }

    if (isOpeningLink.value) return;
    try {
      isOpeningLink.value = true;
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      ).timeout(
        const Duration(seconds: 6),
        onTimeout: () => false,
      );
      if (opened) return;

      final fallbackOpened = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (!fallbackOpened) {
        _showLinkError('تعذر فتح تطبيق الاجتماع على هذا الجهاز');
      }
    } catch (_) {
      _showLinkError('تعذر فتح رابط المقابلة');
    } finally {
      isOpeningLink.value = false;
    }
  }

  String companyName(StudentInterviewCompany company) {
    if (company.name.isNotEmpty) return company.name;
    if (company.industry.isNotEmpty) return company.industry;
    return 'شركة غير محددة';
  }

  String opportunityTypeLabel(String type) {
    switch (type) {
      case 'job':
        return 'وظيفة';
      case 'internship':
        return 'تدريب';
      case 'project':
        return 'مشروع';
      default:
        return type.isEmpty ? 'فرصة' : type;
    }
  }

  String meetingTypeLabel(String type) {
    switch (type) {
      case 'online':
        return 'أونلاين';
      case 'onsite':
        return 'حضوري';
      case 'phone':
        return 'اتصال هاتفي';
      default:
        return type.isEmpty ? 'غير محدد' : type;
    }
  }

  String statusLabel(StudentInterviewModel interview) {
    switch (interview.status) {
      case 'scheduled':
        return interview.hasPassed ? 'موعد سابق' : 'مجدولة';
      case 'rescheduled':
        return interview.hasPassed ? 'موعد سابق' : 'أعيدت جدولتها';
      case 'completed':
        return 'مكتملة';
      case 'cancelled':
        return 'ملغاة';
      default:
        return interview.displayStatus.isEmpty
            ? 'غير محددة'
            : interview.displayStatus;
    }
  }

  String scheduledDateText(DateTime? value) {
    if (value == null) return 'الموعد غير محدد';
    final local = value.toLocal();
    final dayName = _dayName(local.weekday);
    final period = local.hour >= 12 ? 'م' : 'ص';
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    return '$dayName، ${_two(local.day)}/${_two(local.month)}/${local.year} '
        '- ${_two(hour)}:${_two(local.minute)} $period';
  }

  String _dayName(int weekday) {
    const days = <String>[
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[weekday - 1];
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  void _showLinkError(String message) {
    JisrSnackbar.show(
      title: 'تعذر فتح الرابط',
      message: message,
      type: JisrSnackbarType.error,
    );
  }
}
