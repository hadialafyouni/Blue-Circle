import 'package:get/get.dart';
import 'safe_zone_controller.dart';

class SafeZoneBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SafeZoneController>(() => SafeZoneController());
  }
}
