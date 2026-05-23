import 'package:get/get.dart';
import 'children_management_controller.dart';

class ChildrenManagementBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<ChildrenManagementController>(() => ChildrenManagementController());
    Get.put(ChildrenManagementController(), permanent: true);
  }
}

