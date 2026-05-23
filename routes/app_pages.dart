
import 'package:get/get.dart';
import '../features/splash/splash_view.dart';
import '../features/splash/splash_binding.dart';
import '../features/onboarding/onboarding_view.dart';
import '../features/onboarding/onboarding_binding.dart';
import '../features/onboarding/get_started_view.dart';
import '../features/auth/sign_in_view.dart';
import '../features/auth/sign_up_view.dart';
import '../features/auth/otp_verification_view.dart';
import '../features/auth/auth_binding.dart';
import '../features/dashboard/dashboard_view.dart';
import '../features/dashboard/dashboard_binding.dart';
import '../features/dashboard/child_dashboard_view.dart';
import '../features/dashboard/child_dashboard_binding.dart';
import '../features/dashboard/children_management_view.dart';
import '../features/dashboard/children_management_binding.dart';
import '../features/dashboard/add_edit_child_view.dart';
import '../features/safe_zone/safe_zone_view.dart';
import '../features/safe_zone/safe_zone_binding.dart';
import '../features/home/home_view.dart';
import '../features/home/home_binding.dart';
import '../features/find_places/find_places_view.dart';
import '../features/find_places/find_places_binding.dart';
import '../features/community/community_view.dart';
import '../features/community/community_binding.dart';
import '../features/child_safety/child_safety_view.dart';
import '../features/child_safety/child_safety_binding.dart';
import '../features/profile/profile_view.dart';
import '../features/profile/profile_binding.dart';
import '../features/edit_profile/edit_profile_view.dart';
import '../features/edit_profile/edit_profile_binding.dart';
import '../features/post_creation/post_creation_view.dart';
import '../features/post_creation/post_creation_binding.dart';
import '../features/find_places/add_place_view.dart';
import '../features/find_places/add_place_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.GET_STARTED,
      page: () => const GetStartedView(),
    ),
    GetPage(
      name: _Paths.SIGN_IN,
      page: () => const SignInView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => const SignUpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.OTP_VERIFICATION,
      page: () => const OtpVerificationView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SAFE_ZONE,
      page: () => const SafeZoneView(),
      binding: SafeZoneBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.FIND_PLACES,
      page: () => const FindPlacesView(),
      binding: FindPlacesBinding(),
    ),
    GetPage(
      name: _Paths.COMMUNITY,
      page: () => const CommunityView(),
      binding: CommunityBinding(),
    ),
    GetPage(
      name: _Paths.CHILD_SAFETY,
      page: () => const ChildSafetyView(),
      binding: ChildSafetyBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.CHILD_DASHBOARD,
      page: () => const ChildDashboardView(),
      binding: ChildDashboardBinding(),
    ),
    GetPage(
      name: _Paths.CHILDREN_MANAGEMENT,
      page: () => const ChildrenManagementView(),
      binding: ChildrenManagementBinding(),
    ),
    GetPage(
      name: _Paths.ADD_CHILD,
      page: () =>  AddEditChildView(),
      binding: ChildrenManagementBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_CHILD,
      page: () =>  AddEditChildView(),
      binding: ChildrenManagementBinding(),
    ),
    GetPage(
      name: _Paths.POST_CREATION,
      page: () => const PostCreationView(),
      binding: PostCreationBinding(),
    ),
    GetPage(
      name: _Paths.PLACE_CREATION,
      page: () => const AddPlaceView(),
      binding: AddPlaceBinding(),
    ),
  ];
}
