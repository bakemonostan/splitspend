-- Reference copy of migration applied on project splitspend-mvp (groups UI + join-by-code).
-- Source of truth is Supabase migration history; keep for repo/searchability.

ALTER TABLE public.groups
  ADD COLUMN IF NOT EXISTS category text NOT NULL DEFAULT 'other'
    CHECK (category IN ('trip', 'home', 'event', 'other')),
  ADD COLUMN IF NOT EXISTS cover_image_url text;

ALTER TABLE public.groups ALTER COLUMN invite_code DROP NOT NULL;

CREATE OR REPLACE FUNCTION public.generate_invite_code()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  chars text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  suffix text := '';
  i int;
  pos int;
BEGIN
  FOR i IN 1..4 LOOP
    pos := 1 + floor(random() * length(chars))::int;
    IF pos > length(chars) THEN pos := length(chars); END IF;
    suffix := suffix || substr(chars, pos, 1);
  END LOOP;
  RETURN 'SPLIT-' || suffix;
END;
$$;

CREATE OR REPLACE FUNCTION public.groups_set_invite_code()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.invite_code IS NULL OR btrim(COALESCE(NEW.invite_code, '')) = '' THEN
    LOOP
      NEW.invite_code := public.generate_invite_code();
      EXIT WHEN NOT EXISTS (
        SELECT 1 FROM public.groups g WHERE g.invite_code = NEW.invite_code
      );
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_groups_set_invite_code ON public.groups;
CREATE TRIGGER trg_groups_set_invite_code
  BEFORE INSERT ON public.groups
  FOR EACH ROW
  EXECUTE FUNCTION public.groups_set_invite_code();

DROP POLICY IF EXISTS group_members_insert_creator_owner ON public.group_members;
CREATE POLICY group_members_insert_creator_owner ON public.group_members
FOR INSERT TO public
WITH CHECK (
  role = 'owner'
  AND user_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM public.groups g
    WHERE g.id = group_members.group_id AND g.created_by = auth.uid()
  )
  AND NOT EXISTS (
    SELECT 1 FROM public.group_members gm WHERE gm.group_id = group_members.group_id
  )
);

CREATE OR REPLACE FUNCTION public.join_group_by_invite_code(p_code text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_group_id uuid;
  v_norm text;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  v_norm := upper(regexp_replace(trim(p_code), '^#', ''));
  SELECT id INTO v_group_id FROM public.groups WHERE invite_code = v_norm;
  IF v_group_id IS NULL THEN
    RAISE EXCEPTION 'Invalid invite code';
  END IF;
  INSERT INTO public.group_members (group_id, user_id, role)
  VALUES (v_group_id, auth.uid(), 'member')
  ON CONFLICT (group_id, user_id) DO NOTHING;
  RETURN v_group_id;
END;
$$;

REVOKE ALL ON FUNCTION public.join_group_by_invite_code(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.join_group_by_invite_code(text) TO authenticated;

REVOKE ALL ON FUNCTION public.generate_invite_code() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.generate_invite_code() TO service_role;
