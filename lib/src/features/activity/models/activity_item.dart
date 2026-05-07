class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.groupId,
    required this.eventType,
    required this.createdAt,
    this.actorUserId,
    this.actorDisplayName,
    this.summary,
    this.groupName,
  });

  final String id;
  final String groupId;
  final String eventType;
  final DateTime createdAt;
  final String? actorUserId;
  final String? actorDisplayName;
  final String? summary;
  final String? groupName;
}
