-- Add shipping_type to orders and Customer tables
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "shipping_type" TEXT DEFAULT 'home';
ALTER TABLE "Customer" ADD COLUMN IF NOT EXISTS "shipping_type" TEXT DEFAULT 'home';
