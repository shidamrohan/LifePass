# LifePass Backend - Quick Start Guide

## Setup (5 minutes)

### 1. Create Virtual Environment
```bash
cd backend
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # Mac/Linux
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Configure Database

**Option A: PostgreSQL (Recommended for production)**
```bash
# Install PostgreSQL (if not already)
# Create database
createdb lifepass

# Update .env
DATABASE_URL=postgresql://postgres:password@localhost:5432/lifepass
```

**Option B: SQLite (For quick testing)**
```bash
# Update .env
DATABASE_URL=sqlite:///./lifepass.db
```

### 4. Get API Keys

Add these to `.env`:
- **GEMINI_API_KEY** - From [Google AI Studio](https://makersuite.google.com/app/apikey)
- **CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET** - From [Cloudinary](https://cloudinary.com)
- **QR_CIPHER_KEY** - Optional (auto-generated if not provided)

### 5. Run Server
```bash
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API available at: **http://localhost:8000**
- API Docs: http://localhost:8000/docs (Swagger UI)
- ReDoc: http://localhost:8000/redoc

---

## Testing the API

### Option 1: Swagger UI (Easy)
1. Open http://localhost:8000/docs
2. Click "Try it out" on each endpoint
3. Fill in the fields and execute

### Option 2: cURL
```bash
# Register
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "patient@test.com",
    "password": "test123",
    "name": "Test Patient",
    "phone": "+919876543210",
    "role": "patient"
  }'

# Login
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "patient@test.com",
    "password": "test123"
  }'

# Create Profile
curl -X POST "http://localhost:8000/api/v1/patient/profile" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "dob": "1990-05-15T00:00:00",
    "gender": "Male",
    "blood_group": "O+",
    "height": 180.5,
    "weight": 75.0,
    "emergency_contact": "Jane Doe",
    "emergency_contact_phone": "+919876543211"
  }'
```

### Option 3: Postman
Import the collection from `API_DOCUMENTATION.md`

---

## Project Structure

```
backend/
├── app/
│   ├── api/v1/routes/          # API endpoints
│   │   ├── auth.py             # Authentication
│   │   ├── patient.py          # Patient profile & medical history
│   │   ├── reports.py          # Report upload & AI processing
│   │   ├── emergency.py        # Emergency profile
│   │   ├── qr_codes.py         # QR code generation/scanning
│   │   └── doctor.py           # Doctor dashboard & audit logs
│   ├── auth/                   # JWT & authentication utils
│   ├── models/                 # SQLAlchemy ORM models
│   ├── schemas/                # Pydantic request/response models
│   ├── database/               # Database connection
│   ├── services/               # Business logic
│   │   ├── cloudinary_service.py
│   │   └── audit_service.py
│   ├── ai/                     # Gemini AI integration
│   ├── qr/                     # QR code generation
│   └── main.py                 # FastAPI app
├── requirements.txt
├── .env
├── .gitignore
├── README.md
├── API_DOCUMENTATION.md
└── QUICKSTART.md
```

---

## Database Schema

### Users Table
- id (PK)
- email (unique)
- name
- phone
- password (hashed)
- role (patient/doctor/admin)
- created_at

### Patient Profiles
- id (PK)
- user_id (FK → users)
- dob, gender, blood_group, height, weight
- emergency_contact, emergency_contact_phone

### Medical Data
- diseases: disease_name, diagnosed_date
- allergies: allergy, severity (mild/moderate/severe)
- medicines: medicine, dosage, frequency

### Reports & AI
- reports: patient_id, url, report_type, upload_date
- ai_summaries: patient_id, summary, risk_level, generated_at

### Emergency & Security
- emergency_profiles: Patient's critical info (blood group, allergies, meds, summary)
- qr_codes: patient_id, encrypted_token
- audit_logs: doctor_id, patient_id, action, time, ip_address

---

## Key Features Implemented

✅ **Authentication** - JWT-based register/login  
✅ **Patient Profile** - Create, read, update  
✅ **Medical History** - Diseases, allergies, medications  
✅ **Report Upload** - PDF/JPG/PNG with Cloudinary  
✅ **AI Processing** - Gemini API auto-extracts medical info  
✅ **Emergency Profile** - Focused on critical info for doctors  
✅ **QR Code** - Encrypted QR with emergency access  
✅ **Doctor Dashboard** - View emergency profiles  
✅ **Audit Logging** - Track all doctor access  

---

## Common Issues

### PostgreSQL Connection Error
```
Make sure PostgreSQL is running:
- Windows: Services → postgresql-x64-XX
- Mac: brew services start postgresql
- Linux: sudo systemctl start postgresql
```

### Gemini API Key Error
- Get key from: https://makersuite.google.com/app/apikey
- Make sure billing is enabled in Google Cloud

### Cloudinary Upload Error
- Get credentials from: https://cloudinary.com/console
- Verify CLOUDINARY_CLOUD_NAME matches your account

---

## Next Steps

1. **Frontend (Flutter)** - Create mobile app for patients
2. **Dashboard (React)** - Create web dashboard for doctors
3. **Advanced Features**:
   - Real-time notifications
   - Video consultation integration
   - Prescription management
   - Appointment scheduling
   - Multi-language support

---

## Support

For issues or questions:
1. Check API_DOCUMENTATION.md for endpoint details
2. Review error messages in API response
3. Check logs in terminal for debug info

---
