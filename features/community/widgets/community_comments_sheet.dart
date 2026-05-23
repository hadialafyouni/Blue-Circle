import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/c_text.dart';
import '../community_controller.dart';
import 'community_empty_card.dart';

class CommunityCommentsSheet extends GetView<CommunityController> {
  const CommunityCommentsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.72,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CText(text: 'Comments', fontSize: 18, fontWeight: FontWeight.bold),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() {
                if (controller.isCommentsLoading.value &&
                    controller.activeComments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.activeComments.isEmpty) {
                  return const CommunityEmptyCard(
                    title: 'No comments yet',
                    message: 'Start the conversation.',
                    icon: Icons.chat_bubble_outline,
                  );
                }

                return ListView.separated(
                  itemCount: controller.activeComments.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final comment = controller.activeComments[index];
                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CText(
                                  text: comment.userName,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              CText(
                                text:
                                    '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          CText(
                            text: comment.content,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            ellipsisText: false,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment',
                      filled: true,
                      fillColor: AppColors.grey100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Obx(() {
                  return IconButton(
                    onPressed: controller.isSendingComment.value
                        ? null
                        : controller.addComment,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(
                      controller.isSendingComment.value
                          ? Icons.hourglass_top
                          : Icons.send,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
