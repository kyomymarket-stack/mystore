-- Products Schema matching Shopify-like fields
CREATE TABLE "products" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "title" TEXT NOT NULL,
    "description" TEXT,
    "sku" TEXT,
    "barcode" TEXT,
    "price" DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    "compare_at_price" DECIMAL(10, 2),
    "cost_per_item" DECIMAL(10, 2),
    "stock_quantity" INTEGER NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'Draft', -- Active, Draft, Archived
    "category" TEXT,
    "vendor" TEXT,
    "tags" TEXT[],
    "image_url" TEXT,
    "weight" DECIMAL(10, 3),
    "weight_unit" TEXT DEFAULT 'kg',
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE "products" ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Public Read Access" ON "products"
    FOR SELECT USING (true);

CREATE POLICY "Authenticated Admin Write Access" ON "products"
    FOR ALL USING (auth.role() = 'authenticated');

-- Trigger for updated_at
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON "products"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Indexes
CREATE INDEX idx_products_status ON "products"("status");
CREATE INDEX idx_products_category ON "products"("category");
CREATE INDEX idx_products_vendor ON "products"("vendor");
