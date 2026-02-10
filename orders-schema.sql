-- Order Management Schema
-- Supports both Guest Checkout and Authenticated Customers

CREATE TABLE IF NOT EXISTS "orders" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "order_number" TEXT UNIQUE NOT NULL,
    "customer_email" TEXT, -- Can be null if linked to a User, or filled for Guest
    "customer_name" TEXT NOT NULL,
    "total_amount" DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    "status" TEXT NOT NULL DEFAULT 'Pending', -- Pending, Paid, Shipped, Cancelled
    "payment_status" TEXT DEFAULT 'Unpaid',
    "shipping_address" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "order_items" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "order_id" UUID REFERENCES "orders"("id") ON DELETE CASCADE,
    "product_id" UUID REFERENCES "products"("id"), -- Link to product
    "product_title" TEXT NOT NULL, -- Snapshot of title in case product is deleted
    "quantity" INTEGER NOT NULL DEFAULT 1,
    "price" DECIMAL(10, 2) NOT NULL, -- Price at moment of purchase
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE "orders" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "order_items" ENABLE ROW LEVEL SECURITY;

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

-- Indexes
CREATE INDEX idx_orders_email ON "orders"("customer_email");
CREATE INDEX idx_orders_number ON "orders"("order_number");
CREATE INDEX idx_order_items_order ON "order_items"("order_id");
