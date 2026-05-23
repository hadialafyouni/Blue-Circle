import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/c_text.dart';
import '../community_controller.dart';

class CommunityCreatePostSheet extends GetView<CommunityController> {
  const CommunityCreatePostSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        20.h,
        20.w,
        MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CText(
              text: 'Create Post',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 14.h),
            TextField(
              controller: controller.createPostController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your post (optional if uploading an image)',
                filled: true,
                fillColor: AppColors.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.pickPostImage,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      controller.selectedPostImage.value == null
                          ? 'Upload Image'
                          : 'Change Image',
                    ),
                  ),
                ),
                if (controller.selectedPostImage.value != null) ...[
                  SizedBox(width: 10.w),
                  IconButton(
                    onPressed: controller.removePostImage,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.grey100,
                    ),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ],
            ),
            if (controller.selectedPostImage.value != null) ...[
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.file(
                  controller.selectedPostImage.value!,
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            SizedBox(height: 10.h),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.hidePostAuthorName.value,
              onChanged: controller.toggleHidePostAuthor,
              activeColor: AppColors.primary,
              title: const Text('Hide my name'),
              subtitle: const Text('Show this as Anonymous Post'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isCreatingPost.value
                    ? null
                    : controller.createGroupPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  controller.isCreatingPost.value
                      ? 'Posting...'
                      : 'Create Post',
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
