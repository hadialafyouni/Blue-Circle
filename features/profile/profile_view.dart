import 'package:bluecircle/routes/app_pages.dart';
import 'package:bluecircle/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';

import 'profile_controller.dart';
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(text: "Profile", leadingIcon: false),
      body: _buildBody(),
    );
  }


  Widget _buildBody() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: ListView(
        children: [
          _buildProfileCard(),
          SizedBox(height: 24.h),

          _sectionTitle("Account"),
          _optionCard(Icons.settings_outlined, "Settings"),
          _optionCard(Icons.notifications_none_outlined, "Notifications"),
          _optionCard(Icons.lock_outline, "Privacy & Security"),

          SizedBox(height: 20.h),

          _sectionTitle("Support"),
          _optionCard(Icons.help_outline, "Help Center"),
          _optionCard(Icons.favorite_border, "About Us"),

          SizedBox(height: 20.h),

          _childProfileCard(),

          SizedBox(height: 20.h),

          _signOutCard(),
        ],
      ),
    );
  }

  
  Widget _buildProfileCard() {
    return Obx(() {
      final userData = controller.user.value;
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColors.primary.withValues(alpha: .1),
                  backgroundImage: userData?.profileImageUrl != null
                      ? NetworkImage(userData!.profileImageUrl!)
                      : null,
                  child: userData?.profileImageUrl == null
                      ? Icon(Icons.person, color: AppColors.primary, size: 28.sp)
                      : null,
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CText(
                      text: userData?.name ?? "User",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    CText(
                      text: (userData?.role ?? "Parent").capitalizeFirst ?? "Guardian Account",
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                    if ((userData?.phone ?? '').isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: userData?.isPhoneVerified == true
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.grey100,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: CText(
                          text: userData?.isPhoneVerified == true
                              ? "Phone Verified"
                              : "Phone Not Verified",
                          fontSize: 11.sp,
                          color: userData?.isPhoneVerified == true
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: controller.onEditProfileTap,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: CText(text: "Edit Profile", fontSize: 16.sp),
              ),
            ),
          ],
        ),
      );
    });
  }

  
  Widget _optionCard(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          SizedBox(width: 12.w),
          Expanded(child: CText(text: title, fontSize: 16.sp,)),
          Icon(Icons.chevron_right, color: AppColors.grey400),
        ],
      ),
    );
  }

  Widget _childProfileCard() {
    return Obx(() {
      final child = controller.firstChild.value;
      if (child == null) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              const CText(text: "No Child Added", fontWeight: FontWeight.bold, fontSize: 14),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.CHILDREN_MANAGEMENT),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: CText(text: "Add Child Profile", fontSize: 14.sp, color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      }
      
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CText(text: "Child Profile", fontWeight: FontWeight.bold, fontSize: 16.sp),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: () => Get.toNamed(Routes.CHILD_DASHBOARD, arguments: child),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CText(
                    text: "${child.childName} - ${child.age} Years",
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                  const CText(
                    text: "Sensory preferences configured",
                    fontSize: 12,
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            GestureDetector(
              onTap: () => Get.toNamed(Routes.CHILDREN_MANAGEMENT),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: CText(text: "Manage Children", fontSize: 16.sp),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _signOutCard() {
    return GestureDetector(
      onTap: controller.onLogout,
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: _cardDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8.w),
            const CText(text: "Sign Out", color: Colors.red, fontSize: 16,),
          ],
        ),
      ),
    );
  }

  
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 10,
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: CText(
        text: text,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    );
  }
}
