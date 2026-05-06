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

  static String? emailFromUser(User? user) => user?.email;
}
