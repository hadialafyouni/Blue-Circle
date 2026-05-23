import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/widgets/c_text.dart';
import '../community_controller.dart';

class CommunityGroupCard extends GetView<CommunityController> {
  const CommunityGroupCard({
    required this.group,
    this.matchReason,
    this.isHighlighted = false,
    super.key,
  });

  final GroupModel group;
  final String? matchReason;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canJoin = controller.canSendJoinRequest(group);
      final canCancel = controller.canCancelJoinRequest(group);
      final isBusy = controller.isJoinRequestLoadingFor(group.id);

      return Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: isHighlighted
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.18))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.groups,
                    color: AppColors.darkBlue,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CText(
                        text: group.name,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 4.h),
                      CText(
                        text: 'Created by ${group.ownerName}',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            CText(
              text: group.description,
              fontSize: 13,
              color: AppColors.textPrimary,
              lineHeight: 1.5,
            ),
            if (matchReason != null && matchReason!.trim().isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16.sp,
                      color: AppColors.darkBlue,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CText(
                        text: matchReason!,
                        fontSize: 12,
                        color: AppColors.darkBlue,
                        lineHeight: 1.4,
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _chip(
                  Icons.people_alt_outlined,
                  '${group.totalMembers} members',
                ),
                _chip(Icons.feed_outlined, '${group.totalPosts} posts'),
                ...group.sensoryPreferences.take(3).map(_tagChip),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.openGroup(group.id),
                    child: const Text('View Group'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canCancel
                        ? () => controller.cancelJoinRequest(group)
                        : canJoin
                            ? () => controller.requestJoin(group)
                            : () => controller.openGroup(group.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      isBusy
                          ? 'Please wait...'
                          : canCancel
                              ? 'Cancel request'
                          : controller.ctaLabelForGroup(group),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          CText(text: text, fontSize: 11, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _tagChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: CText(text: text, fontSize: 11, color: AppColors.darkBlue),
    );
  }
}
