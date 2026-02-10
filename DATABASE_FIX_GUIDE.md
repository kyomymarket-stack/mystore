# 🔧 Complete Database Schema Fix Guide

## ✅ Test Results Summary

### What's Working:
- ✅ **Orders Page** - Delivery company selection works perfectly
- ✅ **Landing Page Customizer** - Save functionality works 
- ✅ **Database Writes** - Data is being saved successfully

### ⚠️ Issues Found:
The following tables are **missing from your database** and causing console errors:
- ❌ `store_settings` - Needed for global store configuration
- ❌ `site_visits` - Needed for analytics
- ❌ `profiles` - Needed for user profiles

## 🚀 Complete Fix (Run This Now)

### Step 1: Open Supabase Dashboard
1. Go to https://supabase.com/dashboard
2. Select your project
3. Click **"SQL Editor"** in the left sidebar

### Step 2: Run the Master Fix Script
1. Open the file: **`MASTER_SCHEMA_FIX.sql`** (located in your project root)
2. **Copy ALL the SQL** from that file
3. **Paste it** into the Supabase SQL Editor
4. Click **"Run"** (or press Ctrl+Enter)

### Step 3: Wait for Completion
- You'll see several success messages
- Look for: "Schema migration completed successfully!"
- This confirms all tables and columns were created

### Step 4: Refresh Your Application
1. Go back to your application at http://localhost:5173
2. **Hard refresh** the page (Ctrl+Shift+R or Cmd+Shift+R)
3. Check the browser console - the schema errors should be gone!

## 📋 What This Fix Does

### Creates Missing Tables:
```sql
✓ store_settings  - For global store settings
✓ site_visits     - For visitor analytics  
✓ profiles        - For user profiles with roles
```

### Adds Missing Columns to `orders`:
```sql
✓ delivery_company  - Selected delivery partner
✓ notes            - Order notes
✓ shipping_type    - Home/Desk delivery
✓ wilaya           - Algerian province
✓ commune          - Algerian commune
✓ customer_phone   - Customer contact
✓ user_id          - Multi-tenancy support
```

### Adds Missing Columns to `products`:
```sql
✓ All offer_* columns (26 columns)
  - Colors, timers, toggles
  - FAQ and testimonials (JSONB)
  - Payment options
  - Layout controls
```

### Security Features:
```sql
✓ Row Level Security (RLS) enabled on all tables
✓ Proper access policies
✓ Public can view products/create orders
✓ Only owners can manage their data
```

### Automation:
```sql
✓ Auto-create profile on user signup
✓ Auto-create store_settings on user signup
✓ Auto-update timestamps on changes
```

## 🧪 Verification

After running the script, you can verify it worked by running these queries in Supabase:

```sql
-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('store_settings', 'site_visits', 'profiles');

-- Check orders columns
SELECT column_name 
FROM information_schema.columns
WHERE table_name = 'orders' AND column_name = 'delivery_company';

-- Check products columns  
SELECT count(*) as offer_columns 
FROM information_schema.columns
WHERE table_name = 'products' AND column_name LIKE 'offer_%';
```

Expected results:
- ✅ 3 tables found (store_settings, site_visits, profiles)
- ✅ delivery_company column exists
- ✅ 26 offer_* columns found

## 🐛 Troubleshooting

### If you still see errors after running the script:

1. **Check for SQL errors in the output**
   - Scroll through the SQL Editor output
   - Look for any lines starting with "ERROR"
   - Common fix: Your user might not have permissions

2. **Clear the schema cache**
   - In Supabase Dashboard, go to "Database" → "Extensions"
   - Find "postgrest" and toggle it off then on
   - Or just wait 1-2 minutes for auto-refresh

3. **Verify you're on the right project**
   - Check the project name in the Supabase dashboard
   - Make sure it matches your `.env` file

4. **Check browser console**
   - Open DevTools (F12)
   - Go to Console tab
   - If you still see PGRST205 errors, the table wasn't created

5. **Try refreshing the database connection**
   ```bash
   # In your terminal (optional)
   # This will restart your dev server
   # Press Ctrl+C then run:
   npm run dev
   ```

## 💡 Additional Notes

- **Safe to run multiple times** - Uses `IF NOT EXISTS` and `ON CONFLICT DO NOTHING`
- **No data loss** - Only adds new tables/columns, doesn't modify existing data
- **Production ready** - Includes RLS policies for security
- **Multi-tenant ready** - Adds `user_id` columns for data isolation

## 🎉 After Success

Once the fix is applied and you've refreshed:
- ✅ No more schema cache errors in console
- ✅ Landing Page Customizer fully functional
- ✅ Orders page works perfectly
- ✅ All features should work as expected
