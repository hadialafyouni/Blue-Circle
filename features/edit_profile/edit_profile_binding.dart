import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import 'edit_profile_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}
