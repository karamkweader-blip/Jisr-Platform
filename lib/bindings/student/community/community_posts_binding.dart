import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/community/community_posts_controller.dart';
import 'package:jisr_platform/controllers/student/points/student_points_controller.dart';

class CommunityPostsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunityPostsController>(() => CommunityPostsController());
    Get.lazyPut<StudentPointsController>(() => StudentPointsController());
  }
}
