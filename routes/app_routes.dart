
// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const GET_STARTED = _Paths.GET_STARTED;
  static const SIGN_IN = _Paths.SIGN_IN;
  static const SIGN_UP = _Paths.SIGN_UP;
  static const OTP_VERIFICATION = _Paths.OTP_VERIFICATION;
  static const SAFE_ZONE = _Paths.SAFE_ZONE;
  static const HOME = _Paths.HOME;
  static const FIND_PLACES = _Paths.FIND_PLACES;
  static const COMMUNITY = _Paths.COMMUNITY;
  static const CHILD_SAFETY = _Paths.CHILD_SAFETY;
  static const PROFILE = _Paths.PROFILE;
  static const EDIT_PROFILE = _Paths.EDIT_PROFILE;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const CHILD_DASHBOARD = _Paths.CHILD_DASHBOARD;
  static const CHILDREN_MANAGEMENT = _Paths.CHILDREN_MANAGEMENT;
  static const ADD_CHILD = _Paths.ADD_CHILD;
  static const EDIT_CHILD = _Paths.EDIT_CHILD;
  static const POST_CREATION = _Paths.POST_CREATION;
  static const PLACE_CREATION = _Paths.PLACE_CREATION;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const GET_STARTED = '/get-started';
  static const SIGN_IN = '/sign-in';
  static const SIGN_UP = '/sign-up';
  static const OTP_VERIFICATION = '/otp-verification';
  static const SAFE_ZONE = '/safe-zone';
  static const HOME = '/home';
  static const FIND_PLACES = '/find-places';
  static const COMMUNITY = '/community';
  static const CHILD_SAFETY = '/child-safety';
  static const PROFILE = '/profile';
  static const EDIT_PROFILE = '/edit-profile';
  static const DASHBOARD = '/dashboard';
  static const CHILD_DASHBOARD = '/child-dashboard';
  static const CHILDREN_MANAGEMENT = '/children-management';
  static const ADD_CHILD = '/add-child';
  static const EDIT_CHILD = '/edit-child';
  static const POST_CREATION = '/post-creation';
  static const PLACE_CREATION = '/place-creation';
}
