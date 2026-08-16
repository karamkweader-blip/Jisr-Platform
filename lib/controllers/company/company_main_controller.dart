import 'package:get/get.dart';

class CompanyMainController extends GetxController {
  static const int searchPageIndex = 0;
  static const int opportunitiesPageIndex = 1;
  static const int homePageIndex = 2;
  static const int conversationsPageIndex = 3;
  static const int profilePageIndex = 4;
  static const int pagesCount = 5;

  final RxInt selectedIndex = homePageIndex.obs;

  void changeTab(int index) {
    if (!_isValidIndex(index)) {
      return;
    }

    if (selectedIndex.value == index) {
      return;
    }

    selectedIndex.value = index;
  }

  void openNextTab() {
    final nextIndex = selectedIndex.value + 1;

    if (_isValidIndex(nextIndex)) {
      changeTab(nextIndex);
    }
  }

  void openPreviousTab() {
    final previousIndex = selectedIndex.value - 1;

    if (_isValidIndex(previousIndex)) {
      changeTab(previousIndex);
    }
  }

  bool _isValidIndex(int index) {
    return index >= 0 && index < pagesCount;
  }
}