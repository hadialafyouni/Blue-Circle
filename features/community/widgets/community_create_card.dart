import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/c_text.dart';
import '../community_controller.dart';

class CommunityCreateCard extends GetView<CommunityController> {
  const CommunityCreateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CText(
            text: 'Start a new community',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          SizedBox(height: 8.h),
          CText(
            text: 'Create a community first, then members can join and post.',
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.92),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.openCreateCommunitySheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.darkBlue,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Community'),
            ),
          ),
        ],
      ),
    );
  }
}
