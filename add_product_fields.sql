-- Add missing columns to products table
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "description_images" TEXT[] DEFAULT '{}';
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "sizes" TEXT[] DEFAULT '{}';
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "colors" TEXT[] DEFAULT '{}';

-- Add missing columns to order_items table (required for product variants)
ALTER TABLE "order_items" ADD COLUMN IF NOT EXISTS "size" TEXT;
ALTER TABLE "order_items" ADD COLUMN IF NOT EXISTS "color" TEXT;
