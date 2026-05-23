import 'package:cloud_firestore/cloud_firestore.dart';

enum GroupMemberRole { owner, member }

extension GroupMemberRoleExtension on GroupMemberRole {
  String get value {
    switch (this) {
      case GroupMemberRole.owner:
        return 'owner';
      case GroupMemberRole.member:
        return 'member';
    }
  }
}

enum GroupMembershipStatus { pending, approved, removed, rejected }

extension GroupMembershipStatusExtension on GroupMembershipStatus {
  String get value {
    switch (this) {
      case GroupMembershipStatus.pending:
        return 'pending';
      case GroupMembershipStatus.approved:
        return 'approved';
      case GroupMembershipStatus.removed:
        return 'removed';
      case GroupMembershipStatus.rejected:
        return 'rejected';
    }
  }
}

class GroupMemberModel {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
  final String? userImage;
  final String role;
  final String status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final DateTime? joinedAt;
  final String? respondedBy;

  const GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.role,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.joinedAt,
    this.respondedBy,
  });

  bool get isPending => status == GroupMembershipStatus.pending.value;
  bool get isApproved => status == GroupMembershipStatus.approved.value;
  bool get isOwner => role == GroupMemberRole.owner.value;

  factory GroupMemberModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return GroupMemberModel(
      id: documentId,
      groupId: map['groupId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'],
      role: map['role'] ?? GroupMemberRole.member.value,
      status: map['status'] ?? GroupMembershipStatus.pending.value,
      requestedAt:
          (map['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (map['respondedAt'] as Timestamp?)?.toDate(),
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate(),
      respondedBy: map['respondedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'role': role,
      'status': status,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'respondedAt': respondedAt != null
          ? Timestamp.fromDate(respondedAt!)
          : null,
      'joinedAt': joinedAt != null ? Timestamp.fromDate(joinedAt!) : null,
      'respondedBy': respondedBy,
    };
  }
}
