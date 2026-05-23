import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/places_repository.dart';
import '../../data/models/place_model.dart';

class FindPlacesController extends GetxController {
  final PlacesRepository _placesRepository = Get.find<PlacesRepository>();

  final TextEditingController searchController = TextEditingController();
  final List<String> categories = ["All", "Parks", "Museums", "Cafes", "Schools"];
  final RxString selectedCategory = "All".obs;
  
  final RxList<PlaceModel> allPlaces = <PlaceModel>[].obs;
  final RxList<PlaceModel> filteredPlaces = <PlaceModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    dev.log('FindPlacesController Initialized', name: 'FIND_PLACES_DEBUG');
    _fetchPlaces();
    
   
    ever(selectedCategory, (category) {
      dev.log('Category filter changed: $category', name: 'FIND_PLACES_DEBUG');
      _fetchPlaces();
    });

    ever(allPlaces, (_) => _filterPlaces());

    searchController.addListener(() {
      _filterPlaces();
    });
  }

  @override
  void onClose() {
    dev.log('FindPlacesController Closed', name: 'FIND_PLACES_DEBUG');
    searchController.dispose();
    super.onClose();
  }

  void _fetchPlaces() {
    dev.log('Fetching places for category: ${selectedCategory.value}', name: 'FIND_PLACES_DEBUG');
    allPlaces.bindStream(_placesRepository.getPlaces(
      category: selectedCategory.value,
    ));
  }

  void _filterPlaces() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      filteredPlaces.value = allPlaces;
    } else {
      filteredPlaces.value = allPlaces.where((place) {
        return place.name.toLowerCase().contains(query) ||
               place.description.toLowerCase().contains(query) ||
               (place.address?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}
