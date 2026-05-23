import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/utils/image_picker_helper.dart';
import '../../data/repositories/community_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/post_model.dart';
import '../../data/models/category_model.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/notification/notification.dart';
import '../../core/utils/error_handler.dart';

class PostCreationController extends GetxController {
  
  final CommunityRepository _communityRepository = Get.find<CommunityRepository>();
  final CategoryRepository _categoryRepository = Get.find<CategoryRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hideName = false.obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;


  @override
  void onInit() {
    super.onInit();
    dev.log('PostCreationController Initialized', name: 'POST_CREATION_DEBUG');
    
    categories.bindStream(_categoryRepository.getCategories());
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  
  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  
  Future<void> pickImage() async {
    await ImagePickerHelper.showImageSourceSheet(
      onImagePicked: (file) {
        selectedImage.value = file;
      },
      onImageRemoved: () {
        selectedImage.value = null;
      },
      showRemoveOption: selectedImage.value != null,
    );
  }

  
  void removeImage() {
    selectedImage.value = null;
  }

  void toggleHideName(bool? value) {
    hideName.value = value ?? false;
  }

  
  Future<void> createPost() async {
    if (isLoading.value) return;
    
    if (selectedCategory.value == null) {
      ErrorHandler.showErrorSnackBar('Please select a category');
      return;
    }

    final title = titleController.text.trim();
    if (title.isEmpty) {
      ErrorHandler.showErrorSnackBar('Please enter a title');
      return;
    }

    final description = descriptionController.text.trim();
    if (description.isEmpty) {
      ErrorHandler.showErrorSnackBar('Please enter a description');
      return;
    }

    final userId = _authRepository.currentUser?.uid;
    if (userId == null) {
      ErrorHandler.showErrorSnackBar('User not authenticated');
      return;
    }

    try {
      isLoading.value = true;
      dev.log('Creating post...', name: 'POST_CREATION_DEBUG');

      
      final user = await _userRepository.getUser(userId);

  
      String? imageUrl;
      String? imagePath;
      if (selectedImage.value != null) {
        dev.log('Uploading image...', name: 'POST_CREATION_DEBUG');

        final result = await _storageService.uploadImage(
          file: selectedImage.value!,
          folder: "posts/$userId",
          onProgress: (progress) {
            dev.log('Upload progress: ${(progress * 100).toStringAsFixed(2)}%', name: 'POST_CREATION_DEBUG');
          },
        );

        imageUrl = result["url"];
        imagePath = result["path"];
        dev.log('Image uploaded: $imageUrl', name: 'POST_CREATION_DEBUG');
      }

    
      final post = PostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdBy: userId,
        title: title,
        description: description,
        categoryId: selectedCategory.value!.id,
        authorName: user!.name,
        authorImage: hideName.value ? null : user.profileImage,
        hideName: hideName.value,
        imageUrl: imageUrl,
        imagePath: imagePath,
        createdAt: DateTime.now(),
        likesCount: 0,
        commentCount: 0,
      );


      await _communityRepository.createPost(post);
      await CommunityNotificationDispatcher.notifyPublicPostCreated(
        post: post,
        actorName: user.name,
      );
      await _categoryRepository.incrementPostCount(selectedCategory.value!.id);

      
      ErrorHandler.showSuccessSnackBar('Success', 'Post created successfully!');


    
      titleController.clear();
      descriptionController.clear();
      selectedCategory.value = null;
      selectedImage.value = null;
      hideName.value = false;

      // Get.back();
      dev.log('Can pop: ${Get.key.currentState?.canPop()}', name: 'NAV_DEBUG');

      if (Navigator.of(Get.context!).canPop()) {
  Navigator.of(Get.context!).pop();
}
      // Automatically refresh the community post list when a post is created
    } catch (e) {
      dev.log('Error creating post: $e', name: 'POST_CREATION_DEBUG');
      ErrorHandler.showErrorSnackBar(e);
    } finally {
      isLoading.value = false;
    }
  }
}
