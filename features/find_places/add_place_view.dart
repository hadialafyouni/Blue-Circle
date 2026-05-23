import 'package:bluecircle/shared/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'add_place_controller.dart';

class AddPlaceView extends GetView<AddPlaceController> {
  const AddPlaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(text: "Add New Place"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel("Place Name"),
            CustomTextField(
              hintText: "Enter place name (e.g. Central Park)",
              controller: controller.nameController,
              textcolor: AppColors.textPrimary,
              backcolor: const Color(0xFFF8F9FA),
            ),
            SizedBox(height: 20.h),
            _buildSectionLabel("Address"),
            CustomTextField(
              hintText: "Enter location or address",
              controller: controller.addressController,
              textcolor: AppColors.textPrimary,
              backcolor: const Color(0xFFF8F9FA),
            ),
            SizedBox(height: 20.h),
            _buildSectionLabel("Description"),
            CustomTextField(
              hintText: "Tell us about this place...",
              controller: controller.descriptionController,
              textcolor: AppColors.textPrimary,
              backcolor: const Color(0xFFF8F9FA),
            ),
            SizedBox(height: 24.h),
            _buildSettingsToggle(),
            SizedBox(height: 32.h),
            Obx(() => PrimaryButton(
      text: "Create Place",
      width: double.infinity,
      isLoading: controller.isLoading.value,
      onTap: controller.createPlace,
))
           
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: CText(
        text: label,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF333333),
      ),
    );
  }

  Widget _buildSettingsToggle() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Obx(() => _toggleRow(
                title: "Quiet Area Available",
                value: controller.quietAvailable.value,
                onChanged: (val) => controller.quietAvailable.value = val,
              )),
          const Divider(height: 24),
          Row(
            children: [
              const CText(text: "Noise Level", fontSize: 14, fontWeight: FontWeight.w600),
              const Spacer(),
              Obx(() => _noiseSelector()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggleRow({required String title, required bool value, required Function(bool) onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CText(text: title, fontSize: 14, fontWeight: FontWeight.w600),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _noiseSelector() {
    return Row(
      children: List.generate(5, (index) {
        final current = index + 1;
        final isSelected = controller.noiseRating.value == current;
        return GestureDetector(
          onTap: () => controller.noiseRating.value = current,
          child: Container(
            margin: EdgeInsets.only(left: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: CText(
              text: current.toString(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        );
      }),
    );
  }
}
