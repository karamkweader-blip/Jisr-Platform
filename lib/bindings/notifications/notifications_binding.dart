import 'package:get/get.dart';
import 'package:jisr_platform/controllers/notifications/notifications_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/notifications/notification_api_service.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(
        AuthService.new,
        fenix: true,
      );
    }

    if (!Get.isRegistered<NotificationApiService>()) {
      Get.lazyPut<NotificationApiService>(
        () => NotificationApiService(
          Get.find<AuthService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<NotificationsController>()) {
      Get.lazyPut<NotificationsController>(
        () => NotificationsController(
          Get.find<NotificationApiService>(),
        ),
        fenix: true,
      );
    }
  }
}