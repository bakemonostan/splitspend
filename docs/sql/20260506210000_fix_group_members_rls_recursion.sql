-- Fixes infinite recursion in RLS on group_members (Postgres ERROR infinite recursion).
-- Applied as migration fix_group_members_rls_recursion on splitspend-mvp.

CREATE OR REPLACE FUNCTION public.user_is_group_member(p_group_id uuid, p_user_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.group_members
    WHERE group_id = p_group_id AND user_id = p_user_id
  );
$$;

CREATE OR REPLACE FUNCTION public.user_is_group_owner(p_group_id uuid, p_user_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.group_members
    WHERE group_id = p_group_id AND user_id = p_user_id AND role = 'owner'
  );
$$;

CREATE OR REPLACE FUNCTION public.group_member_count(p_group_id uuid)
RETURNS integer
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT count(*)::integer FROM public.group_members WHERE group_id = p_group_id;
$$;

REVOKE ALL ON FUNCTION public.user_is_group_member(uuid, uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.user_is_group_owner(uuid, uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.group_member_count(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.user_is_group_member(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.user_is_group_owner(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.group_member_count(uuid) TO authenticated;

-- groups / group_members / expenses policies recreated — see migration on Supabase dashboard.
