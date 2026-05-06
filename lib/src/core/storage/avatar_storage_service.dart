import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Storage bucket for profile photos (create bucket + policies in dashboard; see docs).
abstract final class AvatarStorageService {
  static const String bucketId = 'avatars';

  static String _objectPath(String userId, String extension) =>
      '$userId/avatar.$extension';

  static String _extensionForMime(String? mime) {
    if (mime != null && mime.toLowerCase().contains('png')) return 'png';
    return 'jpg';
  }

  /// Uploads picked image and refreshes [User.userMetadata] `avatar_url` (public URL).
  static Future<String> uploadProfilePhoto(XFile file) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to upload a profile photo.');
    }

    final ext = _extensionForMime(file.mimeType);
    final path = _objectPath(user.id, ext);
    final bytes = await file.readAsBytes();
    final contentType = file.mimeType ??
        (ext == 'png' ? 'image/png' : 'image/jpeg');

    await client.storage.from(bucketId).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: contentType,
      ),
    );

    final publicUrl = client.storage.from(bucketId).getPublicUrl(path);
    final bust = DateTime.now().millisecondsSinceEpoch;
    final urlWithBust = '$publicUrl?v=$bust';

    final meta = Map<String, dynamic>.from(user.userMetadata ?? {});
    meta['avatar_url'] = urlWithBust;
    await client.auth.updateUser(UserAttributes(data: meta));

    return urlWithBust;
  }

  static String? avatarUrlFromUser(User? user) =>
      user?.userMetadata?['avatar_url'] as String?;

  static String? displayNameFromUser(User? user) =>
      user?.userMetadata?['full_name'] as String? ??
      user?.userMetadata?['name'] as String?;

  /// Falls back to email local-part, then a generic label.
  static String resolvedDisplayName(User? user) {
    final n = displayNameFromUser(user);
    if (n != null && n.trim().isNotEmpty) return n.trim();
    final email = user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Account';
  }

  static String? emailFromUser(User? user) => user?.email;

  /// `user_metadata.currency` or default USD label.
  static String currencyLabelFromUser(User? user) {
    final raw = user?.userMetadata?['currency'] as String?;
    if (raw != null && raw.trim().isNotEmpty) return raw.trim();
    final code = user?.userMetadata?['currency_code'] as String?;
    if (code == 'EUR') return 'EUR (€)';
    if (code == 'GBP') return 'GBP (£)';
    return 'USD (\$)';
  }

  static bool notificationsEnabledFromUser(User? user) {
    final v = user?.userMetadata?['notifications_enabled'];
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() != 'false';
    return true;
  }

  static String passwordSectionSubtitleFromUser(User? user) {
    final hint = user?.userMetadata?['password_changed_hint'] as String?;
    if (hint != null && hint.trim().isNotEmpty) return hint.trim();
    final iso = user?.userMetadata?['password_updated_at'] as String?;
    if (iso != null) {
      try {
        final d = DateTime.parse(iso);
        return 'Last updated ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      } catch (_) {}
    }
    return 'Use Change Password to update';
  }
}
