-- Add role column to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'USER';

-- Update RLS policies to allow admins to view all profiles
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON profiles;
CREATE POLICY "Public profiles are viewable by everyone." ON profiles
    FOR SELECT USING (true);

-- Allow admins to update roles (simplified for now, ideally restrict to admins only)
CREATE POLICY "Admins can update profiles" ON profiles
    FOR UPDATE USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'ADMIN'));
