-- ============================================================================
-- MASTER SCHEMA FIX FOR ENDER ONLINE STORE
-- This script fixes ALL missing tables and columns reported in console errors
-- Run this entire script in your Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- PART 1: CREATE MISSING TABLES
-- ============================================================================

-- 1.1 Create store_settings table
CREATE TABLE IF NOT EXISTS "store_settings" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id" UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    "settings" JSONB NOT NULL DEFAULT '{}'::jsonb,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 1.2 Create site_visits table
CREATE TABLE IF NOT EXISTS "site_visits" (
    "id" SERIAL PRIMARY KEY,
    "path" TEXT NOT NULL,
    "visitor_id" TEXT,
    "user_agent" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 1.3 Ensure profiles table exists
CREATE TABLE IF NOT EXISTS "profiles" (
    "id" UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
    "username" TEXT UNIQUE,
    "email_mapping" TEXT,
    "preferred_language" TEXT DEFAULT 'en',
    "mfa_enabled" BOOLEAN DEFAULT FALSE,
    "recovery_codes" TEXT[],
    "role" TEXT DEFAULT 'user',
    "avatar_url" TEXT,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- PART 2: ADD MISSING COLUMNS TO ORDERS TABLE
-- ============================================================================

ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "delivery_company" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "notes" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "shipping_type" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "wilaya" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "commune" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "customer_phone" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "user_id" UUID REFERENCES auth.users(id) DEFAULT auth.uid();

-- ============================================================================
-- PART 3: ADD MISSING COLUMNS TO PRODUCTS TABLE (Landing Page Customizer)
-- ============================================================================

ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "user_id" UUID REFERENCES auth.users(id) DEFAULT auth.uid();
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_enabled" BOOLEAN DEFAULT FALSE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_title" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_subtitle" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_discount" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_timer_hours" INTEGER DEFAULT 24;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_timer_minutes" INTEGER DEFAULT 0;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_bg_color" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_text_color" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_page_bg_color" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_btn_bg_color" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_btn_text_color" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_gallery" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_ai_insights" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_benefits" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_social_proof" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_success_message" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_checkout_title" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_form_subtitle" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_faq" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_faq" JSONB DEFAULT '[]'::jsonb;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_testimonials" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_testimonials" JSONB DEFAULT '[]'::jsonb;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_allow_cod" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_allow_card" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_social_links" BOOLEAN DEFAULT TRUE;

-- ============================================================================
-- PART 4: ADD MISSING COLUMNS TO OTHER TABLES
-- ============================================================================

ALTER TABLE "customers" ADD COLUMN IF NOT EXISTS "user_id" UUID REFERENCES auth.users(id) DEFAULT auth.uid();
ALTER TABLE "order_items" ADD COLUMN IF NOT EXISTS "user_id" UUID REFERENCES auth.users(id) DEFAULT auth.uid();

-- ============================================================================
-- PART 5: ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE "products" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "orders" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "order_items" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "customers" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "store_settings" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "site_visits" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "profiles" ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PART 6: CREATE RLS POLICIES
-- ============================================================================

-- Profiles Policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Public profiles are viewable by everyone') THEN
        CREATE POLICY "Public profiles are viewable by everyone" ON "profiles" FOR SELECT USING (true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can insert their own profile') THEN
        CREATE POLICY "Users can insert their own profile" ON "profiles" FOR INSERT WITH CHECK (auth.uid() = id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can update own profile') THEN
        CREATE POLICY "Users can update own profile" ON "profiles" FOR UPDATE USING (auth.uid() = id);
    END IF;
END $$;

-- Products Policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'products' AND policyname = 'Public can view any product') THEN
        CREATE POLICY "Public can view any product" ON "products" FOR SELECT USING (true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'products' AND policyname = 'Users can manage their own products') THEN
        CREATE POLICY "Users can manage their own products" ON "products" FOR ALL USING (auth.uid() = user_id);
    END IF;
END $$;

-- Orders Policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'orders' AND policyname = 'Public can create orders') THEN
        CREATE POLICY "Public can create orders" ON "orders" FOR INSERT WITH CHECK (true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'orders' AND policyname = 'Users can view their own orders') THEN
        CREATE POLICY "Users can view their own orders" ON "orders" FOR SELECT USING (auth.uid() = user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'orders' AND policyname = 'Users can update their own orders') THEN
        CREATE POLICY "Users can update their own orders" ON "orders" FOR UPDATE USING (auth.uid() = user_id);
    END IF;
END $$;

-- Order Items Policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'order_items' AND policyname = 'Public can create order items') THEN
        CREATE POLICY "Public can create order items" ON "order_items" FOR INSERT WITH CHECK (true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'order_items' AND policyname = 'Users can view their own order items') THEN
        CREATE POLICY "Users can view their own order items" ON "order_items" FOR SELECT USING (auth.uid() = user_id);
    END IF;
END $$;

-- Customers Policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'customers' AND policyname = 'Public can create customers') THEN
        CREATE POLICY "Public can create customers" ON "customers" FOR INSERT WITH CHECK (true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'customers' AND policyname = 'Users can view their own customers') THEN
        CREATE POLICY "Users can view their own customers" ON "customers" FOR SELECT USING (auth.uid() = user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'customers' AND policyname = 'Users can update their own customers') THEN
        CREATE POLICY "Users can update their own customers" ON "customers" FOR UPDATE USING (auth.uid() = user_id);
    END IF;
END $$;

-- Store Settings Policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'store_settings' AND policyname = 'Public can view store settings') THEN
        CREATE POLICY "Public can view store settings" ON "store_settings" FOR SELECT USING (true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'store_settings' AND policyname = 'Users can manage their own settings') THEN
        CREATE POLICY "Users can manage their own settings" ON "store_settings" FOR ALL USING (auth.uid() = user_id);
    END IF;
END $$;

-- Site Visits Policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'site_visits' AND policyname = 'Public can insert site visits') THEN
        CREATE POLICY "Public can insert site visits" ON "site_visits" FOR INSERT WITH CHECK (true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'site_visits' AND policyname = 'Anyone can view site visits') THEN
        CREATE POLICY "Anyone can view site visits" ON "site_visits" FOR SELECT USING (true);
    END IF;
END $$;

-- ============================================================================
-- PART 7: CREATE TRIGGERS AND FUNCTIONS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for store_settings
DROP TRIGGER IF EXISTS update_store_settings_updated_at ON "store_settings";
CREATE TRIGGER update_store_settings_updated_at 
    BEFORE UPDATE ON "store_settings"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger for profiles
DROP TRIGGER IF EXISTS update_profiles_updated_at ON "profiles";
CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON "profiles"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Create profile
  INSERT INTO public.profiles (id, username, email_mapping, preferred_language)
  VALUES (new.id, new.raw_user_meta_data->>'username', new.email, 'en')
  ON CONFLICT (id) DO NOTHING;
  
  -- Create default store settings
  INSERT INTO public.store_settings (user_id, settings)
  VALUES (new.id, '{
    "storeName": "My Store",
    "currency": "DZD",
    "themeMode": "system",
    "primaryColor": "#008060"
  }'::jsonb)
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create or replace trigger for new users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- PART 8: VERIFICATION QUERIES
-- ============================================================================

-- Verify orders table columns
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'orders' 
  AND column_name IN ('delivery_company', 'notes', 'shipping_type', 'wilaya', 'commune', 'customer_phone', 'user_id')
ORDER BY column_name;

-- Verify products table columns (offer_* columns)
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'products' 
  AND (column_name LIKE 'offer_%' OR column_name = 'user_id')
ORDER BY column_name;

-- Verify new tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('store_settings', 'site_visits', 'profiles')
ORDER BY table_name;

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Schema migration completed successfully!';
    RAISE NOTICE 'All missing tables and columns have been added.';
    RAISE NOTICE 'RLS policies and triggers are in place.';
    RAISE NOTICE 'Please refresh your application to clear any schema cache.';
END $$;
