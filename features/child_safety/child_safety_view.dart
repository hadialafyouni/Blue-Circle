import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/safety_toggle_card.dart';
import 'child_safety_controller.dart';

class ChildSafetyView extends GetView<ChildSafetyController> {
  const ChildSafetyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  CustomAppBar(text: "Child Safety",bgColor: AppColors.primary,tColor: AppColors.kwhite,),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: AppColors.primary, size: 32.sp),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: CText(
                      text: "Safety measures help keep your child protected. Enable location tracking for best results.",
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      lineHeight: 1.5,
                      softWrap: true,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Obx(() => SafetyToggleCard(
              title: "Location Tracking",
              description: "Track your child's real-time location.",
              value: controller.isLocationTrackingEnabled.value,
              onChanged: controller.toggleLocationTracking,
            )),
            Obx(() => SafetyToggleCard(
              title: "Safe Zone Alerts",
              description: "Get notified when child leaves safe zone.",
              value: controller.isSafeZoneAlertsEnabled.value,
              onChanged: controller.toggleSafeZoneAlerts,
            )),
             Obx(() => SafetyToggleCard(
              title: "Emergency Contact",
              description: "Enable quick call to emergency contacts.",
              value: controller.isEmergencyContactEnabled.value,
              onChanged: controller.toggleEmergencyContact,
            )),

            SizedBox(height: 32.h),

             Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 2.w,
                )
              ),
              child: Icon(Icons.shield_outlined, size: 60.sp, color: AppColors.primary),
             ),
             SizedBox(height: 16.h),
             CText(
               text: "Enable Safety Mode to lock critical settings.",
               alignText: TextAlign.center,
               fontSize: 14,
               color: AppColors.textSecondary,
             )
          ],
        ),
      ),
    );
  }
}
