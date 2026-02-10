-- Database Schema Fix
-- Run this script in your Supabase SQL Editor to fix the "missing column" error.

-- 1. Ensure 'user_id' column exists in 'orders' table
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "user_id" UUID REFERENCES auth.users(id);

-- 2. Ensure 'user_id' column exists in 'order_items' table
ALTER TABLE "order_items" ADD COLUMN IF NOT EXISTS "user_id" UUID REFERENCES auth.users(id);

-- 3. Notify PostgREST to reload the schema cache (this fixes the "schema cache" error)
NOTIFY pgrst, 'reload config';
