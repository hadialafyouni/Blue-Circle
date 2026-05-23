import 'package:get/get.dart';
import 'find_places_controller.dart';

class FindPlacesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FindPlacesController>(() => FindPlacesController());
  }
}
