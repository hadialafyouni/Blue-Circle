import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/c_text.dart';
import '../community_controller.dart';

class CommunityPostComposerCard extends GetView<CommunityController> {
  const CommunityPostComposerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canPost = controller.canCreatePostInActiveGroup;
      final message = controller.activeMembership.value?.isPending == true
          ? 'Posting is unlocked after the owner approves your request.'
          : 'Join this group first. After approval, you can create posts here.';

      if (!canPost) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: AppColors.textSecondary,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CText(
                  text: message,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CText(
              text: 'Share with the group',
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 8.h),
            CText(
              text: 'Create a community post inside this group.',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.openCreatePostSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                icon: const Icon(Icons.groups_outlined),
                label: const Text('Create Post'),
              ),
            ),
          ],
        ),
      );
    });
  }
}
