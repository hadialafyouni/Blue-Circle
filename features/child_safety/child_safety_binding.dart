import 'package:get/get.dart';
import 'child_safety_controller.dart';

class ChildSafetyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChildSafetyController>(() => ChildSafetyController());
  }
}
