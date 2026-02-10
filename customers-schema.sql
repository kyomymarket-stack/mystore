-- Customers Table Schema
-- Matches the frontend Customer interface

CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    status TEXT NOT NULL DEFAULT 'New', -- VIP, Repeat, Inactive, New
    ltv DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    orders_count INTEGER NOT NULL DEFAULT 0,
    location TEXT,
    address TEXT,
    notes TEXT,
    last_order_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Customers
CREATE POLICY "Authenticated users can view customers" ON customers
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert customers" ON customers
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update customers" ON customers
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete customers" ON customers
    FOR DELETE USING (auth.role() = 'authenticated');

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_customers_status ON customers(status);
CREATE INDEX IF NOT EXISTS idx_customers_created_at ON customers(created_at DESC);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_customers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER customers_updated_at_trigger
    BEFORE UPDATE ON customers
    FOR EACH ROW
    EXECUTE FUNCTION update_customers_updated_at();

-- Insert some sample data (optional, for testing)
INSERT INTO customers (full_name, email, phone, status, ltv, orders_count, location, last_order_at)
VALUES
    ('John Doe', 'john@example.com', '+1 234 567 8900', 'VIP', 1250.50, 12, 'New York, US', '2024-01-20'),
    ('Jane Smith', 'jane@smith.com', '+1 234 567 8901', 'Repeat', 450.00, 4, 'Toronto, CA', '2024-01-15'),
    ('Ahmed Hassan', 'ahmed@demo.ar', '+966 50 123 4567', 'New', 0, 0, 'Riyadh, SA', NULL)
ON CONFLICT (email) DO NOTHING;
