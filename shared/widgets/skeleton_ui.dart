import 'package:bluecircle/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkeletonUI extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonUI({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }

  static Widget placeCardSkeleton() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonUI(width: double.infinity, height: 180),
          SizedBox(height: 12.h),
          const SkeletonUI(width: 200, height: 20),
          SizedBox(height: 8.h),
          const SkeletonUI(width: 150, height: 15),
          SizedBox(height: 12.h),
          Row(
            children: [
              const SkeletonUI(width: 80, height: 30),
              SizedBox(width: 8.w),
              const SkeletonUI(width: 80, height: 30),
            ],
          ),
        ],
      ),
    );
  }

  static Widget communityPostSkeleton() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonUI(width: 40, height: 40, borderRadius: 20),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonUI(width: 120, height: 15),
                  SizedBox(height: 4.h),
                  const SkeletonUI(width: 80, height: 12),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const SkeletonUI(width: double.infinity, height: 60),
          SizedBox(height: 12.h),
          const SkeletonUI(width: double.infinity, height: 200),
        ],
      ),
    );
  }
}
