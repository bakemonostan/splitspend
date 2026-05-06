# Supabase Storage — profile avatars (`avatars` bucket)

The app uploads profile images to Storage bucket **`avatars`** (see `AvatarStorageService.bucketId` and `lib/src/core/storage/avatar_storage_service.dart`).

## 1. Create the bucket

1. Supabase Dashboard → **Storage** → **New bucket**.
2. Name: **`avatars`** (must match `AvatarStorageService.bucketId`).
3. **Public bucket:** turn **ON** so `getPublicUrl()` works in the mobile app without signed URLs.

## 2. Policies (SQL)

Run in **SQL Editor** (adjust if you use a private bucket + signed URLs instead).

```sql
-- Allow authenticated users to upload/update/delete only objects named {their-uuid}/...
CREATE POLICY "Users upload own avatar"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND name LIKE auth.uid()::text || '/%'
);

CREATE POLICY "Users update own avatar"
ON storage.objects FOR UPDATE TO authenticated
USING (
  bucket_id = 'avatars'
  AND name LIKE auth.uid()::text || '/%'
);

CREATE POLICY "Users delete own avatar"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'avatars'
  AND name LIKE auth.uid()::text || '/%'
);

-- Public read (OK for a public bucket)
CREATE POLICY "Public read avatars"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'avatars');
```

## 3. App behavior

- Path: `{auth_user_id}/avatar.jpg` or `avatar.png` (from picked image MIME).
- After upload, **`user.userMetadata['avatar_url']`** is set to the public URL (with a cache-bust query param).

## 4. Troubleshooting

- **403 / RLS:** Policies missing or path not under `/{uuid}/`.
- **Bucket not found:** Name must be exactly `avatars` or change `bucketId` in code.
- **iOS / Android permissions:** See `Info.plist` and `AndroidManifest.xml` in this repo.
