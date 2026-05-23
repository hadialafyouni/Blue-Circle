import 'dart:developer' as dev;
import 'dart:ui';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../routes/app_pages.dart';
import '../../data/repositories/safe_zone_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/safe_zone_model.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/error_handler.dart';

class SafeZoneController extends GetxController {
  final SafeZoneRepository _safeZoneRepository = Get.find<SafeZoneRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final LocationService _locationService = Get.find<LocationService>();

  final RxDouble radius = 500.0.obs;
  final RxBool isLoading = false.obs;

  GoogleMapController? mapController;

  Rx<LatLng> center = const LatLng(31.5204, 74.3587).obs;

  RxSet<Circle> circles = <Circle>{}.obs;
  RxSet<Marker> markers = <Marker>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
    _startLocationTracking();
  }

  void _startLocationTracking() {
    _locationService.getPositionStream().listen(
      (Position position) {
        // If we have an active safe zone view being configured by calculateDistance ok MUhammad
        if (center.value.latitude != 0.0) {
          final dist = _locationService.calculateDistance(
            center.value.latitude, 
            center.value.longitude, 
            position.latitude, 
            position.longitude
          );

          if (dist > radius.value) {
            dev.log('OUTSIDE SAFE ZONE: $dist meters', name: 'SAFE_ZONE_DEBUG');
          }
        }
      },
      onError: (e) {
        dev.log('Location Stream Error: $e', name: 'SAFE_ZONE_DEBUG');
      },
      cancelOnError: false,
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    drawCircle();
    addMarker();
  }

  Future<void> getCurrentLocation() async {
    try {
      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        center.value = LatLng(position.latitude, position.longitude);
        mapController?.animateCamera(
          CameraUpdate.newLatLng(center.value),
        );
        drawCircle();
        addMarker();
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(e);
    }
  }

  void drawCircle() {
    circles.clear();
    circles.add(
      Circle(
        circleId: const CircleId("safe_zone"),
        center: center.value,
        radius: radius.value,
        fillColor: const Color(0x332196F3),
        strokeColor: const Color(0xFF2196F3),
        strokeWidth: 2,
      ),
    );
  }

  void addMarker() {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId("marker"),
        position: center.value,
        draggable: true,
        onDragEnd: (LatLng newPosition) {
          center.value = newPosition;
          drawCircle();
        },
      ),
    );
  }

  void updateRadius(double value) {
    radius.value = value;
    drawCircle();
  }

  Future<void> confirmSafeZone() async {
    final userId = _authRepository.currentUser?.uid;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final safeZone = SafeZoneModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: "Home Safe Zone", // Default name, could be dynamic
        latitude: center.value.latitude,
        longitude: center.value.longitude,
        radius: radius.value,
        createdAt: DateTime.now(),
      );

      await _safeZoneRepository.addSafeZone(userId, safeZone);
      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      ErrorHandler.showErrorSnackBar(e);
    } finally {
      isLoading.value = false;
    }
  }
}
