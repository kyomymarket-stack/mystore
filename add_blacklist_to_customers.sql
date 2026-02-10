-- Migration to add blacklist-related columns to customers table

ALTER TABLE customers ADD COLUMN IF NOT EXISTS is_blacklisted BOOLEAN DEFAULT FALSE;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS cancelled_orders_count INTEGER DEFAULT 0;

-- Optional: Index for filtering blacklisted customers
CREATE INDEX IF NOT EXISTS idx_customers_is_blacklisted ON customers(is_blacklisted);
