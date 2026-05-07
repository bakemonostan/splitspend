import 'package:split_spend/src/features/activity/models/activity_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityRepository {
  ActivityRepository(this._client);

  final SupabaseClient _client;

  Future<List<ActivityItem>> fetchActivity({int limit = 80}) async {
    final rows = await _client
        .from('activity_logs')
        .select(
          'id, group_id, actor_user_id, event_type, summary, created_at, groups(name)',
        )
        .order('created_at', ascending: false)
        .limit(limit);

    final list = rows as List<dynamic>;
    if (list.isEmpty) {
      return [];
    }

    final actorIds = list
        .map((r) => Map<String, dynamic>.from(r as Map)['actor_user_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    final profilesRows = actorIds.isEmpty
        ? <dynamic>[]
        : await _client
              .from('profiles')
              .select('id, display_name')
              .inFilter('id', actorIds);

    final profilesById = <String, String>{};
    for (final row in profilesRows) {
      final m = Map<String, dynamic>.from(row as Map);
      final id = m['id']?.toString();
      final name = m['display_name']?.toString().trim();
      if (id != null && name != null && name.isNotEmpty) {
        profilesById[id] = name;
      }
    }

    final out = <ActivityItem>[];
    for (final row in list) {
      final m = Map<String, dynamic>.from(row as Map);
      final actorId = m['actor_user_id']?.toString();
      final group = m['groups'];
      final createdAtRaw = m['created_at']?.toString();
      final createdAt = createdAtRaw == null
          ? DateTime.now()
          : DateTime.tryParse(createdAtRaw)?.toLocal() ?? DateTime.now();

      out.add(
        ActivityItem(
          id: m['id']?.toString() ?? '',
          groupId: m['group_id']?.toString() ?? '',
          eventType: m['event_type']?.toString() ?? 'event',
          summary: m['summary']?.toString(),
          createdAt: createdAt,
          actorUserId: actorId,
          actorDisplayName: actorId == null ? null : profilesById[actorId],
          groupName: group is Map<String, dynamic>
              ? group['name']?.toString()
              : null,
        ),
      );
    }
    return out;
  }
}
