import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/market_analysis/market_analysis_controller.dart';

class MarketAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarketAnalysisController>(() => MarketAnalysisController());
  }
}
