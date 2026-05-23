import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/group_member_model.dart';
import '../../../shared/widgets/c_text.dart';
import '../community_controller.dart';

class CommunityRequestCard extends GetView<CommunityController> {
  const CommunityRequestCard({required this.member, super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CText(
            text: member.userName,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 6.h),
          CText(
            text: 'Wants to join this community.',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.rejectRequest(member.userId),
                  child: const Text('Reject'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.approveRequest(member.userId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
