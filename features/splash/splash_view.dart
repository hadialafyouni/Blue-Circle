import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary,
                  width: 8.w,
                ),
              ),
              child: Icon(
                Icons.radio_button_unchecked, 
                size: 60.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            CText(
              text: AppStrings.appName,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
            SizedBox(height: 12.h),
             CText(
              text: "Supporting neurodiverse families",
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
             SizedBox(height: 40.h),
             const CircularProgressIndicator(
               valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
             )
          ],
        ),
      ),
    );
  }
}
