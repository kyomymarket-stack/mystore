-- Consolidated Database Repair Script
-- This script ensures all tables exist with the correct columns and policies.

-- 1. Ensure the helper function for timestamps exists
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Ensure "products" table exists
CREATE TABLE IF NOT EXISTS "products" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "title" TEXT NOT NULL,
    "description" TEXT,
    "sku" TEXT,
    "barcode" TEXT,
    "price" DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    "compare_at_price" DECIMAL(10, 2),
    "cost_per_item" DECIMAL(10, 2),
    "stock_quantity" INTEGER NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'Draft', -- Active, Draft, Archived
    "category" TEXT,
    "vendor" TEXT,
    "tags" TEXT[],
    "image_url" TEXT,
    "weight" DECIMAL(10, 3),
    "weight_unit" TEXT DEFAULT 'kg',
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Ensure "orders" table exists with Algeria columns
CREATE TABLE IF NOT EXISTS "orders" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "order_number" TEXT UNIQUE NOT NULL,
    "customer_email" TEXT,
    "customer_name" TEXT NOT NULL,
    "customer_phone" TEXT,
    "wilaya" TEXT,
    "commune" TEXT,
    "total_amount" DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    "status" TEXT NOT NULL DEFAULT 'Pending',
    "payment_status" TEXT DEFAULT 'Unpaid',
    "shipping_address" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Force add columns if they are missing (for existing tables)
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "customer_phone" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "wilaya" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "commune" TEXT;

-- 4. Ensure "order_items" table exists (THE FIX)
CREATE TABLE IF NOT EXISTS "order_items" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "order_id" UUID REFERENCES "orders"("id") ON DELETE CASCADE,
    "product_id" UUID REFERENCES "products"("id"), 
    "product_title" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 1,
    "price" DECIMAL(10, 2) NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Enable RLS
ALTER TABLE "products" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "orders" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "order_items" ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies
-- Products
DROP POLICY IF EXISTS "Public Read Access" ON "products";
CREATE POLICY "Public Read Access" ON "products" FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated Admin Write Access" ON "products";
CREATE POLICY "Authenticated Admin Write Access" ON "products" FOR ALL USING (auth.role() = 'authenticated');

-- Orders
DROP POLICY IF EXISTS "Public can create orders" ON "orders";
CREATE POLICY "Public can create orders" ON "orders" FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Admins can do everything" ON "orders";
CREATE POLICY "Admins can do everything" ON "orders" FOR ALL USING (auth.role() = 'authenticated');

-- Order Items
DROP POLICY IF EXISTS "Public can create order items" ON "order_items";
CREATE POLICY "Public can create order items" ON "order_items" FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Admins can do everything items" ON "order_items";
CREATE POLICY "Admins can do everything items" ON "order_items" FOR ALL USING (auth.role() = 'authenticated');

-- 7. Triggers
DROP TRIGGER IF EXISTS update_products_updated_at ON "products";
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON "products"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_orders_updated_at ON "orders";
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON "orders"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
