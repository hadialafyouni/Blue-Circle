import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/places_repository.dart';
import '../../data/models/place_model.dart';
import '../../core/utils/error_handler.dart';

class AddPlaceController extends GetxController {
  final PlacesRepository _placesRepository = Get.find<PlacesRepository>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final RxBool isLoading = false.obs;
  final RxBool quietAvailable = false.obs;
  final RxInt noiseRating = 1.obs;

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> createPlace() async {
    if (nameController.text.isEmpty) {
      ErrorHandler.showErrorSnackBar("Name is required");
      return;
    }

    try {
      isLoading.value = true;
      final newPlace = PlaceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        description: descriptionController.text.trim(),
        quietAvailable: quietAvailable.value,
        staffFriendly: true,
        overallRating: 5.0,
        images: [],
        category: "General",
        location: const GeoPoint(0, 0),
        sensoryRatings: {
          'noise': noiseRating.value.toDouble(),
          'crowd': 1.0,
        },
      );

      await _placesRepository.createPlace(newPlace);
      Get.back();
      ErrorHandler.showSuccessSnackBar("Success", "Place created successfully!");
    } catch (e) {
      dev.log("Error creating place: $e", name: "ADD_PLACE");
      ErrorHandler.showErrorSnackBar(e);
    } finally {
      isLoading.value = false;
    }
  }
}
