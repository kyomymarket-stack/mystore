-- Add delivery_company and notes to orders table
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "delivery_company" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "notes" TEXT;
