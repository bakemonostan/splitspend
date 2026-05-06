# Groups — Supabase (create & join)

This app uses your existing **`groups`**, **`group_members`** tables and the **`join_group_by_invite_code`** RPC (see migrations on the project).

## Create group (client)

1. **`INSERT` into `public.groups`**  
   - `name`, `created_by` (= `auth.uid()`), `category` (`trip` \| `home` \| `event` \| `other`).  
   - Omit `invite_code`; a **trigger** assigns a unique `SPLIT-XXXX` value.

2. **`INSERT` into `public.group_members`**  
   - `group_id`, `user_id`, `role` = `'owner'`.

Implemented in `GroupsRepository.createGroup`.

## Optional cover image

Covers use the same **`avatars`** Storage bucket as profile photos, under paths:

`{auth.uid()}/group-covers/{group_id}.{jpg|png}`

Existing Storage policies allow objects whose key starts with the user’s UUID, so this path is valid. After upload, the client **`UPDATE`s `groups.cover_image_url`** with the public URL.

Implemented in `GroupsRepository.uploadGroupCoverIfPresent`.

## Join group (client)

Call RPC **`join_group_by_invite_code(p_code text)`** with the raw code (with or without `#`). It normalizes the string, resolves the group, and **`INSERT`s** `group_members` as `member` (`ON CONFLICT DO NOTHING`).

Implemented in `GroupsRepository.joinGroupByInviteCode`.

## RLS (important)

Policies must **not** query `group_members` inside another `group_members` policy — Postgres raises **“infinite recursion detected in policy for relation group_members”** and REST returns **500**.

Helpers **`user_is_group_member`**, **`user_is_group_owner`**, **`group_member_count`** (`SECURITY DEFINER`) implement membership checks without recursion. Migration: **`fix_group_members_rls_recursion`**.

## Where to see SQL

- Reference snapshot: `docs/sql/20260506120000_groups_category_invite_join.sql`  
- Dashboard: **Database → Migrations** on your Supabase project.
