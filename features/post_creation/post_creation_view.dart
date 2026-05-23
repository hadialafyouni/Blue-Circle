import 'package:bluecircle/shared/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import 'post_creation_controller.dart';

class PostCreationView extends GetView<PostCreationController> {
  const PostCreationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(text: "Create Post"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            const CText(
              text: "Select Category *",
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 12.h),
            Obx(() => _buildCategoryGrid()),
            
            SizedBox(height: 24.h),
            
         
            const CText(
              text: "Title *",
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(
                hintText: "Enter post title",
                filled: true,
                fillColor: AppColors.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
              maxLength: 100,
            ),
            
            SizedBox(height: 16.h),
            
         
            const CText(
              text: "Description *",
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller.descriptionController,
              decoration: InputDecoration(
                hintText: "Share your thoughts...",
                filled: true,
                fillColor: AppColors.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
              maxLines: 6,
              maxLength: 500,
            ),
            
            SizedBox(height: 16.h),
            
        
            const CText(
              text: "Add Image (Optional)",
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 12.h),
            Obx(() => _buildImagePicker()),

            SizedBox(height: 16.h),

            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: CheckboxListTile(
                  value: controller.hideName.value,
                  onChanged: controller.toggleHideName,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  title: const CText(
                    text: "Hide my name",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  subtitle: const CText(
                    text: "Your post will appear as Anonymous.",
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 32.h),
         
Obx(() => PrimaryButton(
      text: "Create Post",
      width: double.infinity,
      isLoading: controller.isLoading.value,
      onTap: controller.createPost,
))

            // Obx(() => SizedBox(
            //   width: double.infinity,
            //   height: 50.h,
            //   child: ElevatedButton(
            //     onPressed: controller.isLoading.value ? null : controller.createPost,
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primary,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12.r),
            //       ),
            //     ),
            //     child: controller.isLoading.value
            //         ? const CircularProgressIndicator(color: Colors.white)
            //         : const CText(
            //             text: "Create Post",
            //             fontSize: 16,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.white,
            //           ),
            //   ),
            // )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    if (controller.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: controller.categories.map((category) {
        final isSelected = controller.selectedCategory.value?.id == category.id;
        return GestureDetector(
          onTap: () => controller.selectCategory(category),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.grey100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.icon,
                  style: TextStyle(fontSize: 20.sp),
                ),
                SizedBox(width: 8.w),
                CText(
                  text: category.name,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImagePicker() {
    if (controller.selectedImage.value != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              controller.selectedImage.value!,
              width: double.infinity,
              height: 200.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: controller.removeImage,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
        width: double.infinity,
        height: 150.h,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.grey300,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48.sp,
              color: AppColors.grey500,
            ),
            SizedBox(height: 8.h),
            CText(
              text: "Tap to add image",
              fontSize: 14,
              color: AppColors.grey500,
            ),
          ],
        ),
      ),
    );
  }
}
