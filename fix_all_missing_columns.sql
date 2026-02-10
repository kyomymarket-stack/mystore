-- Add missing columns to orders table for delivery company integration
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "delivery_company" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "notes" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "shipping_type" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "wilaya" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "commune" TEXT;
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "customer_phone" TEXT;

-- Add offer-related columns to products table for Landing Page Customizer
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_enabled" BOOLEAN DEFAULT FALSE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_title" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_subtitle" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_discount" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_timer_hours" INTEGER DEFAULT 24;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_timer_minutes" INTEGER DEFAULT 0;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_bg_color" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_text_color" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_page_bg_color" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_btn_bg_color" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_btn_text_color" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_gallery" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_ai_insights" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_benefits" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_social_proof" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_success_message" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_checkout_title" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_form_subtitle" TEXT;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_faq" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_faq" JSONB DEFAULT '[]'::jsonb;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_show_testimonials" BOOLEAN DEFAULT TRUE;
ALTER TABLE "products" ADD COLUMN IF NOT EXISTS "offer_testimonials" JSONB DEFAULT '[]'::jsonb;
