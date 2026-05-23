import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/error_handler.dart';
import '../../core/services/notification/notification.dart';
import '../../data/models/child_model.dart';
import '../../data/models/group_comment_model.dart';
import '../../data/models/group_member_model.dart';
import '../../data/models/group_model.dart';
import '../../data/models/group_post_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/child_repository.dart';
import '../../data/repositories/community_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../shared/utils/image_picker_helper.dart';
import 'services/community_group_ai_suggestion_service.dart';
import 'community_group_view.dart';
import 'community_management_view.dart';
import 'widgets/community_comments_sheet.dart';
import 'widgets/community_create_post_sheet.dart';
import 'widgets/community_create_sheet.dart';

class CommunityController extends GetxController {
  final CommunityRepository _communityRepository =
      Get.find<CommunityRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final ChildRepository _childRepository = Get.find<ChildRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final CommunityGroupAiSuggestionService _groupSuggestionService =
      Get.find<CommunityGroupAiSuggestionService>();

  final TextEditingController createGroupNameController =
      TextEditingController();
  final TextEditingController createGroupDescriptionController =
      TextEditingController();
  final TextEditingController createPostController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  final RxList<GroupModel> groups = <GroupModel>[].obs;
  final RxList<GroupModel> matchingGroups = <GroupModel>[].obs;
  final RxList<GroupMemberModel> userMemberships = <GroupMemberModel>[].obs;
  final RxList<ChildModel> children = <ChildModel>[].obs;
  final Rxn<UserModel> currentUserModel = Rxn<UserModel>();
  final RxMap<String, String> matchingGroupReasons = <String, String>{}.obs;
  final RxList<String> selectedSensoryPreferences = <String>[].obs;

  final Rxn<GroupModel> activeGroup = Rxn<GroupModel>();
  final Rxn<GroupMemberModel> activeMembership = Rxn<GroupMemberModel>();
  final RxList<GroupPostModel> activeGroupPosts = <GroupPostModel>[].obs;
  final RxList<GroupMemberModel> activeApprovedMembers =
      <GroupMemberModel>[].obs;
  final RxList<GroupMemberModel> activePendingMembers =
      <GroupMemberModel>[].obs;
  final RxList<GroupCommentModel> activeComments = <GroupCommentModel>[].obs;

  final RxnString activeGroupId = RxnString();
  final RxnString activeCommentsPostId = RxnString();
  final RxnString submittingJoinRequestGroupId = RxnString();
  final Rxn<File> selectedPostImage = Rxn<File>();

  final RxBool isBootstrapping = false.obs;
  final RxBool isGroupsLoading = true.obs;
  final RxBool isGroupLoading = false.obs;
  final RxBool isGroupPostsLoading = false.obs;
  final RxBool isApprovedMembersLoading = false.obs;
  final RxBool isPendingMembersLoading = false.obs;
  final RxBool isCommentsLoading = false.obs;
  final RxBool isCreatingGroup = false.obs;
  final RxBool isMatchingGroupsLoading = false.obs;
  final RxBool isCreatingPost = false.obs;
  final RxBool isSendingComment = false.obs;
  final RxBool hidePostAuthorName = false.obs;

  StreamSubscription<List<GroupModel>>? _groupsSubscription;
  StreamSubscription<List<GroupMemberModel>>? _userMembershipSubscription;
  StreamSubscription<GroupModel?>? _activeGroupSubscription;
  StreamSubscription<GroupMemberModel?>? _activeMembershipSubscription;
  StreamSubscription<List<GroupPostModel>>? _groupPostsSubscription;
  StreamSubscription<List<GroupMemberModel>>? _approvedMembersSubscription;
  StreamSubscription<List<GroupMemberModel>>? _pendingMembersSubscription;
  StreamSubscription<List<GroupCommentModel>>? _commentsSubscription;
  int _matchingRequestVersion = 0;

  String? get currentUserId => _authRepository.currentUser?.uid;

  static const List<String> defaultSensoryPreferences = [
    'Noise friendly',
    'Low light',
    'Quiet discussion',
    'Routine support',
    'Visual support',
    'Small groups',
  ];

  // Load community list stream and current user/children context.
  @override
  void onInit() {
    super.onInit();
    _bindGroups();
    _loadCurrentUserContext();
  }

  @override
  void onClose() {
    createGroupNameController.dispose();
    createGroupDescriptionController.dispose();
    createPostController.dispose();
    commentController.dispose();
    _groupsSubscription?.cancel();
    _userMembershipSubscription?.cancel();
    _activeGroupSubscription?.cancel();
    _activeMembershipSubscription?.cancel();
    _groupPostsSubscription?.cancel();
    _approvedMembersSubscription?.cancel();
    _pendingMembersSubscription?.cancel();
    _commentsSubscription?.cancel();
    super.onClose();
  }
    // Default sensory tags + normalized child sensory keys for create-group UI.

  List<String> get sensoryOptions {
    final childOptions = children
        .expand((child) => child.sensoryPreferences.keys)
        .map(_normalizeSensoryLabel)
        .where((item) => item.isNotEmpty)
        .toSet();

    return {...defaultSensoryPreferences, ...childOptions}.toList()..sort();
  }
    // Live stream of all groups; refresh matching groups whenever data changes.

  void _bindGroups() {
    isGroupsLoading.value = true;
    _groupsSubscription?.cancel();
    _groupsSubscription = _communityRepository.getGroups().listen(
      (items) {
        groups.assignAll(items);
        isGroupsLoading.value = false;
        unawaited(_refreshMatchingGroups());
      },
      onError: (error) {
        isGroupsLoading.value = false;
        ErrorHandler.showErrorSnackBar(error);
      },
    );
  }
    // Loads signed-in user and children so AI matching can personalize results.

  Future<void> _loadCurrentUserContext() async {
    final userId = currentUserId;
    if (userId == null) {
      isBootstrapping.value = false;
      return;
    }

    try {
      isBootstrapping.value = true;
      currentUserModel.value = await _userRepository.getUser(userId);

      final user = currentUserModel.value;
      if (user?.role == 'parent') {
        children.value = await _childRepository.getChildrenList(userId);
      } else {
        children.clear();
      }

      unawaited(_refreshMatchingGroups());

      _userMembershipSubscription?.cancel();
      _userMembershipSubscription = _communityRepository
          .getUserMemberships(userId)
          .listen(
            (items) => userMemberships.assignAll(items),
            onError: (error) => ErrorHandler.showErrorSnackBar(error),
          );
    } catch (e) {
      dev.log('Failed to load community context: $e', name: 'COMMUNITY_DEBUG');
      ErrorHandler.showErrorSnackBar(e);
    } finally {
      isBootstrapping.value = false;
    }
  }
    // Returns current user's membership record for one group (if any).

  GroupMemberModel? membershipForGroup(String groupId) {
    return userMemberships.firstWhereOrNull(
      (membership) => membership.groupId == groupId,
    );
  }

  bool isOwner(GroupModel group) => group.ownerId == currentUserId;
    // Owners and approved members can post inside the selected group.

  bool get canCreatePostInActiveGroup {
    final group = activeGroup.value;
    if (group == null) {
      return false;
    }
    if (isOwner(group)) {
      return true;
    }
    return activeMembership.value?.isApproved ?? false;
  }
    // Computes card button label based on ownership/membership status.

  String ctaLabelForGroup(GroupModel group) {
    if (isOwner(group)) {
      return 'Manage';
    }

    final membership = membershipForGroup(group.id);
    if (membership == null) {
      return 'Join group';
    }
    if (membership.isApproved) {
      return 'Open group';
    }
    if (membership.isPending) {
      return 'Request pending';
    }
    if (membership.status == GroupMembershipStatus.rejected.value) {
      return 'Request again';
    }
    return 'Join group';
  }
    // Join is allowed only when user is not owner and not already pending/approved.

  bool canSendJoinRequest(GroupModel group) {
    final membership = membershipForGroup(group.id);
    return !isOwner(group) &&
        (membership == null ||
            membership.status == GroupMembershipStatus.rejected.value ||
            membership.status == GroupMembershipStatus.removed.value);
  }

  bool canCancelJoinRequest(GroupModel group) {
    final membership = membershipForGroup(group.id);
    return !isOwner(group) && (membership?.isPending ?? false);
  }

  bool isJoinRequestLoadingFor(String groupId) {
    return submittingJoinRequestGroupId.value == groupId;
  }
    // Matching section is shown only for parent flow.

  bool get shouldShowMatchingSection {
    return children.isNotEmpty || currentUserModel.value?.role == 'parent';
  }
    // Reason text shown under each highlighted recommended group card.

  String matchingReasonForGroup(String groupId) {
    return matchingGroupReasons[groupId] ?? 'Matches your child preferences.';
  }

  String matchingGroupsEmptyMessage() {
    if (children.isEmpty) {
      return 'Add your child details to get AI-matched communities here.';
    }

    final labels = _preferredSensoryLabelsFromChildren();
    if (labels.isEmpty) {
      return 'Update your child preferences to see more personalized matches.';
    }

    return 'No strong matches found yet. You can still explore all communities below.';
  }

  void toggleSensoryPreference(String value) {
    if (selectedSensoryPreferences.contains(value)) {
      selectedSensoryPreferences.remove(value);
    } else {
      selectedSensoryPreferences.add(value);
    }
  }

  void resetCreateGroupSelection() {
    selectedSensoryPreferences.clear();
    createGroupNameController.clear();
    createGroupDescriptionController.clear();
  }
    // Opens bottom sheet to create a new community group.

  Future<void> openCreateCommunitySheet() async {
    resetCreateGroupSelection();
    await Get.bottomSheet<void>(
      const CommunityCreateSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
    // Validates input and creates group + owner membership in one flow.

  Future<void> createGroup() async {
    if (isCreatingGroup.value) {
      return;
    }

    final userId = currentUserId;
    final user = currentUserModel.value;
    if (userId == null || user == null) {
      ErrorHandler.showErrorSnackBar('Please sign in to create a community.');
      return;
    }

    final trimmedName = createGroupNameController.text.trim();
    final trimmedDescription = createGroupDescriptionController.text.trim();

    if (trimmedName.isEmpty) {
      ErrorHandler.showErrorSnackBar('Please enter a community name.');
      return;
    }
    if (trimmedDescription.isEmpty) {
      ErrorHandler.showErrorSnackBar('Please enter a short description.');
      return;
    }

    try {
      isCreatingGroup.value = true;
      final now = DateTime.now();
      final groupId = now.microsecondsSinceEpoch.toString();

      final group = GroupModel(
        id: groupId,
        name: trimmedName,
        description: trimmedDescription,
        ownerId: userId,
        ownerName: user.name,
        sensoryPreferences: selectedSensoryPreferences.toList(),
        totalMembers: 1,
        pendingRequests: 0,
        totalPosts: 0,
        createdAt: now,
        updatedAt: now,
      );

      final ownerMembership = GroupMemberModel(
        id: '${groupId}_$userId',
        groupId: groupId,
        userId: userId,
        userName: user.name,
        userImage: user.profileImageUrl ?? user.profileImage,
        role: GroupMemberRole.owner.value,
        status: GroupMembershipStatus.approved.value,
        requestedAt: now,
        respondedAt: now,
        joinedAt: now,
        respondedBy: userId,
      );

      await _communityRepository.createGroup(
        group: group,
        ownerMembership: ownerMembership,
      );

      resetCreateGroupSelection();
      ErrorHandler.showSuccessSnackBar(
        'Success',
        'Community created successfully.',
      );
      Get.back();
    } catch (e) {
      dev.log('Failed to create community: $e', name: 'COMMUNITY_DEBUG');
      ErrorHandler.showErrorSnackBar(e);
    } finally {
      isCreatingGroup.value = false;
    }
  }
    // Sets active group and binds all streams needed for group detail screen.

  Future<void> openGroup(String groupId) async {
    final group = groups.firstWhereOrNull((item) => item.id == groupId);
    activeGroupId.value = groupId;
    activeGroup.value = group;
    activeMembership.value = membershipForGroup(groupId);
    activeGroupPosts.clear();
    activeApprovedMembers.clear();
    activePendingMembers.clear();
    activeComments.clear();
    activeCommentsPostId.value = null;

    _bindActiveGroup(groupId);
    _bindGroupPosts(groupId);
    _bindManagementStreams(groupId);

    await Get.to<void>(() => CommunityGroupView(groupId: groupId));
  }
    // Watches group document and the current user's membership for this group.

  void _bindActiveGroup(String groupId) {
    final userId = currentUserId;
    isGroupLoading.value = true;
    _activeGroupSubscription?.cancel();
    _activeMembershipSubscription?.cancel();

    _activeGroupSubscription = _communityRepository
        .watchGroup(groupId)
        .listen(
          (group) {
            activeGroup.value = group;
            isGroupLoading.value = false;
          },
          onError: (error) {
            isGroupLoading.value = false;
            ErrorHandler.showErrorSnackBar(error);
          },
        );

    if (userId == null) {
      activeMembership.value = null;
      return;
    }

    _activeMembershipSubscription = _communityRepository
        .watchMembership(groupId, userId)
        .listen((membership) {
          activeMembership.value = membership;
        }, onError: (error) => ErrorHandler.showErrorSnackBar(error));
  }
    // Watches posts stream for active group.

  void _bindGroupPosts(String groupId) {
    isGroupPostsLoading.value = true;
    _groupPostsSubscription?.cancel();
    _groupPostsSubscription = _communityRepository
        .getGroupPosts(groupId)
        .listen(
          (posts) {
            activeGroupPosts.assignAll(posts);
            isGroupPostsLoading.value = false;
          },
          onError: (error) {
            isGroupPostsLoading.value = false;
            ErrorHandler.showErrorSnackBar(error);
          },
        );
  }
    // Watches approved and pending member lists for owner management screen.

  void _bindManagementStreams(String groupId) {
    isApprovedMembersLoading.value = true;
    isPendingMembersLoading.value = true;

    _approvedMembersSubscription?.cancel();
    _pendingMembersSubscription?.cancel();

    _approvedMembersSubscription = _communityRepository
        .getGroupMembers(groupId, status: GroupMembershipStatus.approved.value)
        .listen(
          (members) {
            activeApprovedMembers.assignAll(members);
            isApprovedMembersLoading.value = false;
          },
          onError: (error) {
            isApprovedMembersLoading.value = false;
            ErrorHandler.showErrorSnackBar(error);
          },
        );

    _pendingMembersSubscription = _communityRepository
        .getGroupMembers(groupId, status: GroupMembershipStatus.pending.value)
        .listen(
          (members) {
            activePendingMembers.assignAll(members);
            isPendingMembersLoading.value = false;
          },
          onError: (error) {
            isPendingMembersLoading.value = false;
            ErrorHandler.showErrorSnackBar(error);
          },
        );
  }

  Future<void> openManagement(GroupModel group) async {
    if (activeGroupId.value != group.id) {
      activeGroup.value = group;
      activeGroupId.value = group.id;
      _bindManagementStreams(group.id);
    }
    await Get.to<void>(() => CommunityManagementView(groupId: group.id));
  }
    // Sends join request for current user to selected community.

  Future<void> requestJoin(GroupModel group) async {
    if (submittingJoinRequestGroupId.value != null) {
      return;
    }

    final userId = currentUserId;
    final user = currentUserModel.value;
    if (userId == null || user == null) {
      ErrorHandler.showErrorSnackBar('Please sign in to join a community.');
      return;
    }

    try {
      submittingJoinRequestGroupId.value = group.id;
      await _communityRepository.requestToJoinGroup(
        group: group,
        userId: userId,
        userName: user.name,
        userImage: user.profileImageUrl ?? user.profileImage,
      );
      await CommunityNotificationDispatcher.notifyJoinRequestSubmitted(
        group: group,
        requesterId: userId,
        requesterName: user.name,
      );
      ErrorHandler.showSuccessSnackBar(
        'Request sent',
        'Your join request has been sent to the group owner.',
      );
    } catch (e) {
      ErrorHandler.showErrorSnackBar(e);
    } finally {
      if (submittingJoinRequestGroupId.value == group.id) {
        submittingJoinRequestGroupId.value = null;
      }
    }
  }

  Future<void> cancelJoinRequest(GroupModel group) async {
    if (submittingJoinRequestGroupId.value != null) {
      return;
    }

    final userId = currentUserId;
    final user = currentUserModel.value;
    if (userId == null || user == null) {
      ErrorHandler.showErrorSnackBar('Please sign in to update your request.');
      return;
    }

    try {
      submittingJoinRequestGroupId.value = group.id;
      await _communityRepository.cancelJoinRequest(
        groupId: group.id,
        userId: userId,
      );
      await CommunityNotificationDispatcher.notifyJoinRequestCancelled(
        group: group,
        requesterId: userId,
        requesterName: user.name,
      );
      ErrorHandler.showSuccessSnackBar(
        'Request cancelled',
        'Your join request has been cancelled.',
      );
    } catch (e) {
      ErrorHandler.showErrorSnackBar(e);
    } finally {
      if (submittingJoinRequestGroupId.value == group.id) {
        submittingJoinRequestGroupId.value = null;
      }
    }
  }
    // Opens post composer only when current user has posting permission.

  Future<void> openCreatePostSheet() async {
    if (!canCreatePostInActiveGroup) {
      ErrorHandler.showErrorSnackBar(
        'Only approved members can create posts in this group.',
      );
      return;
    }
    createPostController.clear();
    selectedPostImage.value = null;
    hidePostAuthorName.value = false;
    await Get.bottomSheet<void>(
      const CommunityCreatePostSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
    // Creates post text/image inside currently active group.

  Future<void> createGroupPost() async {
    if (isCreatingPost.value) {
      return;
    }

    final group = activeGroup.value;
    final userId = currentUserId;
    final user = currentUserModel.value;
    if (group == null || userId == null || user == null) {
      ErrorHandler.showErrorSnackBar('Please sign in to post in a community.');
      return;
    }

    final trimmedContent = createPostController.text.trim();
    if (trimmedContent.isEmpty && selectedPostImage.value == null) {
      ErrorHandler.showErrorSnackBar(
        'Please add post text or upload an image before posting.',
      );
      return;
    }

    try {
      isCreatingPost.value = true;
      final now = DateTime.now();
      String? imageUrl;
      String? imagePath;

      if (selectedPostImage.value != null) {
        final uploadResult = await _storageService.uploadImage(
          file: selectedPostImage.value!,
          folder: 'community_posts/$userId/${group.id}',
        );
        imageUrl = uploadResult['url'];
        imagePath = uploadResult['path'];
      }

      final post = GroupPostModel(
        id: now.microsecondsSinceEpoch.toString(),
        groupId: group.id,
        userId: userId,
        userName: hidePostAuthorName.value ? 'Anonymous Post' : user.name,
        userImage: hidePostAuthorName.value
            ? null
            : (user.profileImageUrl ?? user.profileImage),
        content: trimmedContent,
        hideName: hidePostAuthorName.value,
        imageUrl: imageUrl,
        imagePath: imagePath,
        createdAt: now,
        updatedAt: now,
      );

      await _communityRepository.createGroupPost(groupId: group.id, post: post);
      await CommunityNotificationDispatcher.notifyGroupPostCreated(
        group: group,
        post: post,
      );
      createPostController.clear();
      selectedPostImage.value = null;
      hidePostAuthorName.value = false;
      if (Get.isBottomSheetOpen ?? false) {
        Get.back<void>();
      }
      ErrorHandler.showSuccessSnackBar('Success', 'Post created successfully.');
    } catch (e) {
      ErrorHandler.showErrorSnackBar(e);
    } finally {
      isCreatingPost.value = false;
    }
  }
    // Image picker helper for post attachment.

  Future<void> pickPostImage() async {
    await ImagePickerHelper.showImageSourceSheet(
      onImagePicked: (file) {
        selectedPostImage.value = file;
      },
      onImageRemoved: removePostImage,
      showRemoveOption: selectedPostImage.value != null,
    );
  }

  void removePostImage() {
    selectedPostImage.value = null;
  }

  void toggleHidePostAuthor(bool? value) {
    hidePostAuthorName.value = value ?? false;
  }
    // Toggles like for one post for the signed-in user.

  Future<void> toggleGroupPostLike(String postId) async {
    final userId = currentUserId;
    if (userId == null) {
      ErrorHandler.showErrorSnackBar('Please sign in to like posts.');
      return;
    }

    try {
      final isLiked = await _communityRepository.toggleGroupPostLike(
        postId: postId,
        userId: userId,
      );
      if (!isLiked) {
        return;
      }

      final group = activeGroup.value;
      final post = await _communityRepository.getGroupPostById(postId);
      final user = currentUserModel.value;
      if (group != null && post != null && user != null) {
        await CommunityNotificationDispatcher.notifyGroupPostLiked(
          group: group,
          post: post,
          actorId: userId,
          actorName: user.name,
        );
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(e);
    }
  }
    // Opens comments bottom sheet and starts comments stream for that post.

  Future<void> openCommentsSheet(String postId) async {
    activeCommentsPostId.value = postId;
    commentController.clear();
    _bindComments(postId);
    await Get.bottomSheet<void>(
      const CommunityCommentsSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
    // Watches comments stream for selected post.

  void _bindComments(String postId) {
    isCommentsLoading.value = true;
    _commentsSubscription?.cancel();
    _commentsSubscription = _communityRepository
        .getComments(postId)
        .listen(
          (comments) {
            activeComments.assignAll(comments);
            isCommentsLoading.value = false;
          },
          onError: (error) {
            isCommentsLoading.value = false;
            ErrorHandler.showErrorSnackBar(error);
          },
        );
  }
    // Creates a new comment in the active post thread.

  Future<void> addComment() async {
    if (isSendingComment.value) {
      return;
    }

    final group = activeGroup.value;
    final postId = activeCommentsPostId.value;
    final userId = currentUserId;
    final user = currentUserModel.value;
    if (group == null || postId == null || userId == null || user == null) {
      ErrorHandler.showErrorSnackBar('Please sign in to comment.');
      return;
    }

    final trimmedContent = commentController.text.trim();
    if (trimmedContent.isEmpty) {
      ErrorHandler.showErrorSnackBar('Please write a comment first.');
      return;
    }

    try {
      isSendingComment.value = true;
      final comment = GroupCommentModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        groupId: group.id,
        postId: postId,
        userId: userId,
        userName: user.name,
        userImage: user.profileImageUrl ?? user.profileImage,
        content: trimmedContent,
        createdAt: DateTime.now(),
      );

      await _communityRepository.addComment(comment);
      final post = await _communityRepository.getGroupPostById(postId);
      if (post != null) {
        await CommunityNotificationDispatcher.notifyGroupCommentAdded(
          group: group,
          post: post,
          comment: comment,
        );
      }
      commentController.clear();
    } catch (e) {
      ErrorHandler.showErrorSnackBar(e);
    } finally {
      isSendingComment.value = false;
    }
  }
    // Owner action: approve pending join request.

  Future<void> approveRequest(String userId) async {
    final groupId = activeGroupId.value;
    final adminId = currentUserId;
    final group = activeGroup.value;
    final admin = currentUserModel.value;
    if (groupId == null || adminId == null || group == null || admin == null) {
      return;
    }

    try {
      await _communityRepository.approveJoinRequest(
        groupId: groupId,
        userId: userId,
        adminId: adminId,
      );
      await CommunityNotificationDispatcher.notifyJoinRequestApproved(
        group: group,
        memberUserId: userId,
        adminName: admin.name,
      );
      ErrorHandler.showSuccessSnackBar('Approved', 'Member request approved.');
    } catch (e) {
      ErrorHandler.showErrorSnackBar(e);
    }
  }
    // Owner action: reject pending join request.

  Future<void> rejectRequest(String userId) async {
    final groupId = activeGroupId.value;
    final adminId = currentUserId;
    final group = activeGroup.value;
    final admin = currentUserModel.value;
    if (groupId == null || adminId == null || group == null || admin == null) {
      return;
    }

    try {
      await _communityRepository.rejectJoinRequest(
        groupId: groupId,
        userId: userId,
        adminId: adminId,
      );
      await CommunityNotificationDispatcher.notifyJoinRequestRejected(
        group: group,
        memberUserId: userId,
        adminName: admin.name,
      );
      ErrorHandler.showSuccessSnackBar('Rejected', 'Join request rejected.');
    } catch (e) {
      ErrorHandler.showErrorSnackBar(e);
    }
  }
    // Owner action: remove an approved member from group.

  Future<void> removeMember(String userId) async {
    final groupId = activeGroupId.value;
    final adminId = currentUserId;
    final group = activeGroup.value;
    final admin = currentUserModel.value;
    if (groupId == null || adminId == null || group == null || admin == null) {
      return;
    }

    try {
      await _communityRepository.removeMember(
        groupId: groupId,
        userId: userId,
        adminId: adminId,
      );
      await CommunityNotificationDispatcher.notifyMemberRemoved(
        group: group,
        memberUserId: userId,
        adminName: admin.name,
      );
      ErrorHandler.showSuccessSnackBar(
        'Removed',
        'Member removed from the group.',
      );
    } catch (e) {
      ErrorHandler.showErrorSnackBar(e);
    }
  }

  String emptyPostsMessage() {
    return 'No posts yet. Once someone shares in this community, it will appear here.';
  }

  String emptyMembersMessage() {
    return 'No approved members yet.';
  }

  String emptyRequestsMessage() {
    return 'No pending requests right now.';
  }
    // Main matching flow:
    // 1) Call AI suggestion service
    // 2) Map AI ids -> real groups
    // 3) Fallback to local matching when AI fails/empty

  Future<void> _refreshMatchingGroups() async {
    final requestVersion = ++_matchingRequestVersion;

    if (groups.isEmpty || !shouldShowMatchingSection) {
      if (requestVersion == _matchingRequestVersion) {
        matchingGroups.clear();
        matchingGroupReasons.clear();
        isMatchingGroupsLoading.value = false;
      }
      return;
    }

    if (children.isEmpty) {
      if (requestVersion == _matchingRequestVersion) {
        matchingGroups.clear();
        matchingGroupReasons.clear();
        isMatchingGroupsLoading.value = false;
      }
      return;
    }

    final availableGroups = groups.toList(growable: false);
    isMatchingGroupsLoading.value = true;

    try {
      final aiRecommendations = await _groupSuggestionService.suggestGroups(
        children: children.toList(growable: false),
        groups: availableGroups,
      );

      if (requestVersion != _matchingRequestVersion) {
        return;
      }

      if (aiRecommendations.isNotEmpty) {
        final groupsById = {
          for (final group in availableGroups) group.id: group,
        };
        final recommendedGroups = <GroupModel>[];
        final reasons = <String, String>{};

        for (final recommendation in aiRecommendations) {
          final group = groupsById[recommendation.groupId];
          if (group == null) {
            continue;
          }

          recommendedGroups.add(group);
          reasons[group.id] = recommendation.reason;
        }

        if (recommendedGroups.isNotEmpty) {
          matchingGroups.assignAll(recommendedGroups);
          matchingGroupReasons.assignAll(reasons);
          return;
        }
      }

      _applyFallbackMatches(availableGroups);
    } catch (e) {
      dev.log(
        'Failed to load AI community matches: $e',
        name: 'COMMUNITY_DEBUG',
      );

      if (requestVersion != _matchingRequestVersion) {
        return;
      }

      _applyFallbackMatches(availableGroups);
    } finally {
      if (requestVersion == _matchingRequestVersion) {
        isMatchingGroupsLoading.value = false;
      }
    }
  }
    // Local non-AI backup ranking so UI still shows useful recommendations.

  void _applyFallbackMatches(List<GroupModel> availableGroups) {
    final rankedGroups =
        availableGroups
            .map(_buildFallbackMatch)
            .whereType<_LocalGroupMatch>()
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    final selectedMatches = rankedGroups.take(5).toList(growable: true);
    if (selectedMatches.isEmpty && children.isNotEmpty) {
      final exploratoryGroups = availableGroups
          .take(5)
          .map((group) {
            return _LocalGroupMatch(
              group: group,
              score: 0,
              reason:
                  'Recommended from your child profile for community exploration.',
            );
          })
          .toList(growable: false);
      selectedMatches.addAll(exploratoryGroups);
    }

    matchingGroups.assignAll(selectedMatches.map((item) => item.group));
    matchingGroupReasons.assignAll({
      for (final item in selectedMatches) item.group.id: item.reason,
    });
  }
    // Scores one group against weighted child sensory preferences.

  _LocalGroupMatch? _buildFallbackMatch(GroupModel group) {
    final weightedPreferences = _weightedChildPreferences();
    if (weightedPreferences.isEmpty) {
      return null;
    }

    final groupTags = group.sensoryPreferences
        .map(_normalizeTextForSearch)
        .where((item) => item.isNotEmpty)
        .toSet();
    final searchableText =
        '${group.name} ${group.description} ${group.sensoryPreferences.join(' ')}';
    final normalizedSearchableText = _normalizeTextForSearch(searchableText);

    var score = 0;
    final matchedLabels = <String>[];

    weightedPreferences.forEach((label, weight) {
      final normalizedLabel = _normalizeTextForSearch(label);
      final tokenMatches = normalizedLabel
          .split(' ')
          .where(
            (token) =>
                token.isNotEmpty && normalizedSearchableText.contains(token),
          )
          .length;
      final hasDirectTag = groupTags.contains(normalizedLabel);

      if (hasDirectTag) {
        score += weight * 3;
        matchedLabels.add(label);
      } else if (tokenMatches > 0) {
        score += weight * tokenMatches;
        matchedLabels.add(label);
      }
    });

    if (score <= 0) {
      return null;
    }

    final uniqueLabels = matchedLabels.toSet().take(2).toList();
    final reason = uniqueLabels.isEmpty
        ? 'Looks relevant to your saved child preferences.'
        : 'Matches ${uniqueLabels.join(' and ')} preferences.';

    return _LocalGroupMatch(group: group, score: score, reason: reason);
  }
    // Converts child sensory values into weighted labels for local ranking.

  Map<String, int> _weightedChildPreferences() {
    final weights = <String, int>{};

    for (final child in children) {
      for (final entry in child.sensoryPreferences.entries) {
        final normalizedKey = entry.key.trim().toLowerCase();
        final baseWeight = entry.value >= 7
            ? 3
            : entry.value >= 5
            ? 2
            : 1;

        for (final label in _labelsForChildPreference(normalizedKey)) {
          weights[label] = (weights[label] ?? 0) + baseWeight;
        }
      }
    }

    return weights;
  }
    // Top labels used for empty-state guidance copy.

  List<String> _preferredSensoryLabelsFromChildren() {
    final weighted = _weightedChildPreferences().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return weighted.map((entry) => entry.key).take(4).toList();
  }
    // Normalizes child preference keys into community label vocabulary.

  List<String> _labelsForChildPreference(String key) {
    switch (key) {
      case 'noise':
        return const ['Noise friendly', 'Quiet discussion'];
      case 'crowd':
        return const ['Small groups', 'Quiet discussion'];
      case 'light':
        return const ['Low light'];
      case 'touch':
        return const ['Routine support', 'Visual support'];
      default:
        final normalized = _normalizeSensoryLabel(key);
        return normalized.isEmpty ? const [] : [normalized];
    }
  }
    // Normalization for simple contains-based matching.

  String _normalizeTextForSearch(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
    // Converts raw sensory key to title-case readable label.

  String _normalizeSensoryLabel(String raw) {
    final cleaned = raw.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) {
      return '';
    }

    return cleaned
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _LocalGroupMatch {
  const _LocalGroupMatch({
    required this.group,
    required this.score,
    required this.reason,
  });

  final GroupModel group;
  final int score;
  final String reason;
}
