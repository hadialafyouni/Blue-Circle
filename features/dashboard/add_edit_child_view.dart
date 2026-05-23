import 'package:bluecircle/shared/widgets/c_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/custom_buttons.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'children_management_controller.dart';

class AddEditChildView extends StatelessWidget {
   AddEditChildView({super.key});
  final ChildrenManagementController controller = Get.find<ChildrenManagementController>();


  // bool get isEditMode => Get.arguments != null && Get.arguments is ChildModel;
  // ChildModel? get editChild => isEditMode ? Get.arguments as ChildModel : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        text: controller.isEditMode ? "Edit Child" : "Add Child",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            // Profile Image Section
            _buildImageSection(),
            SizedBox(height: 24.h),

            // Basic Info Section
            _buildSectionCard(
              title: "Basic Information",
              children: [
                _buildFieldLabel("Child's Full Name"),
                CustomTextField(
                  controller: controller.nameController,
                  hintText: "Enter child's full name",
                  hasPreffix: true,
                  preffixIcon: Icon(Icons.person, color: AppColors.grey500, size: 20.w),
                ),
                SizedBox(height: 16.h),
                _buildFieldLabel("Date of Birth"),
                GestureDetector(
                  onTap: () => controller.pickDateOfBirth(context),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: controller.ageController,
                      hintText: "Select Date of Birth (Calculates Age)",
                      keyboardType: TextInputType.none,
                      hasPreffix: true,
                      preffixIcon: Icon(Icons.cake, color: AppColors.grey500, size: 20.w),
                    ),
                  ),
                ),
                if (!controller.isEditMode) ...[
                  SizedBox(height: 16.h),
                  _buildFieldLabel("Child Login Email"),
                  CustomTextField(
                    controller: controller.emailController,
                    hintText: "Enter email for child login",
                    keyboardType: TextInputType.emailAddress,
                    hasPreffix: true,
                    preffixIcon: Icon(Icons.email, color: AppColors.grey500, size: 20.w),
                  ),
                  SizedBox(height: 16.h),
                  _buildFieldLabel("Password"),
                  CustomTextField(
                    controller: controller.passwordController,
                    hintText: "Enter password for child login",
                    isPassword: true,
                    hasPreffix: true,
                    preffixIcon: Icon(Icons.lock, color: AppColors.grey500, size: 20.w),
                  ),
                ],
                SizedBox(height: 16.h),
                _buildFieldLabel("Additional Notes"),
                CustomTextField(
                  controller: controller.notesController,
                  hintText: "Any additional notes",
                  hasPreffix: true,
                  preffixIcon: Icon(Icons.note, color: AppColors.grey500, size: 20.w),
                  maxLines: 3,
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Sensory Preferences Section
            _buildSectionCard(
              title: "Sensory Preferences",
              children: [
                _buildSensorySlider("Noise Sensitivity", "noise"),
                SizedBox(height: 16.h),
                _buildSensorySlider("Crowd Sensitivity", "crowd"),
                SizedBox(height: 16.h),
                _buildSensorySlider("Light Sensitivity", "light"),
                SizedBox(height: 16.h),
                _buildSensorySlider("Touch Sensitivity", "touch"),
              ],
            ),

            SizedBox(height: 32.h),

            // Submit Button 
Obx(() => PrimaryButton(
      text: controller.isEditMode
          ? "Update Child"
          : "Create Child Account",
      width: double.infinity,
      isLoading: controller.isLoading.value,
      onTap: controller.submitChild,
))

            ,
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

Widget _buildImageSection() {
  return Center(
    child: Column(
      children: [
        Obx(() {
          final child = controller.editingChild.value;
          final hasImage = controller.selectedImage.value != null || (child?.profileImageUrl != null);

          return Stack(
            children: [
              CircleAvatar(
                radius: 60.r,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: controller.selectedImage.value != null
                    ? FileImage(controller.selectedImage.value!)
                    : (child?.profileImageUrl != null
                        ? NetworkImage(child!.profileImageUrl!)
                        : null) as ImageProvider<Object>?,
                child: !hasImage
                    ? Icon(Icons.person, size: 60.r, color: AppColors.primary)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20.w,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        SizedBox(height: 8.h),
        Text(
          "Profile Photo",
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CText(
              text: title,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            SizedBox(height: 12.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: CText(
        text: label,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSensorySlider(String label, String key) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CText(
              text: label,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            Obx(() {
              final val = (controller.sensoryPreferences[key] ?? 5).toDouble();
              return CText(
                text: val < 4
                    ? "Low"
                    : val < 7
                    ? "Medium"
                    : "High",
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              );
            }),
          ],
        ),
        Obx(() => SliderTheme(
          data: SliderTheme.of(Get.context!).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.grey200,
            thumbColor: Colors.white,
            trackHeight: 6.h,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 10.r,
              elevation: 2,
            ),
            overlayColor: AppColors.primary.withOpacity(0.1),
          ),
          child: Slider(
            value: (controller.sensoryPreferences[key] ?? 5).toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (val) {
              controller.updateSensoryPreference(key, val.round());
            },
          ),
        )),
      ],
    );
  }
}

