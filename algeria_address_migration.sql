-- Add columns for Algeria-specific address and contact info
-- Note: Using lowercase "orders" as it is the primary table used in the React components
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "customer_phone" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "wilaya" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "commune" TEXT;

-- Update Customer table (case-sensitive "Customer" as per schema.sql)
ALTER TABLE "Customer" ADD COLUMN IF NOT EXISTS "wilaya" TEXT;
ALTER TABLE "Customer" ADD COLUMN IF NOT EXISTS "commune" TEXT;
