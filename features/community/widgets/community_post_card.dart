import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/group_post_model.dart';
import '../../../shared/widgets/c_text.dart';
import '../community_controller.dart';

class CommunityPostCard extends GetView<CommunityController> {
  const CommunityPostCard({required this.post, super.key});

  final GroupPostModel post;

  @override
  Widget build(BuildContext context) {
    final displayName = post.hideName ? 'Anonymous Post' : post.userName;
    final showUserImage =
        !post.hideName && (post.userImage?.isNotEmpty ?? false);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.grey200,
                backgroundImage: showUserImage
                    ? NetworkImage(post.userImage!)
                    : null,
                child: showUserImage ? null : const Icon(Icons.person_outline),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CText(
                      text: displayName,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    CText(
                      text: DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(post.createdAt),
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          CText(
            text: post.content,
            fontSize: 14,
            color: AppColors.textPrimary,
            lineHeight: 1.6,
            ellipsisText: false,
          ),
          if (post.imageUrl?.isNotEmpty ?? false) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Image.network(
                post.imageUrl!,
                width: double.infinity,
                height: 190.h,
                fit: BoxFit.cover,
              ),
            ),
          ],
          SizedBox(height: 14.h),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => controller.toggleGroupPostLike(post.id),
                icon: Icon(Icons.favorite_border, size: 18.sp),
                label: Text('${post.likeCount} likes'),
              ),
              SizedBox(width: 8.w),
              TextButton.icon(
                onPressed: () => controller.openCommentsSheet(post.id),
                icon: Icon(Icons.chat_bubble_outline, size: 18.sp),
                label: Text('${post.commentCount} comments'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
