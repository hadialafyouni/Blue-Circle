import 'package:get/get.dart';
import 'child_dashboard_controller.dart';

class ChildDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChildDashboardController>(() => ChildDashboardController());
  }
}

