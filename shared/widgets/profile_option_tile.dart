import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';
import 'c_text.dart';

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CText(
                text: title,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDestructive ? AppColors.error : AppColors.textPrimary,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grey400,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
