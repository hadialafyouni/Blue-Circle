import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import '../../shared/widgets/custom_app_bar.dart';
import 'community_controller.dart';
import 'widgets/community_empty_card.dart';
import 'widgets/community_group_header_card.dart';
import 'widgets/community_post_card.dart';
import 'widgets/community_post_composer_card.dart';

class CommunityGroupView extends GetView<CommunityController> {
  const CommunityGroupView({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          final group = controller.activeGroup.value;
          return CustomAppBar(
            text: group?.name ?? 'Community',
            actions: group != null && controller.isOwner(group)
                ? [
                    IconButton(
                      onPressed: () => controller.openManagement(group),
                      icon: const Icon(Icons.settings, color: Colors.white),
                    ),
                  ]
                : null,
          );
        }),
      ),
      body: Obx(() {
        if (controller.isGroupLoading.value &&
            controller.activeGroup.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final group = controller.activeGroup.value;
        if (group == null) {
          return const Center(
            child: CommunityEmptyCard(
              title: 'Community not found',
              message: 'This community is unavailable right now.',
              icon: Icons.group_off_outlined,
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            const CommunityGroupHeaderCard(),
            SizedBox(height: 16.h),
            const CommunityPostComposerCard(),
            SizedBox(height: 18.h),
            CText(
              text: 'Group Posts',
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 12.h),
            if (controller.isGroupPostsLoading.value &&
                controller.activeGroupPosts.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (controller.activeGroupPosts.isEmpty)
              CommunityEmptyCard(
                title: 'No posts yet',
                message: controller.emptyPostsMessage(),
                icon: Icons.forum_outlined,
              )
            else
              ...controller.activeGroupPosts.map(
                (post) => CommunityPostCard(post: post),
              ),
          ],
        );
      }),
    );
  }
}
