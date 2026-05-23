import 'dart:async';
import 'dart:developer' as dev;

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../data/models/child_location_model.dart';
import '../../data/models/child_model.dart';
import '../../data/models/safe_zone_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/child_repository.dart';
import '../../data/repositories/safe_zone_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../routes/app_pages.dart';
import 'location_service.dart';
import 'notification/notification.dart';

class ChildLiveLocationService extends GetxService {
  final ChildRepository _childRepository = Get.find<ChildRepository>();
  final SafeZoneRepository _safeZoneRepository = Get.find<SafeZoneRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final LocationService _locationService = Get.find<LocationService>();

  final Rx<ChildLocationModel?> currentLocation = Rx<ChildLocationModel?>(null);
  final RxBool isTracking = false.obs;
  final RxString trackingError = ''.obs;

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<SafeZoneModel>>? _safeZonesSubscription;
  StreamSubscription<UserModel>? _parentSettingsSubscription;

  ChildModel? _trackingChild;
  String? _trackingChildId;
  List<SafeZoneModel> _safeZones = const [];
  bool _safeZoneAlertsEnabled = true;
  bool _locationTrackingEnabled = true;
  bool _isHandlingPosition = false;
  Position? _queuedPosition;

  Future<bool> startTracking(ChildModel child) async {
    if (_trackingChildId == child.childId && isTracking.value) {
      _trackingChild = child;
      return true;
    }

    await stopTracking(markOffline: false);

    _trackingChild = child;
    _trackingChildId = child.childId;
    trackingError.value = '';

    final ready = await _locationService.ensureLocationReady(
      requestAlways: true,
    );
    if (!ready) {
      trackingError.value =
          'Location permission is required for live child tracking.';
      await stopTracking(markOffline: false);
      return false;
    }

    await _primeSafetyContext(child.parentId);
    _listenToSafetyContext(child.parentId);

    final currentPosition = await _locationService.getCurrentPosition();
    if (currentPosition != null) {
      _onPosition(currentPosition);
    }

    _positionSubscription = _locationService
        .getPositionStream(background: true)
        .listen(_onPosition, onError: _onPositionError);

    isTracking.value = true;
    return true;
  }

  Future<void> stopTracking({bool markOffline = true}) async {
    final childId = _trackingChildId;

    await _positionSubscription?.cancel();
    await _safeZonesSubscription?.cancel();
    await _parentSettingsSubscription?.cancel();

    _positionSubscription = null;
    _safeZonesSubscription = null;
    _parentSettingsSubscription = null;
    _trackingChild = null;
    _trackingChildId = null;
    _safeZones = const [];
    _queuedPosition = null;
    _isHandlingPosition = false;
    isTracking.value = false;

    if (markOffline && childId != null) {
      try {
        await _childRepository.updateLiveLocationStatus(childId, 'offline');
      } catch (error, stackTrace) {
        dev.log(
          'Failed to mark child live location offline',
          name: 'ChildLiveLocationService',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> _primeSafetyContext(String parentId) async {
    try {
      _safeZones = await _safeZoneRepository
          .getSafeZones(parentId)
          .first
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      _safeZones = const [];
    }

    try {
      final user = await _userRepository
          .userStream(parentId)
          .first
          .timeout(const Duration(seconds: 3));
      final settings = user.childSafetySettings;
      _safeZoneAlertsEnabled = settings?['safeZoneAlerts'] != false;
      _locationTrackingEnabled = settings?['locationTracking'] != false;
    } catch (_) {
      _safeZoneAlertsEnabled = true;
      _locationTrackingEnabled = true;
    }
  }

  void _listenToSafetyContext(String parentId) {
    _safeZonesSubscription = _safeZoneRepository
        .getSafeZones(parentId)
        .listen(
          (zones) {
            _safeZones = zones;
          },
          onError: (error, stackTrace) {
            dev.log(
              'Safe zone stream failed',
              name: 'ChildLiveLocationService',
              error: error,
              stackTrace: stackTrace,
            );
          },
        );

    _parentSettingsSubscription = _userRepository
        .userStream(parentId)
        .listen(
          (user) {
            final settings = user.childSafetySettings;
            _safeZoneAlertsEnabled = settings?['safeZoneAlerts'] != false;
            final trackingEnabled = settings?['locationTracking'] != false;
            if (_locationTrackingEnabled && !trackingEnabled) {
              final childId = _trackingChildId;
              if (childId != null) {
                unawaited(
                  _childRepository.updateLiveLocationStatus(childId, 'paused'),
                );
              }
            }
            _locationTrackingEnabled = trackingEnabled;
          },
          onError: (error, stackTrace) {
            dev.log(
              'Parent safety settings stream failed',
              name: 'ChildLiveLocationService',
              error: error,
              stackTrace: stackTrace,
            );
          },
        );
  }

  void _onPosition(Position position) {
    if (_isHandlingPosition) {
      _queuedPosition = position;
      return;
    }

    unawaited(_processPosition(position));
  }

  Future<void> _processPosition(Position position) async {
    _isHandlingPosition = true;

    try {
      final child = _trackingChild;
      if (child == null || !_locationTrackingEnabled) {
        return;
      }

      final activeSafeZone = _findActiveSafeZone(position);
      currentLocation.value = ChildLocationModel.fromPosition(
        child: child,
        position: position,
        activeSafeZone: activeSafeZone,
      );

      final transition = await _childRepository.updateLiveLocation(
        child: child,
        position: position,
        activeSafeZone: activeSafeZone,
      );

      if (transition != null && _safeZoneAlertsEnabled) {
        await _sendSafeZoneNotification(transition);
      }
    } catch (error, stackTrace) {
      dev.log(
        'Failed to process live child location',
        name: 'ChildLiveLocationService',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isHandlingPosition = false;
      final nextPosition = _queuedPosition;
      _queuedPosition = null;
      if (nextPosition != null) {
        _onPosition(nextPosition);
      }
    }
  }

  SafeZoneModel? _findActiveSafeZone(Position position) {
    SafeZoneModel? nearestZone;
    double? nearestDistance;

    for (final zone in _safeZones) {
      final distance = _locationService.calculateDistance(
        position.latitude,
        position.longitude,
        zone.latitude,
        zone.longitude,
      );

      if (distance <= zone.radius &&
          (nearestDistance == null || distance < nearestDistance)) {
        nearestDistance = distance;
        nearestZone = zone;
      }
    }

    return nearestZone;
  }

  Future<void> _sendSafeZoneNotification(SafeZoneTransition transition) async {
    final departed = transition.type == SafeZoneTransitionType.departed;
    final zoneName = transition.zoneName?.trim().isNotEmpty == true
        ? transition.zoneName!.trim()
        : 'a saved safe zone';
    final title = departed ? 'Safe Zone Alert' : 'Safe Zone Update';
    final body = departed
        ? '${transition.childName} left $zoneName.'
        : '${transition.childName} arrived at $zoneName.';

    try {
      await FCMSenderService.sendToUser(
        userId: transition.parentId,
        type: departed
            ? NotificationType.childLeftSafeZone
            : NotificationType.childArrivedSafeZone,
        title: title,
        body: body,
        data: {
          'route': Routes.CHILD_DASHBOARD,
          'childId': transition.childId,
          'parentId': transition.parentId,
          'zoneId': transition.zoneId,
          'zoneName': transition.zoneName,
          'transition': transition.type.name,
          'latitude': transition.latitude,
          'longitude': transition.longitude,
        },
      );
    } catch (error, stackTrace) {
      dev.log(
        'Failed to send safe zone notification',
        name: 'ChildLiveLocationService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _onPositionError(Object error, StackTrace stackTrace) {
    trackingError.value = 'Live location updates stopped unexpectedly.';
    dev.log(
      'Position stream failed',
      name: 'ChildLiveLocationService',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
