import 'package:image_picker/image_picker.dart';
import 'package:split_spend/src/core/storage/avatar_storage_service.dart';
import 'package:split_spend/src/features/home/models/group_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          'group_id, groups(id, name, category, invite_code, cover_image_url, created_at)',
        )
        .eq('user_id', uid);

    final list = membershipRows as List<dynamic>;
    final byGroupId = <String, Map<String, dynamic>>{};
    for (final row in list) {
      final map = Map<String, dynamic>.from(row as Map);
      final g = map['groups'];
      if (g is Map<String, dynamic>) {
        final id = g['id']?.toString();
        if (id != null) {
          byGroupId[id] = Map<String, dynamic>.from(g);
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
      out.add(
        GroupSummary.fromGroupRow(
          entry.value,
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

    // DB trigger `after_group_created` inserts the owner row into `group_members`.
    // Do not insert here — duplicate (group_id, user_id) violates PK.
    final inserted = await _client
        .from('groups')
        .insert({
          'name': trimmed,
          'created_by': uid,
          'category': category,
        })
        .select('id, invite_code')
        .single();

    return Map<String, dynamic>.from(inserted);
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

  Future<void> joinGroupByInviteCode(String rawCode) async {
    final code = normalizeInviteCode(rawCode);
    if (code.length < 4) {
      throw ArgumentError('Invite code is too short.');
    }
    await _client.rpc<void>(
      'join_group_by_invite_code',
      params: {'p_code': code},
    );
  }
}
