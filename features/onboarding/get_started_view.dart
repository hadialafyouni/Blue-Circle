import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import '../../shared/widgets/custom_buttons.dart';
import '../../routes/app_pages.dart';

class GetStartedView extends StatelessWidget {
  const GetStartedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                height: 300.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.favorite,
                  size: 100.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 48.h),
              CText(
                text: AppStrings.getStartedTitle,
                alignText: TextAlign.center,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              SizedBox(height: 16.h),
              CText(
                text: AppStrings.getStartedSubtitle,
                alignText: TextAlign.center,
                fontSize: 16,
                color: AppColors.textSecondary,
                lineHeight: 1.5,
              ),
              const Spacer(),
              PrimaryButton(
                text: "Get Started",
                onTap: () {
                  Get.toNamed(Routes.SIGN_IN);
                },
              ),
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}
