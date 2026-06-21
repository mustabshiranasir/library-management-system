-- ============================================================================
-- 1. PROFILES & AUTHENTICATION (Hooked into Supabase Auth)
-- ============================================================================
CREATE TABLE profiles (
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

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ============================================================================
-- 2. LIBRARY SYSTEM ENUMS
-- ============================================================================
CREATE TYPE membership_type_enum AS ENUM ('Student', 'Faculty', 'Staff', 'Guest');
CREATE TYPE payment_status_enum AS ENUM ('Paid', 'Unpaid');
CREATE TYPE request_status_enum AS ENUM ('Pending', 'Approved', 'Rejected', 'Fulfilled');


-- ============================================================================
-- 3. CORE LIBRARY TABLES
-- ============================================================================
CREATE TABLE books (
    book_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    edition VARCHAR(50),
    isbn VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE members (
    member_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Link library member to Supabase auth user
    name VARCHAR(150) NOT NULL,
    membership_type membership_type_enum NOT NULL DEFAULT 'Student'
);

CREATE TABLE staff (
    staff_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    name VARCHAR(150) NOT NULL,
    role VARCHAR(100) NOT NULL
);

CREATE TABLE inventory (
    inventory_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    book_id INT NOT NULL UNIQUE REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    title VARCHAR(255) NOT NULL,
    shelf_location VARCHAR(50),
    stock_count INT NOT NULL DEFAULT 0 CHECK (stock_count >= 0),
    total_count INT NOT NULL DEFAULT 0 CHECK (total_count >= 0)
);

CREATE TABLE loans (
    loan_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT NOT NULL REFERENCES members(member_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    issued_book_id INT NOT NULL REFERENCES books(book_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL
);

CREATE TABLE fines (
    fine_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT NOT NULL REFERENCES members(member_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    overdue_book_id INT NOT NULL REFERENCES books(book_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    overdue_days INT NOT NULL CHECK (overdue_days > 0),
    fine_amount DECIMAL(8,2) NOT NULL CHECK (fine_amount >= 0),
    payment_status payment_status_enum NOT NULL DEFAULT 'Unpaid'
);

CREATE TABLE requests (
    request_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT NOT NULL REFERENCES members(member_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    requested_book_id INT NOT NULL REFERENCES books(book_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    request_date DATE NOT NULL DEFAULT CURRENT_DATE,
    request_status request_status_enum NOT NULL DEFAULT 'Pending'
);


-- ============================================================================
-- 4. ROW LEVEL SECURITY (RLS)
-- ============================================================================
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
-- 5. REALTIME BROADCASTING
-- ============================================================================
-- Explicitly enable Realtime for these tables so the frontend UI auto-updates
ALTER PUBLICATION supabase_realtime ADD TABLE books;
ALTER PUBLICATION supabase_realtime ADD TABLE members;
ALTER PUBLICATION supabase_realtime ADD TABLE loans;
ALTER PUBLICATION supabase_realtime ADD TABLE fines;
ALTER PUBLICATION supabase_realtime ADD TABLE requests;
ALTER PUBLICATION supabase_realtime ADD TABLE inventory;
ALTER PUBLICATION supabase_realtime ADD TABLE staff;
