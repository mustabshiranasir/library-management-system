-- ============================================================================
-- 1. PROFILES & AUTHENTICATION (Hooked into Supabase Auth)
-- ============================================================================
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'member' CHECK (role IN ('admin', 'member', 'staff')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trigger to automatically create a profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, role)
    VALUES (new.id, new.email, 'member');
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ============================================================================
-- 2. UPDATE EXISTING TABLES (Add user_id linking)
-- ============================================================================
ALTER TABLE members ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE staff ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;


-- ============================================================================
-- 3. ROW LEVEL SECURITY (RLS)
-- ============================================================================
-- Ensure RLS is enabled on all core tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE loans ENABLE ROW LEVEL SECURITY;
ALTER TABLE fines ENABLE ROW LEVEL SECURITY;
ALTER TABLE requests ENABLE ROW LEVEL SECURITY;

-- Utility function to check if the current user is an admin
CREATE OR REPLACE FUNCTION public.is_admin() RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER;


-- ── DROP OLD POLICIES ──
-- This removes the old "Allow all actions for anon" or previously created policies
DO $$ 
DECLARE
  t text;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
    EXECUTE format('DROP POLICY IF EXISTS "Allow all actions for anon" ON %I;', t);
  END LOOP;
END $$;

DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Admins can read all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update profiles" ON profiles;
DROP POLICY IF EXISTS "Anyone can read books" ON books;
DROP POLICY IF EXISTS "Admins can manage books" ON books;
DROP POLICY IF EXISTS "Anyone can read inventory" ON inventory;
DROP POLICY IF EXISTS "Admins can manage inventory" ON inventory;
DROP POLICY IF EXISTS "Members can read own record" ON members;
DROP POLICY IF EXISTS "Admins can manage members" ON members;
DROP POLICY IF EXISTS "Admins can manage staff" ON staff;
DROP POLICY IF EXISTS "Staff can read own record" ON staff;
DROP POLICY IF EXISTS "Members can see own loans" ON loans;
DROP POLICY IF EXISTS "Admins can manage loans" ON loans;
DROP POLICY IF EXISTS "Members can see own fines" ON fines;
DROP POLICY IF EXISTS "Admins can manage fines" ON fines;
DROP POLICY IF EXISTS "Members can see own requests" ON requests;
DROP POLICY IF EXISTS "Members can create own requests" ON requests;
DROP POLICY IF EXISTS "Admins can manage requests" ON requests;

-- ── CREATE NEW GRANULAR POLICIES ──
-- PROFILES: Users can read their own profile. Admins can read all.
CREATE POLICY "Users can read own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Admins can read all profiles" ON profiles FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins can update profiles" ON profiles FOR UPDATE USING (public.is_admin());

-- BOOKS: Anyone can read books. Only admins can insert/update/delete.
CREATE POLICY "Anyone can read books" ON books FOR SELECT USING (true);
CREATE POLICY "Admins can manage books" ON books FOR ALL USING (public.is_admin());

-- INVENTORY: Anyone can read inventory. Only admins can insert/update/delete.
CREATE POLICY "Anyone can read inventory" ON inventory FOR SELECT USING (true);
CREATE POLICY "Admins can manage inventory" ON inventory FOR ALL USING (public.is_admin());

-- MEMBERS: Members can read their own member record. Admins have full access.
CREATE POLICY "Members can read own record" ON members FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Admins can manage members" ON members FOR ALL USING (public.is_admin());

-- STAFF: Admins have full access.
CREATE POLICY "Admins can manage staff" ON staff FOR ALL USING (public.is_admin());
CREATE POLICY "Staff can read own record" ON staff FOR SELECT USING (user_id = auth.uid());

-- LOANS: Members can see their own loans. Admins have full access.
CREATE POLICY "Members can see own loans" ON loans FOR SELECT USING (
  member_id IN (SELECT member_id FROM members WHERE user_id = auth.uid())
);
CREATE POLICY "Admins can manage loans" ON loans FOR ALL USING (public.is_admin());

-- FINES: Members can see their own fines. Admins have full access.
CREATE POLICY "Members can see own fines" ON fines FOR SELECT USING (
  member_id IN (SELECT member_id FROM members WHERE user_id = auth.uid())
);
CREATE POLICY "Admins can manage fines" ON fines FOR ALL USING (public.is_admin());

-- REQUESTS: Members can see and create their own requests. Admins have full access.
CREATE POLICY "Members can see own requests" ON requests FOR SELECT USING (
  member_id IN (SELECT member_id FROM members WHERE user_id = auth.uid())
);
CREATE POLICY "Members can create own requests" ON requests FOR INSERT WITH CHECK (
  member_id IN (SELECT member_id FROM members WHERE user_id = auth.uid())
);
CREATE POLICY "Admins can manage requests" ON requests FOR ALL USING (public.is_admin());


-- ============================================================================
-- 4. REALTIME BROADCASTING
-- ============================================================================
-- Explicitly enable Realtime for these tables so the frontend UI auto-updates
-- We use a DO block to safely add tables to the publication without throwing errors if they're already added
DO $$
BEGIN
  -- Create publication if it doesn't exist (Supabase usually creates it by default)
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    CREATE PUBLICATION supabase_realtime;
  END IF;

  -- Add tables safely
  ALTER PUBLICATION supabase_realtime ADD TABLE books;
  ALTER PUBLICATION supabase_realtime ADD TABLE members;
  ALTER PUBLICATION supabase_realtime ADD TABLE loans;
  ALTER PUBLICATION supabase_realtime ADD TABLE fines;
  ALTER PUBLICATION supabase_realtime ADD TABLE requests;
  ALTER PUBLICATION supabase_realtime ADD TABLE inventory;
  ALTER PUBLICATION supabase_realtime ADD TABLE staff;
EXCEPTION WHEN OTHERS THEN
  -- Ignore if tables are already in publication
END;
$$;
