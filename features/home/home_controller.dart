import 'dart:developer' as dev;
import 'package:get/get.dart';
import '../../data/repositories/community_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/places_repository.dart';
import '../../data/models/post_model.dart';
import '../../data/models/place_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class HomeController extends GetxController {
  final CommunityRepository _communityRepository = Get.find<CommunityRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final PlacesRepository _placesRepository = Get.find<PlacesRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final RxList<PostModel> recentPosts = <PostModel>[].obs;
  final RxList<PlaceModel> nearbyPlaces = <PlaceModel>[].obs;
  final Rxn<UserModel> user = Rxn<UserModel>();

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    dev.log('HomeController Initialized', name: 'HOME_DEBUG');
    
    recentPosts.bindStream(_communityRepository.getPosts().map((posts) => posts.take(3).toList()));
    nearbyPlaces.bindStream(_placesRepository.getPlaces().map((places) => places.take(3).toList()));

    final userId = _authRepository.currentUser?.uid;
    if (userId != null) {
      user.bindStream(_userRepository.userStream(userId));
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> refreshPosts() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
