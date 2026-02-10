-- Add payment_method to orders table
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "payment_method" TEXT DEFAULT 'cod';
