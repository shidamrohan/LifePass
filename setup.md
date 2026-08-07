# Supabase Architecture Setup

## 1. Supabase Project Setup
1. Create a free project at [Supabase](https://supabase.com).
2. Go to **Project Settings -> API**.
3. You will need three values:
   - `Project URL`
   - `anon/public key` (Client key)
   - `service_role key` (Admin key - KEEP THIS SECRET!)

## 2. Environment Variables
Add these values to your `.env` file in the root folder:
```
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
GEMINI_API_KEY=your_gemini_key
```

## 3. Database Schema
Run the SQL script located at `supabase/schema.sql` in your Supabase project's **SQL Editor**. This will create all the necessary tables for profiles, medical reports, diseases, allergies, and medicines.

## 4. Storage Setup
In Supabase, go to **Storage** and create a new bucket named `reports`. Make sure to set the bucket to **Public** if you want the PDF URLs to be easily accessible by the AI service, or configure RLS policies accordingly.

## 5. Running the AI Backend
The FastAPI backend is now a pure AI microservice.
```bash
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## 6. Running the Flutter App
The Flutter app talks directly to Supabase for all auth and database operations.
```bash
flutter run
```

## 7. Running the Hospital Portal
The portal runs on plain React/JSX and uses the Supabase JS SDK.
```bash
cd hospital-portal
npm install
npm run dev
```
