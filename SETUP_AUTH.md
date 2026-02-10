# Supabase Auth Setup Guide

## 1. Environment Setup
Your environment is ready with Node.js and Docker installed.
The project has been built successfully using `npm run build`.

## 2. Supabase Configuration
The application is configured to use the Supabase project defined in `.env`:
- URL: `https://pfnjaqfkgjmupzpaivnx.supabase.co`

## 3. Database Schema
You **MUST** apply the database schema to your Supabase project for Authentication and Profiles to work correctly.
The schema includes:
- `profiles` table (linked to `auth.users`).
- RLS policies for security.
- Triggers to automatically create a profile on Signup.
- `recovery_codes` for MFA.

**Action:**
1. Go to your [Supabase Dashboard](https://supabase.com/dashboard/project/pfnjaqfkgjmupzpaivnx/editor/sql).
2. Open the SQL Editor.
3. Copy the contents of `schema.sql` (located in the project root).
4. Run the SQL script.

## 4. Running the Application
To start the development server:

```bash
npm run dev
```

The app will be available at `http://localhost:5173`.

## 5. Features Implemented
- **Sign Up**: Creates a new user and automatically generates a Profile.
- **Sign In**: Supports Email or Username login.
- **MFA**: TOTP 2FA enrollment and verification + Recovery Codes.
- **Forgot Password**: Password reset flow.
- **Protected Routes**: Dashboard and Settings are secured.
