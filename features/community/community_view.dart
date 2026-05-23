import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import '../../shared/widgets/custom_app_bar.dart';
import 'community_controller.dart';
import 'widgets/community_create_card.dart';
import 'widgets/community_empty_card.dart';
import 'widgets/community_group_card.dart';

class CommunityView extends GetView<CommunityController> {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(text: 'Community', leadingIcon: false),
      body: Obx(() {
        if (controller.isGroupsLoading.value && controller.groups.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            const CommunityCreateCard(),
            SizedBox(height: 20.h),
            if (controller.shouldShowMatchingSection) ...[
              CText(
                text: 'Matching Communities',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 6.h),
              CText(
                text:
                    'Recommended from your child profile and saved sensory preferences.',
                fontSize: 13,
                color: AppColors.textSecondary,
                lineHeight: 1.4,
              ),
              SizedBox(height: 12.h),
              if (controller.isMatchingGroupsLoading.value &&
                  controller.matchingGroups.isEmpty)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                )
              else if (controller.matchingGroups.isEmpty)
                CommunityEmptyCard(
                  title: 'No matching communities yet',
                  message: controller.matchingGroupsEmptyMessage(),
                  icon: Icons.auto_awesome_outlined,
                )
              else
                ...controller.matchingGroups.map(
                  (group) => CommunityGroupCard(
                    group: group,
                    matchReason: controller.matchingReasonForGroup(group.id),
                    isHighlighted: true,
                  ),
                ),
              SizedBox(height: 20.h),
            ],
            CText(
              text: controller.shouldShowMatchingSection
                  ? 'All Communities'
                  : 'Created Communities',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 12.h),
            if (controller.groups.isEmpty)
              const CommunityEmptyCard(
                title: 'No communities yet',
                message: 'Use the button above to create the first group.',
                icon: Icons.groups_2_outlined,
              ),
            ...controller.groups.map(
              (group) => CommunityGroupCard(group: group),
            ),
          ],
        );
      }),
    );
  }
}
