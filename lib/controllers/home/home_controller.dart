import 'package:get/get.dart';
import 'package:jisr_platform/models/home/home_model.dart';

class HomeController extends GetxController {
  final isLoading = false.obs;

  final homeData = HomeModel(
    title: 'أهلاً بك في جسور',
    subtitle: 'ابدأ ببناء ملفك المهني واستعد لفرصك القادمة',
  );
}
