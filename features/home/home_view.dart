import 'package:bluecircle/features/dashboard/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import '../../routes/app_pages.dart';
import 'home_controller.dart';
import '../../data/models/post_model.dart';
import '../../data/models/place_model.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          title: "Find Places",
                          subtitle: "Search nearby",
                          icon: Icons.search,
                          iconBgColor: const Color(0xFFE8F0FF),
                          iconColor: const Color(0xFF2B7FFF),
                          onTap: () => Get.find<DashboardController>().changeTabIndex(1),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildActionCard(
                          title: "Community",
                          subtitle: "Connect",
                          icon: Icons.people_outline,
                          iconBgColor: const Color(0xFFEEFBF3),
                          iconColor: const Color(0xFF34C759),
                          onTap: () => Get.find<DashboardController>().changeTabIndex(2),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildLargeActionButton(
                    title: "Find Quiet Places",
                    icon: Icons.location_on_outlined,
                    onTap: () => Get.find<DashboardController>().changeTabIndex(1),
                  ),
                  SizedBox(height: 16.h),
                  _buildListTile(
                    title: "Open Community",
                    icon: Icons.people_alt_outlined,
                    onTap: () => Get.find<DashboardController>().changeTabIndex(2),
                  ),
                  SizedBox(height: 12.h),
                  _buildListTile(
                    title: "Child Safety",
                    icon: Icons.verified_user_outlined,
                    onTap: () => Get.toNamed(Routes.CHILD_SAFETY),
                  ),
                  SizedBox(height: 24.h),
                  const CText(
                    text: "Nearby Quiet Place",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B7FFF),
                  ),
                  SizedBox(height: 12.h),
                  _buildNearbyPlaces(),
                  SizedBox(height: 24.h),
                  const CText(
                    text: "Recent Community Posts",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF34C759),
                  ),
                  SizedBox(height: 12.h),
                  _buildRecentPosts(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 30.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => CText(
            text: "Welcome Back, ${controller.user.value?.name ?? "Parent"}",
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            SizedBox(height: 12.h),
            CText(text: title, fontSize: 16, fontWeight: FontWeight.bold),
            SizedBox(height: 4.h),
            CText(text: subtitle, fontSize: 13, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            CText(
              text: title,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFF1F1F1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF333333), size: 22.sp),
            SizedBox(width: 12.w),
            CText(text: title, fontSize: 15, fontWeight: FontWeight.w600),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyPlaces() {
    return Obx(() {
      if (controller.nearbyPlaces.isEmpty) {
        return const Center(child: CText(text: "No places found nearby", fontSize: 14));
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.nearbyPlaces.length,
        itemBuilder: (context, index) {
          final place = controller.nearbyPlaces[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildMiniPlaceCard(place),
          );
        },
      );
    });
  }

  Widget _buildMiniPlaceCard(PlaceModel place) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CText(text: place.name, fontSize: 16, fontWeight: FontWeight.bold),
                    const Icon(Icons.location_on_outlined, color: Color(0xFF2B7FFF), size: 18),
                  ],
                ),
                SizedBox(height: 4.h),
                CText(
                  text: "0.5 km awa", // Placeholder distance
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildTag("Noise: 2/5", const Color(0xFFE6FFF1), const Color(0xFF34C759)),
                    SizedBox(width: 8.w),
                    _buildTag("Crowds: 1/5", const Color(0xFFE8F0FF), const Color(0xFF2B7FFF)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPosts() {
    return Obx(() {
      if (controller.recentPosts.isEmpty) {
        return const Center(child: CText(text: "No recent posts", fontSize: 14));
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.recentPosts.length,
        itemBuilder: (context, index) {
          final post = controller.recentPosts[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildMiniPostCard(post),
          );
        },
      );
    });
  }

  Widget _buildMiniPostCard(PostModel post) {
    final isAnonymous = post.hideName == true;
    final displayName = isAnonymous ? 'Anonymous Parent' : (post.authorName ?? 'Parent');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person, size: 12.r, color: AppColors.primary),
              ),
              SizedBox(width: 8.w),
              CText(text: displayName, fontSize: 13, fontWeight: FontWeight.bold),
              const Spacer(),
              CText(
                text: post.createdAt.toString().substring(0, 10),
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          CText(text: post.title, fontSize: 15, fontWeight: FontWeight.w600),
          SizedBox(height: 4.h),
          CText(
            text: post.description,
            fontSize: 13,
            color: AppColors.textSecondary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: CText(
        text: text,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}
