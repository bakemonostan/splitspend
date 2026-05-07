import 'package:image_picker/image_picker.dart';
import 'package:split_spend/src/core/storage/avatar_storage_service.dart';
import 'package:split_spend/src/features/groups/models/group_member_display.dart';
import 'package:split_spend/src/features/home/models/group_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result of [GroupsRepository.joinGroupByInviteCode] (RPC returns JSON).
class JoinGroupResult {
  const JoinGroupResult({required this.status, required this.groupId});

  final String status;
  final String groupId;

  bool get joined => status == 'joined';

  bool get alreadyMember => status == 'already_member';
}

class GroupsRepository {
  GroupsRepository(this._client);

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Groups the current user belongs to, sorted by name.
  Future<List<GroupSummary>> fetchMyGroups() async {
    final uid = _userId;
    if (uid == null) {
      return [];
    }

    // Avoid nested `group_members(count)` embed — PostgREST often rejects / fails this shape.
    final membershipRows = await _client
        .from('group_members')
        .select(
          'role, group_id, groups(id, name, category, invite_code, cover_image_url, created_at)',
        )
        .eq('user_id', uid);

    final list = membershipRows as List<dynamic>;
    final byGroupId = <String, Map<String, dynamic>>{};
    for (final row in list) {
      final map = Map<String, dynamic>.from(row as Map);
      final g = map['groups'];
      final role = map['role'] as String? ?? 'member';
      if (g is Map<String, dynamic>) {
        final id = g['id']?.toString();
        if (id != null) {
          byGroupId[id] = {
            'group': Map<String, dynamic>.from(g),
            'role': role,
          };
        }
      }
    }

    if (byGroupId.isEmpty) {
      return [];
    }

    final ids = byGroupId.keys.toList();
    final memberRows = await _client
        .from('group_members')
        .select('group_id')
        .inFilter('group_id', ids);

    final counts = <String, int>{for (final id in ids) id: 0};
    for (final row in memberRows as List<dynamic>) {
      final m = Map<String, dynamic>.from(row as Map);
      final gid = m['group_id']?.toString();
      if (gid != null && counts.containsKey(gid)) {
        counts[gid] = counts[gid]! + 1;
      }
    }

    final out = <GroupSummary>[];
    for (final entry in byGroupId.entries) {
      final bundle = entry.value;
      final g = bundle['group'] as Map<String, dynamic>;
      final role = bundle['role'] as String? ?? 'member';
      out.add(
        GroupSummary.fromGroupRow(
          g,
          memberRole: role,
          memberCount: counts[entry.key] ?? 1,
        ),
      );
    }
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  }

  /// Creates a group and inserts the owner row. Server assigns [invite_code].
  Future<Map<String, dynamic>> createGroup({
    required String name,
    required String category,
  }) async {
    final uid = _userId;
    if (uid == null) {
      throw StateError('Sign in to create a group.');
    }

    final trimmed = name.trim();
    if (trimmed.length < 2) {
      throw ArgumentError('Group name is too short.');
    }

    // RPC runs as SECURITY DEFINER so INSERT succeeds even when direct REST inserts
    // hit confusing client/session + RLS interactions; created_by is set from auth.uid()
    // inside Postgres only.
    final raw = await _client.rpc<dynamic>(
      'create_group',
      params: {'p_name': trimmed, 'p_category': category},
    );
    if (raw is! Map) {
      throw StateError('Unexpected create_group response');
    }
    return Map<String, dynamic>.from(raw);
  }

  /// Uploads a group cover to the same public `avatars` bucket under `{userId}/group-covers/{groupId}.*`
  /// (allowed by existing Storage RLS). Updates [groups.cover_image_url].
  Future<void> uploadGroupCoverIfPresent({
    required String groupId,
    required XFile image,
  }) async {
    final uid = _userId;
    if (uid == null) {
      throw StateError('Not signed in.');
    }

    final ext = _extensionForMime(image.mimeType);
    final path = '$uid/group-covers/$groupId.$ext';
    final bytes = await image.readAsBytes();
    final contentType = image.mimeType ??
        (ext == 'png' ? 'image/png' : 'image/jpeg');

    await _client.storage.from(AvatarStorageService.bucketId).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: contentType,
      ),
    );

    final publicUrl =
        _client.storage.from(AvatarStorageService.bucketId).getPublicUrl(path);

    await _client.from('groups').update({
      'cover_image_url': publicUrl,
    }).eq('id', groupId).eq('created_by', uid);
  }

  static String _extensionForMime(String? mime) {
    if (mime != null && mime.toLowerCase().contains('png')) {
      return 'png';
    }
    return 'jpg';
  }

  /// Matches server normalization: trim, strip `#`, remove whitespace, uppercase.
  static String normalizeInviteCode(String raw) {
    var s = raw.trim();
    s = s.replaceFirst(RegExp(r'^#+\s*'), '');
    s = s.replaceAll(RegExp(r'\s+'), '');
    return s.toUpperCase();
  }

  Future<JoinGroupResult> joinGroupByInviteCode(String rawCode) async {
    final code = normalizeInviteCode(rawCode);
    if (code.length < 4) {
      throw ArgumentError('Invite code is too short.');
    }
    final raw = await _client.rpc<dynamic>(
      'join_group_by_invite_code',
      params: {'p_code': code},
    );
    if (raw is! Map) {
      throw StateError('Unexpected join_group_by_invite_code response');
    }
    final map = Map<String, dynamic>.from(raw);
    return JoinGroupResult(
      status: map['status'] as String? ?? '',
      groupId: map['group_id']?.toString() ?? '',
    );
  }

  /// Members of a group (owner first). Requires `profiles_select_same_group_member` RLS.
  Future<List<GroupMemberDisplay>> fetchGroupMembers(String groupId) async {
    if (_userId == null) {
      return [];
    }

    final membershipRows = await _client
        .from('group_members')
        .select('user_id, role')
        .eq('group_id', groupId);

    final list = membershipRows as List<dynamic>;
    if (list.isEmpty) {
      return [];
    }

    final ids = list
        .map((r) => Map<String, dynamic>.from(r)['user_id']?.toString())
        .whereType<String>()
        .toList();

    final profileRows = ids.isEmpty
        ? <dynamic>[]
        : await _client
              .from('profiles')
              .select('id, display_name, avatar_url')
              .inFilter('id', ids);

    final profilesById = <String, Map<String, dynamic>>{};
    for (final row in profileRows) {
      final m = Map<String, dynamic>.from(row);
      final id = m['id']?.toString();
      if (id != null) {
        profilesById[id] = m;
      }
    }

    final out = <GroupMemberDisplay>[];
    for (final row in list) {
      final m = Map<String, dynamic>.from(row);
      final userId = m['user_id']?.toString();
      if (userId == null) {
        continue;
      }
      final role = m['role'] as String? ?? 'member';
      final p = profilesById[userId];
      out.add(
        GroupMemberDisplay(
          userId: userId,
          role: role,
          displayName: p?['display_name'] as String?,
          avatarUrl: p?['avatar_url'] as String?,
        ),
      );
    }

    out.sort((a, b) {
      if (a.isOwner != b.isOwner) {
        return a.isOwner ? -1 : 1;
      }
      final an =
          (a.displayName ?? '').toLowerCase();
      final bn =
          (b.displayName ?? '').toLowerCase();
      return an.compareTo(bn);
    });

    return out;
  }

  Future<void> removeMember({
    required String groupId,
    required String targetUserId,
  }) async {
    await _client.from('group_members').delete().match({
      'group_id': groupId,
      'user_id': targetUserId,
    });
  }

  Future<void> leaveGroup(String groupId) async {
    final uid = _userId;
    if (uid == null) {
      throw StateError('Not signed in.');
    }
    await _client.from('group_members').delete().match({
      'group_id': groupId,
      'user_id': uid,
    });
  }

  Future<void> deleteGroup(String groupId) async {
    await _client.from('groups').delete().eq('id', groupId);
  }

  Future<void> updateGroupName({
    required String groupId,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.length < 2) {
      throw ArgumentError('Name too short.');
    }
    await _client.from('groups').update({'name': trimmed}).eq('id', groupId);
  }
}
