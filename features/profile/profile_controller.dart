

import 'dart:developer' as dev;

import 'package:bluecircle/core/utils/error_handler.dart';
import 'package:bluecircle/data/models/user_model.dart';
import 'package:bluecircle/data/repositories/auth_repository.dart';
import 'package:bluecircle/data/repositories/user_repository.dart';
import 'package:bluecircle/data/repositories/child_repository.dart';
import 'package:bluecircle/data/models/child_model.dart';
import 'package:bluecircle/routes/app_pages.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final Rxn<ChildModel> firstChild = Rxn<ChildModel>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  void _loadUser() {
    final userId = _authRepository.currentUser?.uid;
    if (userId != null) {
      user.bindStream(_userRepository.userStream(userId));
      
      final childRepo = Get.find<ChildRepository>();
      firstChild.bindStream(childRepo.getChildren(userId).map((list) => list.isNotEmpty ? list.first : null));
      
      dev.log('User and Child streams bound for $userId', name: 'PROFILE_DEBUG');
    }
  }

  void onEditProfileTap() => Get.toNamed(Routes.EDIT_PROFILE);

  Future<void> onLogout() async {
    try {
      isLoading.value = true;
      await _authRepository.signOut();
      Get.offAllNamed(Routes.SIGN_IN);
      dev.log('User logged out', name: 'PROFILE_DEBUG');
    } catch (e) {
      dev.log('Logout failed: $e', name: 'PROFILE_DEBUG', error: e);
      ErrorHandler.showErrorSnackBar(e);
    } finally {
      isLoading.value = false;
    }
  }
}
