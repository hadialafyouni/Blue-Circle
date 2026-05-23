import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';
import '../home/home_view.dart';
import '../find_places/find_places_view.dart';
import '../community/community_view.dart';
import '../ai_chat/ai_chat_view.dart';
import '../profile/profile_view.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.tabIndex.value,
        children: const [
          HomeView(),
          FindPlacesView(),
          CommunityView(),
          AiChatView(),
          ProfileView(),
        ],
      )),
      floatingActionButton: Obx(() {
        if (!controller.showFab) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: controller.onFabPressed,
          backgroundColor: AppColors.primary,
          heroTag: "dashboardFAB",
          icon: Icon(controller.fabIcon, color: Colors.white),
          label: Text(
            controller.fabLabel,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      }),
      bottomNavigationBar: Obx(() => Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey500,
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          elevation: 10,
          selectedLabelStyle: TextStyle(
             fontFamily: 'Poppins',
             fontSize: 12.sp,
             fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
             fontFamily: 'Poppins',
             fontSize: 12.sp,
             fontWeight: FontWeight.w500,
          ),
          items: [
            _buildNavItem(Icons.home_filled, "Home"),
            _buildNavItem(Icons.search, "Places"),
            _buildNavItem(Icons.people_alt, "Community"),
            _buildNavItem(Icons.smart_toy, "AI Chat"),
            _buildNavItem(Icons.person, "Profile"),
          ],
        ),
      )),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Container(
        margin: EdgeInsets.only(bottom: 4.h),
        child: Icon(icon, size: 24.sp),
      ),
      label: label,
    );
  }
}
