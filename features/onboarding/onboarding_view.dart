import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import '../../shared/widgets/custom_buttons.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                
                        Container(
                          height: 120.w,
                          width: 120.w,
                          decoration: const BoxDecoration(
                            color: AppColors.primary, 
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconForIndex(index), 
                            size: 48.sp,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 40.h),
         
                        CText(
                          text: controller.onboardingData[index]["title"]!,
                          alignText: TextAlign.center,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary, 
                        ),
                        
                        SizedBox(height: 16.h),
            
                        CText(
                          text: controller.onboardingData[index]["subtitle"]!,
                          alignText: TextAlign.center,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          maxLines: 2,
                          color: AppColors.textSecondary, 
                          lineHeight: 1.5,
                        ),

                        SizedBox(height: 32.h),

       
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              controller.onboardingData.length,
                              (indicatorIndex) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                height: 4.h,
                                width: 24.w, 
                                decoration: BoxDecoration(
                                  color: controller.currentIndex == indicatorIndex
                                      ? AppColors.primary
                                      : AppColors.primary.withValues(alpha: 0.2), 
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
     
            Obx(() {
              final isFirstPage = controller.currentIndex == 0;
              final isLastPage = controller.currentIndex == controller.onboardingData.length - 1;

              return Padding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 48.h),
                child: isFirstPage
                    ? SizedBox(
                      width: double.infinity,
                      child: PrimaryIconButton(
                          text: "Next",
                          iconEnable: true, 
                          color: AppColors.primary,
                          
                          onTap: controller.next, icon: Icons.arrow_forward,
                        ),
                    )
                    : Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52.h,
                              child: PrimaryButtonOutlined(
                                onTap: controller.back,
                                text: "Back",
                                color: Colors.white,
                                iconEnable: true,
                                tcolor: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: PrimaryIconButton(
                              text: isLastPage ? "Get Started" : "Next",
                              onTap: controller.next,
                              icon: Icons.arrow_forward,
                              iconEnable: true,
                            ),
                          ),
                        ],
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.location_on_outlined;
      case 1:
        return Icons.people_outline;
      case 2:
        return Icons.shield_outlined;
      case 3:
      default:
        return Icons.favorite_border;
    }
  }
}
