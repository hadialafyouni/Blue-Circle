import 'package:cloud_firestore/cloud_firestore.dart';

class AiChatMessageModel {
  final String id;
  final String content;
  final bool isUser;
  final DateTime createdAt;
  final bool isThinking;

  const AiChatMessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.createdAt,
    this.isThinking = false,
  });

  factory AiChatMessageModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AiChatMessageModel(
      id: documentId,
      content: map['content'] ?? '',
      isUser: map['isUser'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isThinking: map['isThinking'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'isUser': isUser,
      'createdAt': Timestamp.fromDate(createdAt),
      'isThinking': isThinking,
    };
  }

  AiChatMessageModel copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? createdAt,
    bool? isThinking,
  }) {
    return AiChatMessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}
