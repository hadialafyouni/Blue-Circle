import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int postCount;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.postCount = 0,
    required this.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CategoryModel(
      id: documentId,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '📝',
      postCount: map['postCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'postCount': postCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
