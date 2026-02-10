-- Add Shopify-like options and variants columns to products table
ALTER TABLE "products" 
ADD COLUMN IF NOT EXISTS "options" JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS "variants" JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS "has_variants" BOOLEAN DEFAULT false;

-- Update existing products to have default empty arrays for options/variants if they don't already
UPDATE "products" SET "options" = '[]'::jsonb WHERE "options" IS NULL;
UPDATE "products" SET "variants" = '[]'::jsonb WHERE "variants" IS NULL;
UPDATE "products" SET "has_variants" = false WHERE "has_variants" IS NULL;
