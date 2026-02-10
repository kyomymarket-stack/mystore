-- Kanban Board Schema for CRM
-- Supports Leads, Orders, and Tickets with drag & drop positioning

-- Lead entity for Kanban
CREATE TABLE IF NOT EXISTS "leads" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "title" TEXT NOT NULL,
    "company" TEXT,
    "contact_name" TEXT,
    "email" TEXT,
    "phone" TEXT,
    "value" DECIMAL(10, 2),
    "status" TEXT NOT NULL DEFAULT 'new',
    "position" INTEGER NOT NULL DEFAULT 0,
    "user_id" UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Update existing Order table to ensure position and status
-- (Assuming Order table exists from schema.sql)
ALTER TABLE "Order" 
ADD COLUMN IF NOT EXISTS "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Update existing Ticket table
-- (Assuming Ticket table exists from schema.sql)

-- Kanban Column Configuration
CREATE TABLE IF NOT EXISTS "kanban_columns" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "entity_type" TEXT NOT NULL, -- 'lead', 'order', 'ticket'
    "title" TEXT NOT NULL,
    "status_value" TEXT NOT NULL, -- The actual status value to match
    "position" INTEGER NOT NULL,
    "color" TEXT DEFAULT '#6B7280', -- Subtle color indicator
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_type, status_value)
);

-- Enable Row Level Security
ALTER TABLE "leads" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "kanban_columns" ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Leads
CREATE POLICY "Users can view all leads" ON "leads"
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert leads" ON "leads"
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update leads" ON "leads"
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Users can delete leads" ON "leads"
    FOR DELETE USING (auth.role() = 'authenticated');

-- RLS Policies for Kanban Columns
CREATE POLICY "Anyone can view kanban columns" ON "kanban_columns"
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Only admins can modify kanban columns" ON "kanban_columns"
    FOR ALL USING (auth.role() = 'authenticated');

-- Insert default columns for Leads
INSERT INTO "kanban_columns" ("entity_type", "title", "status_value", "position", "color") VALUES
('lead', 'New', 'new', 0, '#3B82F6'),
('lead', 'Contacted', 'contacted', 1, '#8B5CF6'),
('lead', 'Qualified', 'qualified', 2, '#F59E0B'),
('lead', 'Proposal', 'proposal', 3, '#10B981'),
('lead', 'Won', 'won', 4, '#22C55E'),
('lead', 'Lost', 'lost', 5, '#EF4444')
ON CONFLICT (entity_type, status_value) DO NOTHING;

-- Insert default columns for Orders
INSERT INTO "kanban_columns" ("entity_type", "title", "status_value", "position", "color") VALUES
('order', 'Pending', 'pending', 0, '#F59E0B'),
('order', 'Processing', 'processing', 1, '#3B82F6'),
('order', 'Shipped', 'shipped', 2, '#8B5CF6'),
('order', 'Delivered', 'delivered', 3, '#10B981'),
('order', 'Cancelled', 'cancelled', 4, '#EF4444')
ON CONFLICT (entity_type, status_value) DO NOTHING;

-- Insert default columns for Tickets
INSERT INTO "kanban_columns" ("entity_type", "title", "status_value", "position", "color") VALUES
('ticket', 'Open', 'open', 0, '#3B82F6'),
('ticket', 'In Progress', 'in_progress', 1, '#F59E0B'),
('ticket', 'Waiting', 'waiting', 2, '#8B5CF6'),
('ticket', 'Resolved', 'resolved', 3, '#10B981'),
('ticket', 'Closed', 'closed', 4, '#6B7280')
ON CONFLICT (entity_type, status_value) DO NOTHING;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_leads_updated_at BEFORE UPDATE ON "leads"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_kanban_columns_updated_at BEFORE UPDATE ON "kanban_columns"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_leads_status ON "leads"("status");
CREATE INDEX IF NOT EXISTS idx_leads_position ON "leads"("position");
CREATE INDEX IF NOT EXISTS idx_leads_user_id ON "leads"("user_id");
CREATE INDEX IF NOT EXISTS idx_kanban_columns_entity_type ON "kanban_columns"("entity_type");
