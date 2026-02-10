# Database Setup

To make the application fully functional, you need to create the necessary tables in Supabase.

### 1. Products (Required)
Allows you to manage inventory.
1. Open SQL Editor in Supabase.
2. Run content of `products-schema.sql`.

### 2. Orders & Storefront (Required for Guest Checkout)
Allows customers to place orders without signing in.
1. Open SQL Editor in Supabase.
2. Run content of `orders-schema.sql`.

### 3. Customers (Required for Customer Management)
Allows you to manage customer information and track their activity.
1. Open SQL Editor in Supabase.
2. Run content of `customers-schema.sql`.

### 4. Kanban Board (Optional)
Enables the kanban board feature for order management.
1. Open SQL Editor in Supabase.
2. Run content of `kanban-schema.sql`.

---

### Troubleshooting: Missing Tables Error
If you see an error like "Could not find the table 'public.order_items' in the schema cache":
1. Open SQL Editor in Supabase.
2. Run the content of `fix_database.sql`.
   This script will ensure all tables, columns (including Algeria-specific ones), and RLS policies are correctly set up.
3. Refresh your browser.
