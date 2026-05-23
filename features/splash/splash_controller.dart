import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../data/repositories/auth_repository.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 3), () {
      _checkAuthState();
    });
  }

  void _checkAuthState() {
    if (_authRepository.currentUser != null) {
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      Get.offAllNamed(Routes.ONBOARDING);
    }
  }
}
