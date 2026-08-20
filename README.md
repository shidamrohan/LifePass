🏥 LifePass: Emergency Medical Information & Health Identity Platform

LifePass is a secure digital health identity platform designed to provide authorized hospital staff with quick access to a patient's critical medical information during emergencies. Using QR-based identification, cloud-based medical records, and AI-assisted medical report analysis, LifePass helps make essential health information available when timely decisions matter.

✨ Key Features

📱 Patient Mobile App | Flutter

  Manage personal and emergency medical information.
  Store allergies, chronic diseases, blood group, and current medications.
  Upload medical reports and documents.
  Generate a QR code linked to the patient's emergency health profile.
  Receive updates when medical information is accessed or updated.

🏥 Hospital Web Portal | React

  Secure hospital and staff access.
  Scan patient QR codes to retrieve emergency health information.
  View critical information first, including blood group, allergies, chronic conditions, and medications.
  Access AI-generated medical summaries.
  View medical reports and patient history.
  Maintain access and activity logs.

🤖 AI Processing Service | Python

  Processes uploaded medical reports asynchronously.
  Retrieves reports from secure cloud storage.
  Uses Google Gemini AI to analyze medical information.
  Extracts important information such as diseases, allergies, medications, and medical risks.
  Generates a structured emergency medical summary.
  Stores processed information back in the Supabase database.

## 🏗 System Architecture

LifePass follows a cloud-based, database-centric architecture with a separate AI processing service.

Supabase

Supabase manages:

* User Authentication
* PostgreSQL Database
* Medical Record Storage
* Row Level Security
* Real-time Updates

Patient Application

The Flutter application communicates with Supabase for:

* Registration and Login
* Managing Health Profiles
* Uploading Medical Reports
* Generating and accessing QR codes
* Receiving real-time updates

Hospital Portal

The React-based hospital portal allows authorized hospital personnel to:

  Authenticate securely
  Scan patient QR codes
  Fetch emergency medical information
  Access AI-generated summaries
  View patient medical reports
  Record access activity

### AI Processing Service

The Python service operates independently from the frontend applications:

```text
Medical Report Upload
        ↓
Supabase Storage
        ↓
Python AI Processing Service
        ↓
Google Gemini AI
        ↓
Extract Medical Information
        ↓
Generate Emergency Summary
        ↓
Supabase PostgreSQL
```

This separation ensures that patient and hospital applications can continue accessing available medical data independently of the AI processing workflow.

🛠 Tech Stack

Flutter (Dart) | React.js | Python | FastAPI | Supabase PostgreSQL | Supabase Auth | Supabase Storage | Supabase Realtime | Google Gemini API | OCR | REST APIs | QR Code**

🚀 Getting Started

Prerequisites

  Flutter SDK 3.12+
  Node.js 18+
  Python 3.10+
  Supabase Project
  Google Gemini API Key

1. Database Setup

1. Create a Supabase project.
2. Open the Supabase SQL Editor.
3. Execute the required database schema files:

```text
supabase/schema.sql
alter_reports.sql
```

This creates the required database tables, storage configuration, and security policies.

2. Patient App | Flutter

Navigate to the project root.

Create a `.env` file:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Run:

```bash
flutter pub get
flutter run
```

3. Hospital Portal | React

Navigate to the hospital portal:

```bash
cd hospital-portal
```

Create the required `.env` file with your Supabase configuration.

Run:

```bash
npm install
npm run dev
```

4. AI Processing Service | Python

Navigate to the backend directory:

```bash
cd backend
```

Create a `.env` file:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
GEMINI_API_KEY=your_gemini_api_key
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Start the AI processing service:

```bash
python -m app.worker
```

🔐 Security

LifePass uses:

Supabase Authentication
  Role-based access control
  PostgreSQL Row Level Security policies
  Secure cloud storage for medical reports
  Authenticated access to hospital resources
  Audit logging for patient record access

> Important: API keys and service role keys must never be committed to GitHub. Store sensitive credentials in `.env` files and add them to `.gitignore`.

🧪 Test Credentials

🛡️ System Admin | Web Portal

Email: `admin@lifepass.com`
Password: `Password123`

> These credentials must exist in Supabase Authentication and have the appropriate admin role configured in the database.

👥 Team

Rohan Shidam
LinkedIn: [Rohan Shidam on LinkedIn](https://www.linkedin.com/in/rohan-shidam-487188399/?utm_source=chatgpt.com)

### Fija Shaikh

LinkedIn: [Fija Shaikh on LinkedIn](https://www.linkedin.com/in/fija-shaikh/?utm_source=chatgpt.com)

GitHub: [Fija Shaikh on GitHub](https://github.com/fija-shaikh?utm_source=chatgpt.com)

📌 Project Goal

LifePass aims to reduce delays caused by unavailable medical history during emergencies by providing authorized healthcare personnel with rapid access to critical patient information through a secure digital health identity system.
