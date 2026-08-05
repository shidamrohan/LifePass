# LifePass Backend Setup

## Installation

1. **Create virtual environment:**
   ```bash
   python -m venv venv
   venv\Scripts\activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure environment variables:**
   - Copy `.env.example` to `.env`
   - Add your API keys:
     - PostgreSQL connection string
     - Gemini API key
     - Cloudinary credentials
     - JWT secret key

4. **Setup PostgreSQL database:**
   ```bash
   # Create database
   createdb lifepass
   ```

5. **Run the server:**
   ```bash
   python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

   API will be available at: `http://localhost:8000`
   API Docs: `http://localhost:8000/docs`

## Project Structure

```
backend/
├── app/
│   ├── api/
│   │   └── v1/
│   │       └── routes/
│   │           └── auth.py          # Authentication endpoints
│   ├── auth/                         # JWT & password utilities
│   ├── models/                       # SQLAlchemy ORM models
│   ├── schemas/                      # Pydantic request/response models
│   ├── database/                     # Database connection & session
│   ├── services/                     # Business logic services
│   ├── ai/                           # Gemini AI integration
│   ├── qr/                           # QR code generation/scanning
│   ├── utils/                        # Helper utilities
│   └── main.py                       # FastAPI app initialization
├── tests/                            # Unit & integration tests
├── requirements.txt                  # Python dependencies
├── .env                              # Environment variables
└── README.md                         # Documentation
```

## API Endpoints (Implemented)

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login & get JWT token

## Next Steps

1. **Patient Profile Routes**
   - `POST /api/v1/patient/profile` - Create patient profile
   - `GET /api/v1/patient/profile` - Get patient profile
   - `PUT /api/v1/patient/profile` - Update profile

2. **Medical History Routes**
   - `POST /api/v1/patient/disease` - Add disease
   - `POST /api/v1/patient/allergy` - Add allergy
   - `POST /api/v1/patient/medicine` - Add medicine

3. **Report Upload & AI Processing**
   - `POST /api/v1/patient/report` - Upload medical report
   - AI automatically extracts & processes information

4. **Emergency Profile**
   - `GET /api/v1/emergency/profile/{patient_id}` - Get emergency summary
   - Encrypted & accessible via QR code scan

5. **QR Module**
   - `GET /api/v1/qr/generate` - Generate patient QR
   - `POST /api/v1/qr/scan` - Scan & validate QR

6. **Doctor Dashboard**
   - `GET /api/v1/doctor/patient/{id}` - Access patient profile
   - `POST /api/v1/doctor/treatment` - Add treatment notes

7. **Audit Logging**
   - Automatic logging of all doctor access
