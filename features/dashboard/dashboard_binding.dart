import 'package:get/get.dart';
import 'dashboard_controller.dart';
import '../home/home_controller.dart';
import '../find_places/find_places_controller.dart';
import '../community/community_controller.dart';
import '../profile/profile_controller.dart';
import '../ai_chat/ai_chat_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<FindPlacesController>(() => FindPlacesController());
    Get.lazyPut<CommunityController>(() => CommunityController());
    Get.lazyPut<AiChatController>(() => AiChatController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
