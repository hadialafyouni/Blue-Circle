import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/group_member_model.dart';
import '../../../shared/widgets/c_text.dart';
import '../community_controller.dart';

class CommunityGroupHeaderCard extends GetView<CommunityController> {
  const CommunityGroupHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final group = controller.activeGroup.value;
      final membership = controller.activeMembership.value;

      if (group == null) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CText(
                        text: group.name,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 6.h),
                      CText(
                        text: group.description,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        lineHeight: 1.5,
                      ),
                    ],
                  ),
                ),
                if (controller.isOwner(group))
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: const Text('Admin'),
                  ),
              ],
            ),
            SizedBox(height: 14.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _chip(
                  Icons.people_alt_outlined,
                  '${group.totalMembers} members',
                ),
                _chip(Icons.hourglass_top, '${group.pendingRequests} pending'),
                _chip(Icons.feed_outlined, '${group.totalPosts} posts'),
                ...group.sensoryPreferences.map(_tagChip),
              ],
            ),
            if (!controller.isOwner(group)) ...[
              SizedBox(height: 16.h),
              _membershipBanner(group.id, membership),
            ],
          ],
        ),
      );
    });
  }

  Widget _membershipBanner(String groupId, GroupMemberModel? membership) {
    final group = controller.activeGroup.value;
    if (group == null) {
      return const SizedBox.shrink();
    }

    if (membership == null ||
        membership.status == GroupMembershipStatus.rejected.value ||
        membership.status == GroupMembershipStatus.removed.value) {
      final isBusy = controller.isJoinRequestLoadingFor(group.id);
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isBusy ? null : () => controller.requestJoin(group),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(isBusy ? 'Please wait...' : 'Join Group'),
        ),
      );
    }

    if (membership.isPending) {
      final isBusy = controller.isJoinRequestLoadingFor(group.id);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _noticeCard(
            'Your join request is pending approval from the group owner.',
            AppColors.secondary.withValues(alpha: 0.5),
            AppColors.darkBlue,
          ),
          SizedBox(height: 10.h),
          OutlinedButton(
            onPressed: isBusy ? null : () => controller.cancelJoinRequest(group),
            child: Text(isBusy ? 'Please wait...' : 'Cancel request'),
          ),
        ],
      );
    }

    return _noticeCard(
      'You are a member of this community and can create posts.',
      AppColors.success.withValues(alpha: 0.12),
      Colors.green.shade800,
    );
  }

  Widget _noticeCard(String text, Color bg, Color fg) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: CText(text: text, fontSize: 12, color: fg),
    );
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
          Text(text, style: TextStyle(fontSize: 11.sp)),
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
