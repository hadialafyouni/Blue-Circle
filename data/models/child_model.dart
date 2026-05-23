import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String childId;
  final String parentId;
  final String childName;
  final int age;
  final Map<String, int> sensoryPreferences;
  final List<String> savedPlaces;
  final String? notes;
  final DateTime createdAt;
  
  // Authentication credentials (stored for parent to manage, but used for child login)
  final String? childEmail;
  final String? childPassword;
  final String? profileImageUrl;
  final String? profileImagePath;

  ChildModel({
    required this.childId,
    required this.parentId,
    required this.childName,
    required this.age,
    required this.sensoryPreferences,
    this.savedPlaces = const [],
    this.notes,
    required this.createdAt,
    this.childEmail,
    this.childPassword,
    this.profileImageUrl,
    this.profileImagePath,
  });

  factory ChildModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ChildModel(
      childId: documentId,
      parentId: map['parentId'] ?? '',
      childName: map['childName'] ?? '',
      age: map['age'] ?? 0,
      sensoryPreferences: Map<String, int>.from(map['sensoryPreferences'] ?? {}),
      savedPlaces: List<String>.from(map['savedPlaces'] ?? []),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      childEmail: map['childEmail'],
      childPassword: map['childPassword'],
      profileImageUrl: map['profileImageUrl'],
      profileImagePath: map['profileImagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'childName': childName,
      'age': age,
      'sensoryPreferences': sensoryPreferences,
      'savedPlaces': savedPlaces,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'childEmail': childEmail,
      'childPassword': childPassword,
      'profileImageUrl': profileImageUrl,
      'profileImagePath': profileImagePath,
    };
  }

  ChildModel copyWith({
    String? childId,
    String? parentId,
    String? childName,
    int? age,
    Map<String, int>? sensoryPreferences,
    List<String>? savedPlaces,
    String? notes,
    DateTime? createdAt,
    String? childEmail,
    String? childPassword,
    String? profileImageUrl,
    String? profileImagePath,
  }) {
    return ChildModel(
      childId: childId ?? this.childId,
      parentId: parentId ?? this.parentId,
      childName: childName ?? this.childName,
      age: age ?? this.age,
      sensoryPreferences: sensoryPreferences ?? this.sensoryPreferences,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      childEmail: childEmail ?? this.childEmail,
      childPassword: childPassword ?? this.childPassword,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

