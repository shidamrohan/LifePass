

# 🏥 LifePass: Emergency Medical Information & Health Identity Platform

LifePass is a secure, serverless medical profile system designed to provide first responders and hospital staff with instant access to a patient's critical health information during emergencies. By bridging the gap between personal mobile devices and hospital infrastructure through secure QR code scanning, LifePass ensures that life-saving medical context is always available when every second counts.

## ✨ Key Features

- **📱 Patient Mobile App (Flutter)**
  - Manage personal medical history (allergies, chronic diseases, current medications).
  - Upload raw medical reports (PDF/Images) directly from the device.
  - Generate highly secure, single-use dynamic QR codes for hospital check-ins.
  - Native lock-screen Push Notifications via Supabase WebSockets when a record is accessed.
  
- **🏥 Hospital Web Portal (React)**
  - Secure QR code scanner for instantly accessing patient profiles.
  - 3-Tier UI design prioritizing critical information (Blood Type, Allergies) first, hiding dense history.
  - Built-in audit logging and activity history for compliance and patient safety.

- **🤖 Background AI Worker (Python)**
  - Asynchronous background polling of the database.
  - Downloads patient-uploaded medical reports and processes them using Google's Gemini AI.
  - Automatically extracts diseases, allergies, and creates a risk summary, writing it back to the database instantly.

## 🏗 Architecture

LifePass uses a modern **100% Serverless Frontend Architecture** coupled with a decoupled asynchronous backend worker. 

1. **Database & Auth (Supabase)**: Handles all user authentication and raw data storage. Secured heavily via PostgreSQL Row Level Security (RLS) ensuring strict HIPAA-style access constraints.
2. **Real-Time WebSockets**: The Flutter app listens directly to the Supabase database via WebSockets. When the React app inserts an emergency audit log, the Flutter app instantly triggers a local Push Notification.
3. **Asynchronous Decoupling**: The mobile app and the hospital portal never communicate with the Python AI worker directly over a network, ensuring the system remains highly available regardless of local network constraints.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.12+)
- Node.js (v18+)
- Python (3.10+)
- Supabase Project & Gemini API Key

### 1. Database Setup
Execute `supabase/schema.sql` and `alter_reports.sql` in your Supabase SQL Editor to generate the necessary tables, storage buckets, and RLS policies.

### 2. Patient App (Flutter)
1. Navigate to the root directory.
2. Create a `.env` file containing `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
3. Run `flutter pub get`.
4. Run `flutter run`.

### 3. Hospital Portal (React)
1. Navigate to `cd hospital-portal`.
2. Create a `.env` file containing your Supabase credentials.
3. Run `npm install`.
4. Run `npm run dev`.

### 4. Background AI Worker (Python)
1. Navigate to `cd backend`.
2. Create a `.env` file containing your Supabase Service Role Key and `GEMINI_API_KEY`.
3. Run `pip install -r requirements.txt`.
4. Run `python -m app.worker`.

## Test Credentials

Here are the sample test credentials you can use across the system:



### 🛡️ System Admin (Web Portal)
- **Email**: `admin@lifepass.com` 
- **Password**: `Password123`



