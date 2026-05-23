import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/c_text.dart';
import '../../core/constants/app_constants.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<void> showImageSourceSheet({
    required Function(File) onImagePicked,
    VoidCallback? onImageRemoved,
    bool showRemoveOption = false,
  }) async {
    await Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CText(
              text: "Select Image Source",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: const CText(text: "Choose from Gallery", fontSize: 16),
              onTap: () async {
                Get.back();
                await _pickImage(ImageSource.gallery, onImagePicked);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: const CText(text: "Take a Photo", fontSize: 16),
              onTap: () async {
                Get.back();
                await _pickImage(ImageSource.camera, onImagePicked);
              },
            ),
            if (showRemoveOption && onImageRemoved != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const CText(text: "Remove Photo", fontSize: 16, color: Colors.red),
                onTap: () {
                  Get.back();
                  onImageRemoved();
                },
              ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  static Future<void> _pickImage(ImageSource source, Function(File) onImagePicked) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        onImagePicked(File(image.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }
}
