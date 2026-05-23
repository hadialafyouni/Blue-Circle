import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';

import '../../core/utils/error_handler.dart';

class ChildSafetyController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final RxBool isLocationTrackingEnabled = true.obs;
  final RxBool isSafeZoneAlertsEnabled = true.obs;
  final RxBool isEmergencyContactEnabled = false.obs;
  
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userId = _authRepository.currentUser?.uid;
    if (userId == null) return;

    try {
      final user = await _userRepository.getUser(userId);
      if (user!.childSafetySettings != null) {
        isLocationTrackingEnabled.value = user.childSafetySettings!['locationTracking'] ?? true;
        isSafeZoneAlertsEnabled.value = user.childSafetySettings!['safeZoneAlerts'] ?? true;
        isEmergencyContactEnabled.value = user.childSafetySettings!['emergencyContact'] ?? false;
      }
    } catch (e) {
    
    }
  }

  Future<void> _updateSettings() async {
    final userId = _authRepository.currentUser?.uid;
    if (userId == null) return;

    try {
      final user = await _userRepository.getUser(userId);
      final updatedUser = user!.copyWith(
        childSafetySettings: {
          'locationTracking': isLocationTrackingEnabled.value,
          'safeZoneAlerts': isSafeZoneAlertsEnabled.value,
          'emergencyContact': isEmergencyContactEnabled.value,
        },
      );
      await _userRepository.updateUser(updatedUser);
    } catch (e) {
      ErrorHandler.showErrorSnackBar(e);
    }
  }

  void toggleLocationTracking(bool value) {
    isLocationTrackingEnabled.value = value;
    _updateSettings();
  }

  void toggleSafeZoneAlerts(bool value) {
    isSafeZoneAlertsEnabled.value = value;
    _updateSettings();
  }

  void toggleEmergencyContact(bool value) {
    isEmergencyContactEnabled.value = value;
    _updateSettings();
  }
}
