-- Create user_invites table
CREATE TABLE IF NOT EXISTS user_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'USER',
  status TEXT DEFAULT 'PENDING', -- PENDING, ACCEPTED
  invited_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_invites ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Admins can view invites" ON user_invites
  FOR SELECT USING (
    auth.uid() IN (SELECT id FROM profiles WHERE role = 'ADMIN')
  );

CREATE POLICY "Admins can create invites" ON user_invites
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE role = 'ADMIN')
  );
