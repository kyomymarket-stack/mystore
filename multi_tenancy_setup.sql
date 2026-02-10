-- Multi-Tenancy Setup (Refined)
-- This script adds user_id to all tables and sets up strict RLS policies for data isolation.

-- 1. Ensure the helper function for timestamps exists
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Add user_id to existing tables with defaults for automatic assignment
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "user_id" UUID REFERENCES auth.users(id) DEFAULT auth.uid();
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "user_id" UUID REFERENCES auth.users(id) DEFAULT auth.uid();
ALTER TABLE "order_items" ADD COLUMN IF NOT EXISTS "user_id" UUID REFERENCES auth.users(id) DEFAULT auth.uid();
ALTER TABLE "customers" ADD COLUMN IF NOT EXISTS "user_id" UUID REFERENCES auth.users(id) DEFAULT auth.uid();

-- 3. Create store_settings table
CREATE TABLE IF NOT EXISTS "store_settings" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id" UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    "settings" JSONB NOT NULL DEFAULT '{}'::jsonb,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on all tables
ALTER TABLE "products" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "orders" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "order_items" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "customers" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "store_settings" ENABLE ROW LEVEL SECURITY;

-- 4. Update RLS Policies for strict data isolation

-- Products: Everyone can see, only owner can edit
DROP POLICY IF EXISTS "Public can view any product" ON "products";
CREATE POLICY "Public can view any product" ON "products" FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can only access their own products" ON "products";
CREATE POLICY "Users can only access their own products" ON "products" FOR ALL USING (auth.uid() = user_id);

-- Orders: Everyone can create (checkout), only owner can view/manage
DROP POLICY IF EXISTS "Public can create orders" ON "orders";
CREATE POLICY "Public can create orders" ON "orders" FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can only access their own orders" ON "orders";
CREATE POLICY "Users can only access their own orders" ON "orders" FOR ALL USING (auth.uid() = user_id);

-- Order Items: Everyone can create (checkout), only owner can view/manage
DROP POLICY IF EXISTS "Public can create order items" ON "order_items";
CREATE POLICY "Public can create order items" ON "order_items" FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can only access their own order items" ON "order_items";
CREATE POLICY "Users can only access their own order items" ON "order_items" FOR ALL USING (auth.uid() = user_id);

-- Customers: Everyone can create (first checkout), only owner can view/manage
DROP POLICY IF EXISTS "Public can create customers" ON "customers";
CREATE POLICY "Public can create customers" ON "customers" FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can only access their own customers" ON "customers";
CREATE POLICY "Users can only access their own customers" ON "customers" FOR ALL USING (auth.uid() = user_id);

-- Store Settings: Everyone can view (branding), only owner can edit
DROP POLICY IF EXISTS "Public can view store settings" ON "store_settings";
CREATE POLICY "Public can view store settings" ON "store_settings" FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can only access their own settings" ON "store_settings";
CREATE POLICY "Users can only access their own settings" ON "store_settings" FOR ALL USING (auth.uid() = user_id);

-- 5. Triggers for updated_at
DROP TRIGGER IF EXISTS update_store_settings_updated_at ON "store_settings";
CREATE TRIGGER update_store_settings_updated_at BEFORE UPDATE ON "store_settings"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 6. Update handle_new_user trigger to include store_settings
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Create profile
  INSERT INTO public.profiles (id, username, email_mapping, preferred_language)
  VALUES (new.id, new.raw_user_meta_data->>'username', new.email, 'en');
  
  -- Create default store settings
  INSERT INTO public.store_settings (user_id, settings)
  VALUES (new.id, '{
    "storeName": "My Store",
    "currency": "USD",
    "themeMode": "system",
    "primaryColor": "#008060"
  }'::jsonb);
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
