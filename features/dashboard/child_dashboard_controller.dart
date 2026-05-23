import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/services/child_live_location_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/role_auth_service.dart';
import '../../core/utils/error_handler.dart';
import '../../data/models/child_location_model.dart';
import '../../data/models/child_model.dart';
import '../../data/models/safe_zone_model.dart';
import '../../data/repositories/child_repository.dart';
import '../../data/repositories/safe_zone_repository.dart';

class ChildDashboardController extends GetxController {
  final ChildRepository _childRepository = Get.find<ChildRepository>();
  final SafeZoneRepository _safeZoneRepository = Get.find<SafeZoneRepository>();
  final RoleAuthService _roleAuthService = Get.find<RoleAuthService>();
  final ChildLiveLocationService _liveLocationService =
      Get.find<ChildLiveLocationService>();
  final LocationService _locationService = Get.find<LocationService>();

  final Rx<ChildModel?> currentChild = Rx<ChildModel?>(null);
  final Rx<ChildLocationModel?> liveLocation = Rx<ChildLocationModel?>(null);
  final Rx<LatLng?> currentUserLocation = Rx<LatLng?>(null);
  final RxList<SafeZoneModel> safeZones = <SafeZoneModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isParentViewer = false.obs;
  final RxString trackingError = ''.obs;
  final Rx<MapType> mapType = MapType.normal.obs;

  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Circle> circles = <Circle>{}.obs;

  StreamSubscription<ChildLocationModel?>? _locationSubscription;
  StreamSubscription<List<SafeZoneModel>>? _safeZonesSubscription;
  bool _hasCenteredMap = false;

  @override
  void onInit() {
    super.onInit();

    final argument = Get.arguments;
    if (argument is ChildModel) {
      isParentViewer.value = true;
      currentChild.value = argument;
      _watchChild(argument);
      unawaited(_loadCurrentUserLocation());
      return;
    }

    _loadChildProfile();
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    _safeZonesSubscription?.cancel();
    super.onClose();
  }

  String get childName => currentChild.value?.childName ?? 'Child';

  LatLng get mapTarget {
    final location = liveLocation.value;
    if (location != null) {
      return LatLng(location.latitude, location.longitude);
    }

    final userLocation = currentUserLocation.value;
    if (userLocation != null) {
      return userLocation;
    }

    if (safeZones.isNotEmpty) {
      final firstZone = safeZones.first;
      return LatLng(firstZone.latitude, firstZone.longitude);
    }

    return const LatLng(0, 0);
  }

  bool get isShowingUserFallback =>
      liveLocation.value == null && currentUserLocation.value != null;

  String get locationTitle =>
      liveLocation.value == null ? 'Current Location' : 'Live Location';

  String get locationSubtitle {
    final location = liveLocation.value;
    if (location == null) {
      if (currentUserLocation.value != null) {
        return 'Child location unavailable, showing your location';
      }
      return isParentViewer.value
          ? 'Getting your current location'
          : 'Starting live tracking';
    }

    final updatedAt = location.updatedAt;
    if (updatedAt == null) {
      return 'Live location updating';
    }

    final elapsed = DateTime.now().difference(updatedAt);
    if (elapsed.inSeconds < 60) {
      return 'Updated ${elapsed.inSeconds}s ago';
    }
    if (elapsed.inMinutes < 60) {
      return 'Updated ${elapsed.inMinutes}m ago';
    }
    return 'Updated ${elapsed.inHours}h ago';
  }

  String get safeZoneStatusText {
    final location = liveLocation.value;
    if (location == null) {
      return isParentViewer.value
          ? 'Waiting for child phone to share live location'
          : 'Safe zone status unavailable';
    }

    if (location.isInsideSafeZone) {
      final zoneName = location.safeZoneName?.trim();
      return zoneName == null || zoneName.isEmpty
          ? 'Inside a safe zone'
          : 'Inside $zoneName';
    }

    return safeZones.isEmpty ? '' : 'Outside saved safe zones';
  }

  Future<void> _loadChildProfile() async {
    try {
      isLoading.value = true;
      final currentUser = _roleAuthService.firebaseUser;
      if (currentUser == null) {
        trackingError.value = 'Please sign in as a child to share location.';
        return;
      }

      final child = await _childRepository.getChild(currentUser.uid);
      currentChild.value = child;
      _watchChild(child);
      unawaited(_loadCurrentUserLocation());

      final started = await _liveLocationService.startTracking(child);
      if (!started) {
        trackingError.value = _liveLocationService.trackingError.value;
        ErrorHandler.showErrorSnackBar(
          trackingError.value.isEmpty
              ? 'Unable to start live location tracking.'
              : trackingError.value,
        );
      }
    } catch (error, stackTrace) {
      dev.log(
        'Error loading child location dashboard',
        name: 'CHILD_DASHBOARD',
        error: error,
        stackTrace: stackTrace,
      );
      trackingError.value = 'Unable to load child location.';
    } finally {
      isLoading.value = false;
    }
  }

  void _watchChild(ChildModel child) {
    _bindLiveLocation(child.childId);
    _bindSafeZones(child.parentId);
  }

  Future<void> _loadCurrentUserLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        if (liveLocation.value == null) {
          trackingError.value =
              'Enable location permission to show your current location.';
        }
        return;
      }

      currentUserLocation.value = LatLng(position.latitude, position.longitude);
      _refreshMapOverlays();

      if (mapController != null && liveLocation.value == null) {
        _hasCenteredMap = true;
        await mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentUserLocation.value!, 15),
        );
      }
    } catch (error, stackTrace) {
      dev.log(
        'Error loading current user fallback location',
        name: 'CHILD_DASHBOARD',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _bindLiveLocation(String childId) {
    _locationSubscription?.cancel();
    _locationSubscription = _childRepository
        .watchChildLiveLocation(childId)
        .listen(
          (location) {
            final hadLiveLocation = liveLocation.value != null;
            liveLocation.value = location;
            if (location != null) {
              trackingError.value = '';
            }
            _refreshMapOverlays(
              followChild:
                  !isParentViewer.value ||
                  (!hadLiveLocation && location != null),
            );
          },
          onError: (error, stackTrace) {
            trackingError.value = 'Unable to listen to live child location.';
            dev.log(
              'Child live location stream failed',
              name: 'CHILD_DASHBOARD',
              error: error,
              stackTrace: stackTrace,
            );
          },
        );
  }

  void _bindSafeZones(String parentId) {
    _safeZonesSubscription?.cancel();
    _safeZonesSubscription = _safeZoneRepository
        .getSafeZones(parentId)
        .listen(
          (zones) {
            safeZones.assignAll(zones);
            _refreshMapOverlays();
          },
          onError: (error, stackTrace) {
            dev.log(
              'Safe zone overlay stream failed',
              name: 'CHILD_DASHBOARD',
              error: error,
              stackTrace: stackTrace,
            );
          },
        );
  }

  void _refreshMapOverlays({bool followChild = false}) {
    final nextMarkers = <Marker>{};
    final nextCircles = <Circle>{};

    for (final zone in safeZones) {
      final center = LatLng(zone.latitude, zone.longitude);
      nextMarkers.add(
        Marker(
          markerId: MarkerId('safe_zone_${zone.id}'),
          position: center,
          infoWindow: InfoWindow(
            title: zone.name,
            snippet: '${zone.radius.toStringAsFixed(0)}m radius',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
      nextCircles.add(
        Circle(
          circleId: CircleId('safe_zone_${zone.id}'),
          center: center,
          radius: zone.radius,
          strokeWidth: 2,
          strokeColor: Colors.green,
          fillColor: Colors.green.withValues(alpha: 0.14),
        ),
      );
    }

    final location = liveLocation.value;
    if (location != null) {
      final childPosition = LatLng(location.latitude, location.longitude);
      nextMarkers.add(
        Marker(
          markerId: const MarkerId('child_live_location'),
          position: childPosition,
          infoWindow: InfoWindow(title: childName, snippet: safeZoneStatusText),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );

      if (mapController != null && (!_hasCenteredMap || followChild)) {
        _hasCenteredMap = true;
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(childPosition, 15),
        );
      }
    } else {
      final userLocation = currentUserLocation.value;
      if (userLocation != null) {
        nextMarkers.add(
          Marker(
            markerId: const MarkerId('current_user_location'),
            position: userLocation,
            infoWindow: const InfoWindow(
              title: 'Your Location',
              snippet: 'Shown until child live location is available',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );

        if (mapController != null && !_hasCenteredMap) {
          _hasCenteredMap = true;
          mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(userLocation, 15),
          );
        }
      }
    }

    markers
      ..clear()
      ..addAll(nextMarkers)
      ..refresh();
    circles
      ..clear()
      ..addAll(nextCircles)
      ..refresh();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _hasCenteredMap = true;
    controller.animateCamera(CameraUpdate.newLatLngZoom(mapTarget, 15));
  }

  Future<void> centerOnChild() async {
    if (mapController == null) {
      return;
    }

    await mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(mapTarget, 15),
    );
  }

  Future<void> zoomIn() async {
    await mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> zoomOut() async {
    await mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void cycleMapType() {
    const mapTypes = [
      MapType.normal,
      MapType.satellite,
      MapType.terrain,
      MapType.hybrid,
    ];
    final nextIndex = (mapTypes.indexOf(mapType.value) + 1) % mapTypes.length;
    mapType.value = mapTypes[nextIndex];
  }
}
