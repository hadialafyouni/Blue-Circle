import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'child_model.dart';
import 'safe_zone_model.dart';

class ChildLocationModel {
  const ChildLocationModel({
    required this.childId,
    required this.parentId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.heading,
    this.speed,
    this.isMocked = false,
    this.updatedAt,
    this.safeZoneStatus,
    this.safeZoneId,
    this.safeZoneName,
  });

  final String childId;
  final String parentId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? heading;
  final double? speed;
  final bool isMocked;
  final DateTime? updatedAt;
  final String? safeZoneStatus;
  final String? safeZoneId;
  final String? safeZoneName;

  bool get isInsideSafeZone => safeZoneStatus == 'inside';

  static ChildLocationModel? fromChildMap(
    Map<String, dynamic> map,
    String childId,
  ) {
    final point = map['liveLocation'];
    if (point is! GeoPoint) {
      return null;
    }

    final safeZoneState = Map<String, dynamic>.from(
      map['safeZoneState'] as Map? ?? const {},
    );

    return ChildLocationModel(
      childId: childId,
      parentId: map['parentId']?.toString() ?? '',
      latitude: point.latitude,
      longitude: point.longitude,
      accuracy: (map['liveLocationAccuracy'] as num?)?.toDouble(),
      altitude: (map['liveLocationAltitude'] as num?)?.toDouble(),
      heading: (map['liveLocationHeading'] as num?)?.toDouble(),
      speed: (map['liveLocationSpeed'] as num?)?.toDouble(),
      isMocked: map['liveLocationIsMocked'] == true,
      updatedAt: _dateFrom(map['liveLocationUpdatedAt']),
      safeZoneStatus: safeZoneState['status']?.toString(),
      safeZoneId: safeZoneState['zoneId']?.toString(),
      safeZoneName: safeZoneState['zoneName']?.toString(),
    );
  }

  factory ChildLocationModel.fromPosition({
    required ChildModel child,
    required Position position,
    SafeZoneModel? activeSafeZone,
  }) {
    return ChildLocationModel(
      childId: child.childId,
      parentId: child.parentId,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      heading: position.heading,
      speed: position.speed,
      isMocked: position.isMocked,
      updatedAt: position.timestamp,
      safeZoneStatus: activeSafeZone == null ? 'outside' : 'inside',
      safeZoneId: activeSafeZone?.id,
      safeZoneName: activeSafeZone?.name,
    );
  }

  static DateTime? _dateFrom(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

enum SafeZoneTransitionType { arrived, departed }

class SafeZoneTransition {
  const SafeZoneTransition({
    required this.type,
    required this.childId,
    required this.parentId,
    required this.childName,
    required this.latitude,
    required this.longitude,
    this.zoneId,
    this.zoneName,
    this.previousZoneId,
    this.previousZoneName,
  });

  final SafeZoneTransitionType type;
  final String childId;
  final String parentId;
  final String childName;
  final double latitude;
  final double longitude;
  final String? zoneId;
  final String? zoneName;
  final String? previousZoneId;
  final String? previousZoneName;

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'childId': childId,
      'parentId': parentId,
      'childName': childName,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'previousZoneId': previousZoneId,
      'previousZoneName': previousZoneName,
      'location': GeoPoint(latitude, longitude),
    };
  }
}
