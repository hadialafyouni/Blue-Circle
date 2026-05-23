import 'dart:developer' as dev;
import 'dart:io';
import 'package:bluecircle/core/services/auth_service.dart';
import 'package:bluecircle/core/services/storage_service.dart';
import 'package:bluecircle/data/models/child_model.dart';
import 'package:bluecircle/data/repositories/child_repository.dart';
import 'package:bluecircle/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/utils/image_picker_helper.dart';
import '../../core/utils/error_handler.dart';

class ChildrenManagementController extends GetxController {
  final ChildRepository _childRepository = Get.find<ChildRepository>();
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = Get.find<StorageService>();

  final RxList<ChildModel> children = <ChildModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final Rx<DateTime?> selectedDob = Rx<DateTime?>(null);

  final Rx<File?> selectedImage = Rx<File?>(null);

  final RxMap<String, int> sensoryPreferences = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadChildren();
    _initSensoryPreferences();
  }

  @override
  void onClose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    notesController.dispose();
    super.onClose();
  }


    final Rx<ChildModel?> editingChild = Rx<ChildModel?>(null);

  bool get isEditMode => editingChild.value != null;

  void setChildForEdit(ChildModel child) {
    editingChild.value = child;
    nameController.text = child.childName;
    ageController.text = child.age.toString();
    notesController.text = child.notes ?? '';
    emailController.text = child.childEmail ?? '';
    passwordController.clear();
    sensoryPreferences.value = Map<String, int>.from(child.sensoryPreferences);
    selectedImage.value = null;
  }

  void clearEditMode() {
    editingChild.value = null;
    clearForm();
  }

  void navigateToChildDashboard(ChildModel child) {
    Get.toNamed(Routes.CHILD_DASHBOARD, arguments: child);
  }

  Future<void> pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDob.value ?? DateTime(now.year - 5),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null) {
      selectedDob.value = picked;
      final age = _calculateAge(picked);
      ageController.text = age.toString();
    }
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  void _initSensoryPreferences() {
    sensoryPreferences.value = {
      'noise': 5,
      'crowd': 5,
      'light': 5,
      'touch': 5,
    };
  }

  void submitChild() {
  if (isEditMode) {
    updateChild(editingChild.value!);
    ErrorHandler.showSuccessSnackBar(
  'Success',
  'Update Child successfully!',
);
    if (Navigator.of(Get.context!).canPop()) {
  Navigator.of(Get.context!).pop();
}
  } else {
    createChild();
    ErrorHandler.showSuccessSnackBar(
  'Success',
  'Child created successfully!',
);
    if (Navigator.of(Get.context!).canPop()) {
  Navigator.of(Get.context!).pop();
}
  }
}

 void loadChildren() {
  final parentId = _authService.currentUser?.uid;

  if (parentId == null) {
    dev.log("Parent ID is null", name: "CHILDREN_MGMT");
    return;
  }

  dev.log("Binding children stream for parent: $parentId", name: "CHILDREN_MGMT");

  isLoading.value = true;

  final stream = _childRepository.getChildren(parentId);

  children.bindStream(stream);

  stream.listen(
    (_) {
      isLoading.value = false;
    },
    onError: (e) {
      isLoading.value = false;
      ErrorHandler.showErrorSnackBar("Failed to load children");
    },
  );
}

  /// Show image picker sheet
  Future<void> pickImage() async {
    await ImagePickerHelper.showImageSourceSheet(
      onImagePicked: (file) {
        selectedImage.value = file;
      },
      onImageRemoved: () {
        selectedImage.value = null;
      },
      showRemoveOption: selectedImage.value != null || editingChild.value?.profileImageUrl != null,
    );
  }

  void clearImage() {
    selectedImage.value = null;
  }

  void clearForm() {
    nameController.clear();
    ageController.clear();
    emailController.clear();
    passwordController.clear();
    notesController.clear();
    selectedImage.value = null;
    _initSensoryPreferences();
  }

  Future<void> createChild() async {
    if (isLoading.value) return; // Prevent multiple submissions
    final name = nameController.text.trim();
    final ageText = ageController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final notes = notesController.text.trim();

    if (name.isEmpty) return ErrorHandler.showErrorSnackBar("Please enter child's name");
    if (ageText.isEmpty) return ErrorHandler.showErrorSnackBar("Please enter child's age");
    final age = int.tryParse(ageText);
    if (age == null || age < 0 || age > 18) return ErrorHandler.showErrorSnackBar("Please enter a valid age (0-18)");
    if (email.isEmpty) return ErrorHandler.showErrorSnackBar("Please enter child's email");
    if (password.isEmpty) return ErrorHandler.showErrorSnackBar("Please enter a password");
    if (password.length < 6) return ErrorHandler.showErrorSnackBar("Password must be at least 6 characters");

    // We'll use a secondary Firebase app to create the child user
    // This prevents the parent from being signed out
    FirebaseApp? secondaryApp;

    try {
      isLoading.value = true;
      final parentId = _authService.currentUser?.uid;
      if (parentId == null) return ErrorHandler.showErrorSnackBar("Please login as a parent");

      final emailExists = await _childRepository.childEmailExists(email);
      if (emailExists) return ErrorHandler.showErrorSnackBar("This email is already in use");

      dev.log("Creating secondary Firebase app for child auth", name: "CHILDREN_MGMT");
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      final FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      
      dev.log("Signing up child in secondary app: $email", name: "CHILDREN_MGMT");
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      final childAuthId = userCredential.user!.uid;

      String? imageUrl;
      String? imagePath;

      if (selectedImage.value != null) {
        isLoading.value = false; // Hide main loading
        isUploading.value = true;
        try {
          final result = await _storageService.uploadImage(
            file: selectedImage.value!,
            folder: 'child_profiles/$childAuthId',
          );
          imageUrl = result['url'];
          imagePath = result['path'];
        } finally {
          isUploading.value = false;
          isLoading.value = true; // Show main loading again
        }
      }

      final child = ChildModel(
        childId: childAuthId,
        parentId: parentId,
        childName: name,
        age: age,
        sensoryPreferences: Map<String, int>.from(sensoryPreferences),
        notes: notes.isEmpty ? null : notes,
        createdAt: DateTime.now(),
        childEmail: email,
        childPassword: password,
        profileImageUrl: imageUrl,
        profileImagePath: imagePath,
      );

      await _childRepository.createChild(parentId, child);

      ErrorHandler.showSuccessSnackBar("Success", "Child account created successfully!");
      clearForm();
      Get.back();
      
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "This email is already registered";
          break;
        case 'invalid-email':
          message = "Invalid email address";
          break;
        case 'weak-password':
          message = "Password is too weak";
          break;
        default:
          message = e.message ?? "Failed to create account";
      }
      ErrorHandler.showErrorSnackBar(message);
    } catch (e) {
      dev.log("Error creating child: $e", name: "CHILDREN_MGMT", error: e);
      ErrorHandler.showErrorSnackBar("Failed to create child account");
    } finally {
      isLoading.value = false;
      isUploading.value = false;
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }

  Future<void> updateChild(ChildModel child) async {
    if (isLoading.value) return; // Prevent multiple submissions
    final name = nameController.text.trim();
    final ageText = ageController.text.trim();
    final notes = notesController.text.trim();

    if (name.isEmpty) return ErrorHandler.showErrorSnackBar("Please enter child's name");
    final age = int.tryParse(ageText);
    if (age == null || age < 0 || age > 18) return ErrorHandler.showErrorSnackBar("Please enter a valid age (0-18)");

    try {
      isLoading.value = true;

      String? imageUrl = child.profileImageUrl;
      String? imagePath = child.profileImagePath;

      if (selectedImage.value != null) {
        isUploading.value = true;
        if (child.profileImagePath != null) {
          try {
            await _storageService.deleteFile(child.profileImagePath!);
          } catch (e) {
            dev.log("Error deleting old image: $e", name: "CHILDREN_MGMT");
          }
        }

        try {
          final result = await _storageService.uploadImage(
            file: selectedImage.value!,
            folder: 'child_profiles/${child.childId}',
          );
          imageUrl = result['url'];
          imagePath = result['path'];
        } finally {
          isUploading.value = false;
        }
      }

      final newPassword = passwordController.text.trim();
      if (newPassword.isNotEmpty && newPassword.length >= 6) {
        await _childRepository.updateChildPassword(child.childId, newPassword);
      }

      final updatedChild = child.copyWith(
        childName: name,
        age: age,
        sensoryPreferences: Map<String, int>.from(sensoryPreferences),
        notes: notes.isEmpty ? null : notes,
        profileImageUrl: imageUrl,
        profileImagePath: imagePath,
      );

      await _childRepository.updateChild(updatedChild);

      ErrorHandler.showSuccessSnackBar("Success", "Child profile updated!");
      clearForm();
      Get.back();
    } catch (e) {
      dev.log("Error updating child: $e", name: "CHILDREN_MGMT", error: e);
      ErrorHandler.showErrorSnackBar("Failed to update child profile");
    } finally {
      isLoading.value = false;
      isUploading.value = false;
    }
  }

  
  Future<void> deleteChild(ChildModel child) async {
    try {
      isLoading.value = true;

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text("Delete Child"),
          content: Text(
            "Are you sure you want to delete ${child.childName}'s account? This will also delete their Firebase account and cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      if (child.profileImagePath != null) {
        try {
          await _storageService.deleteFile(child.profileImagePath!);
        } catch (e) {
          dev.log("Error deleting image: $e", name: "CHILDREN_MGMT");
        }
      }

      await _childRepository.deleteChild(child.childId);

      ErrorHandler.showSuccessSnackBar("Success", "Child profile deleted!");
    } catch (e) {
      dev.log("Error deleting child: $e", name: "CHILDREN_MGMT", error: e);
      ErrorHandler.showErrorSnackBar("Failed to delete child profile");
    } finally {
      isLoading.value = false;
    }
  }


  void updateSensoryPreference(String key, int value) {
    sensoryPreferences[key] = value;
  }
}