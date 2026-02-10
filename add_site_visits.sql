CREATE TABLE IF NOT EXISTS "site_visits" (
    "id" SERIAL PRIMARY KEY,
    "path" TEXT NOT NULL,
    "visitor_id" TEXT,
    "user_agent" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE "site_visits" ENABLE ROW LEVEL SECURITY;

-- Allow public insert to site_visits
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'site_visits' AND policyname = 'Allow public insert to site_visits'
    ) THEN
        CREATE POLICY "Allow public insert to site_visits" ON "site_visits"
            FOR INSERT WITH CHECK (true);
    END IF;
END
$$;

-- Allow admin select from site_visits
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'site_visits' AND policyname = 'Allow admin select from site_visits'
    ) THEN
        CREATE POLICY "Allow admin select from site_visits" ON "site_visits"
            FOR SELECT USING (true);
    END IF;
END
$$;
