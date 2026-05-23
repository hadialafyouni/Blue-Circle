import 'package:bluecircle/shared/widgets/custom_app_bar.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import '../../shared/widgets/custom_buttons.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(text: "Edit Profile"),
      body: Stack(
        children: [
          _buildBody(),
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: ListView(
        children: [
          Center(
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Obx(() {
                final img = controller.profileImage.value;
                final user = controller.user.value;
                
                return Stack(
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundColor: AppColors.grey200,
                      backgroundImage: img != null 
                        ? FileImage(img) as ImageProvider 
                        : (user?.profileImage != null ? NetworkImage(user!.profileImage!) : null),
                      child: (img == null && user?.profileImage == null)
                          ? Icon(Icons.person, size: 50.r, color: AppColors.grey400)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 16.w),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          SizedBox(height: 30.h),
          _buildLabel("Your Name"),
          CustomSecondTextField(
            controller: controller.nameController,
            hintText: "Enter your name",
            hasPreffix: true,
            preffixIcon: Icon(Icons.person, color: AppColors.grey500),
          ),
          _buildLabel("Email Address"),
          CustomSecondTextField(
            controller: controller.emailController,
            hintText: "Enter email",
            hasPreffix: true,
            
            preffixIcon: Icon(Icons.email_outlined, color: AppColors.grey500),
          ),
          _buildLabel("Phone Number"),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSecondTextField(
                  controller: controller.phoneController,
                  hintText: "3012345678",
                  hasPreffix: true,
                  keyboardType: TextInputType.phone,
                  onChanged: controller.onPhoneChanged,
                  preffixIcon: SizedBox(
                    width: 120.w,
                    child: CountryCodePicker(
                      onChanged: (countryCode) =>
                          controller.setCountryDialCode(countryCode.dialCode),
                      initialSelection: controller.countryPickerInitialSelection,
                      favorite: const ['PK', 'IN', 'AE', 'SA', 'GB', 'US', 'CA'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      hideMainText: true,
                      alignLeft: false,
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      textStyle: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                        fontFamily: 'Poppins',
                      ),
                      searchStyle: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                        fontFamily: 'Poppins',
                      ),
                      dialogTextStyle: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                        fontFamily: 'Poppins',
                      ),
                      boxDecoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: controller.canShowVerifiedBadge
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.grey100,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: controller.canShowVerifiedBadge
                                ? AppColors.success.withValues(alpha: 0.35)
                                : AppColors.grey300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              controller.canShowVerifiedBadge
                                  ? Icons.verified_user_outlined
                                  : Icons.info_outline,
                              size: 18.w,
                              color: controller.canShowVerifiedBadge
                                  ? AppColors.success
                                  : AppColors.grey500,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: CText(
                                text: controller.canShowVerifiedBadge
                                    ? "Phone Verified"
                                    : controller.hasPendingPhoneChange
                                        ? "Verify this phone with OTP before saving"
                                        : "Add a phone number and verify it for OTP login",
                                fontSize: 12.sp,
                                color: controller.canShowVerifiedBadge
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Obx(
                      () => SizedBox(
                        height: 46.h,
                        child: OutlinedButton(
                          onPressed: controller.isPhoneVerificationInProgress.value
                              ? null
                              : controller.verifyPhoneNumber,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: CText(
                            text: controller.isPhoneVerificationInProgress.value
                                ? "Sending..."
                                : "Verify",
                            fontSize: 13.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildLabel("Emergency Contact"),
          CustomSecondTextField(
            controller: controller.emergencyController,
            hintText: "Emergency contact name/phone",
            hasPreffix: true,
            preffixIcon: Icon(Icons.contact_phone_outlined, color: AppColors.grey500),
          ),
          _buildLabel("Password"),
          CustomSecondTextField(
            controller: controller.passwordController,
            hintText: "Enter new password",
            isPassword: true,
            hasPreffix: true,
            hasSuffix: true,
            preffixIcon: Icon(Icons.lock_outline, color: AppColors.grey500),
          ),
          _buildLabel("Confirm Password"),
          CustomSecondTextField(
            controller: controller.confirmPasswordController,
            hintText: "Confirm password",
            isPassword: true,
            hasPreffix: true,
            hasSuffix: true,
            preffixIcon: Icon(Icons.lock_outline, color: AppColors.grey500),
          ),
          SizedBox(height: 30.h),
          PrimaryButton(
            text: "Save",
            onTap: controller.saveProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 16.h),
      child: CText(
        text: text,
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
      ),
    );
  }
}
