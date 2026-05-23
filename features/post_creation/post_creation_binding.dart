import 'package:get/get.dart';
import 'post_creation_controller.dart';

class PostCreationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostCreationController>(() => PostCreationController());
  }
}
