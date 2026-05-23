import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Find Blue Circle-Friendly Places",
      "subtitle": "Discover parks, sensory-friendly museums near you with detailed sensory ratings.",
      "image": "assets/images/onboarding1.svg" 
    },
    {
      "title": "Community Support",
      "subtitle": "Connect with other parents and caregivers who understand your journey.",
      "image": "assets/images/onboarding2.svg" 
    },
    {
      "title": "Child Safety & Tracking",
      "subtitle": "Optional location tracking and safe zones for peace of mind during outings.",
      "image": "assets/images/onboarding3.svg"
    },
    {
      "title": "Easy to Use",
      "subtitle": "Simple language, large text, and calm design for everyone in your family.",
      "image": "assets/images/onboarding4.svg" 
    },
  ];

  void onPageChanged(int index) {
    _currentIndex.value = index;
  }

  void next() {
    if (_currentIndex.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Get.offNamed(Routes.SIGN_IN); 
    }
  }

  void back() {
    if (_currentIndex.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
