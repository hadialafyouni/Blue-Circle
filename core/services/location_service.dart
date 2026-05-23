import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService extends GetxService {
  Future<Position?> getCurrentPosition() async {
    final isReady = await ensureLocationReady();
    if (!isReady) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: _locationSettings(distanceFilter: 0),
    );
  }

  Future<LocationPermission> requestBackgroundPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> ensureLocationReady({bool requestAlways = false}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    if (requestAlways && permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Stream<Position> getPositionStream({
    bool background = false,
    int distanceFilter = 5,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: _locationSettings(
        background: background,
        distanceFilter: distanceFilter,
      ),
    );
  }

  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  LocationSettings _locationSettings({
    bool background = false,
    int distanceFilter = 5,
  }) {
    if (kIsWeb) {
      return WebSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        maximumAge: const Duration(minutes: 1),
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: background
            ? const ForegroundNotificationConfig(
                notificationTitle: 'BlueCircle location tracking',
                notificationText:
                    'Sharing live child location for safety alerts.',
                notificationChannelName: 'Live Location Tracking',
                enableWakeLock: true,
                setOngoing: true,
              )
            : null,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        activityType: ActivityType.otherNavigation,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: background,
      );
    }

    return LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter,
    );
  }
}
