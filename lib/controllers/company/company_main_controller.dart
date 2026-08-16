import 'package:get/get.dart';

class CompanyMainController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeTab(int index) {
    if (selectedIndex.value == index) return;
    selectedIndex.value = index;
  }
}