import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../shared/widgets/c_text.dart';
import '../../shared/widgets/custom_app_bar.dart';
import 'community_controller.dart';
import 'widgets/community_empty_card.dart';
import 'widgets/community_member_card.dart';
import 'widgets/community_request_card.dart';

class CommunityManagementView extends GetView<CommunityController> {
  const CommunityManagementView({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'Manage Group'),
      body: Obx(() {
        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            CText(
              text: 'Pending Requests',
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 10.h),
            if (controller.isPendingMembersLoading.value &&
                controller.activePendingMembers.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (controller.activePendingMembers.isEmpty)
              CommunityEmptyCard(
                title: 'No requests',
                message: controller.emptyRequestsMessage(),
                icon: Icons.inbox_outlined,
              )
            else
              ...controller.activePendingMembers.map(
                (member) => CommunityRequestCard(member: member),
              ),
            SizedBox(height: 20.h),
            CText(
              text: 'Joined Members',
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 10.h),
            if (controller.isApprovedMembersLoading.value &&
                controller.activeApprovedMembers.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (controller.activeApprovedMembers.isEmpty)
              CommunityEmptyCard(
                title: 'No members',
                message: controller.emptyMembersMessage(),
                icon: Icons.people_outline,
              )
            else
              ...controller.activeApprovedMembers.map(
                (member) => CommunityMemberCard(member: member),
              ),
          ],
        );
      }),
    );
  }
}
