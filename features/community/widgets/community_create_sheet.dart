import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/c_text.dart';
import '../community_controller.dart';

class CommunityCreateSheet extends GetView<CommunityController> {
  const CommunityCreateSheet({super.key});

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
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              CText(
                text: 'Create Community',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller.createGroupNameController,
                decoration: _inputDecoration('Community name'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller.createGroupDescriptionController,
                maxLines: 4,
                decoration: _inputDecoration('Description'),
              ),
              SizedBox(height: 16.h),
              CText(
                text: 'Sensory preferences',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: controller.sensoryOptions.map((option) {
                  final selected = controller.selectedSensoryPreferences
                      .contains(option);
                  return FilterChip(
                    label: Text(option),
                    selected: selected,
                    onSelected: (_) =>
                        controller.toggleSensoryPreference(option),
                    selectedColor: AppColors.secondary,
                    checkmarkColor: AppColors.darkBlue,
                  );
                }).toList(),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isCreatingGroup.value
                      ? null
                      : controller.createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    controller.isCreatingGroup.value
                        ? 'Creating...'
                        : 'Create Community',
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: AppColors.grey100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}
