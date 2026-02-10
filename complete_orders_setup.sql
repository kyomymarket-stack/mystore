-- Complete Orders and Order Items Schema with Algeria Support
-- Run this in Supabase SQL Editor

-- Create orders table
CREATE TABLE IF NOT EXISTS "orders" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "order_number" TEXT UNIQUE NOT NULL,
    "customer_email" TEXT,
    "customer_name" TEXT NOT NULL,
    "customer_phone" TEXT,
    "wilaya" TEXT,
    "commune" TEXT,
    "shipping_address" TEXT,
    "shipping_type" TEXT DEFAULT 'home',
    "total_amount" DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    "status" TEXT NOT NULL DEFAULT 'Pending',
    "payment_status" TEXT DEFAULT 'Unpaid',
    "payment_method" TEXT DEFAULT 'cod',
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS "order_items" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "order_id" UUID REFERENCES "orders"("id") ON DELETE CASCADE,
    "product_id" UUID REFERENCES "products"("id"),
    "product_title" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 1,
    "price" DECIMAL(10, 2) NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE "orders" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "order_items" ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Public can create orders" ON "orders";
DROP POLICY IF EXISTS "Public can create order items" ON "order_items";
DROP POLICY IF EXISTS "Admins can do everything" ON "orders";
DROP POLICY IF EXISTS "Admins can do everything items" ON "order_items";

-- Allow public to INSERT orders (Guest Checkout)
CREATE POLICY "Public can create orders" ON "orders"
    FOR INSERT WITH CHECK (true);

-- Allow public to INSERT order items
CREATE POLICY "Public can create order items" ON "order_items"
    FOR INSERT WITH CHECK (true);

-- Allow Admins to View/Edit All
CREATE POLICY "Admins can do everything" ON "orders"
    FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can do everything items" ON "order_items"
    FOR ALL USING (auth.role() = 'authenticated');

-- Create Indexes for performance
CREATE INDEX IF NOT EXISTS idx_orders_email ON "orders"("customer_email");
CREATE INDEX IF NOT EXISTS idx_orders_number ON "orders"("order_number");
CREATE INDEX IF NOT EXISTS idx_orders_status ON "orders"("status");
CREATE INDEX IF NOT EXISTS idx_order_items_order ON "order_items"("order_id");
CREATE INDEX IF NOT EXISTS idx_order_items_product ON "order_items"("product_id");
