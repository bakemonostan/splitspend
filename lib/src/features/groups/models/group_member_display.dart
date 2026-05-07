/// Member row for group settings (from `group_members` + `profiles`).
class GroupMemberDisplay {
  const GroupMemberDisplay({
    required this.userId,
    required this.role,
    this.displayName,
    this.avatarUrl,
  });

  final String userId;
  final String role;
  final String? displayName;
  final String? avatarUrl;

  bool get isOwner => role == 'owner';

  String get shortIdTail =>
      userId.length > 8 ? userId.substring(userId.length - 6) : userId;
}
