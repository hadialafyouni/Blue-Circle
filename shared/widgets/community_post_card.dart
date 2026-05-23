import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';
import 'c_text.dart';

class CommunityPostCard extends StatelessWidget {
  final String userName;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;

  const CommunityPostCard({
    super.key,
    required this.userName,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments, required Future<void> Function() onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.grey200,
                child: Icon(Icons.person, color: AppColors.grey500),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CText(
                    text: userName,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  CText(
                    text: timeAgo,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.more_horiz, color: AppColors.textSecondary),
            ],
          ),
          SizedBox(height: 16.h),
          CText(
            text: content,
            fontSize: 14,
            color: AppColors.textPrimary,
            lineHeight: 1.5,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.favorite_border, size: 20.sp, color: AppColors.textSecondary),
              SizedBox(width: 6.w),
              CText(
                text: likes.toString(),
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 24.w),
              Icon(Icons.chat_bubble_outline, size: 20.sp, color: AppColors.textSecondary),
              SizedBox(width: 6.w),
              CText(
                text: comments.toString(),
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
