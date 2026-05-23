import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/group_member_model.dart';
import '../../../shared/widgets/c_text.dart';
import '../community_controller.dart';

class CommunityMemberCard extends GetView<CommunityController> {
  const CommunityMemberCard({required this.member, super.key});

  final GroupMemberModel member;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.secondary,
            backgroundImage: (member.userImage?.isNotEmpty ?? false)
                ? NetworkImage(member.userImage!)
                : null,
            child: (member.userImage?.isNotEmpty ?? false)
                ? null
                : const Icon(Icons.person_outline),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CText(
                  text: member.userName,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 4.h),
                CText(
                  text: member.isOwner ? 'Owner' : 'Member',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          if (!member.isOwner)
            TextButton(
              onPressed: () => controller.removeMember(member.userId),
              child: const Text('Remove'),
            ),
        ],
      ),
    );
  }
}
