import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/c_text.dart';

class CommunityEmptyCard extends StatelessWidget {
  const CommunityEmptyCard({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 52.sp, color: AppColors.grey400),
          SizedBox(height: 12.h),
          CText(text: title, fontSize: 16, fontWeight: FontWeight.bold),
          SizedBox(height: 6.h),
          CText(
            text: message,
            fontSize: 13,
            color: AppColors.textSecondary,
            alignText: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
