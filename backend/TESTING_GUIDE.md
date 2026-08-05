# LifePass Backend - Testing Guide

## Manual Testing Workflow

Follow this step-by-step guide to test all major features.

---

## 1. Authentication Flow

### Register Patient
```bash
POST http://localhost:8000/api/v1/auth/register

{
  "email": "patient@example.com",
  "password": "Password123!",
  "name": "John Doe",
  "phone": "+919876543210",
  "role": "patient"
}

Expected: 
- Status 200
- Returns user id (e.g., 1)
```

### Register Doctor
```bash
POST http://localhost:8000/api/v1/auth/register

{
  "email": "doctor@example.com",
  "password": "Password123!",
  "name": "Dr. Smith",
  "phone": "+918765432109",
  "role": "doctor"
}

Expected: Status 200, Returns user id (e.g., 2)
```

### Login Patient
```bash
POST http://localhost:8000/api/v1/auth/login

{
  "email": "patient@example.com",
  "password": "Password123!"
}

Expected: Status 200, Returns JWT token
Save this token as PATIENT_TOKEN
```

### Login Doctor
```bash
POST http://localhost:8000/api/v1/auth/login

{
  "email": "doctor@example.com",
  "password": "Password123!"
}

Expected: Status 200, Returns JWT token
Save this token as DOCTOR_TOKEN
```

---

## 2. Patient Profile Setup

### Create Patient Profile
```bash
POST http://localhost:8000/api/v1/patient/profile
Authorization: Bearer PATIENT_TOKEN

{
  "dob": "1990-05-15T00:00:00",
  "gender": "Male",
  "blood_group": "O+",
  "height": 180.5,
  "weight": 75.0,
  "emergency_contact": "Jane Doe",
  "emergency_contact_phone": "+919876543211"
}

Expected: Status 200, Returns patient profile id
```

### Get Patient Profile
```bash
GET http://localhost:8000/api/v1/patient/profile
Authorization: Bearer PATIENT_TOKEN

Expected: Status 200, Returns complete profile details
```

### Update Patient Profile
```bash
PUT http://localhost:8000/api/v1/patient/profile
Authorization: Bearer PATIENT_TOKEN

{
  "blood_group": "A+",
  "weight": 78.0
}

Expected: Status 200
```

---

## 3. Medical History

### Add Disease
```bash
POST http://localhost:8000/api/v1/patient/disease
Authorization: Bearer PATIENT_TOKEN

{
  "disease_name": "Type 2 Diabetes",
  "diagnosed_date": "2015-03-20T00:00:00"
}

Expected: Status 200
```

### Add Multiple Diseases
```bash
POST http://localhost:8000/api/v1/patient/disease
(Add: "Hypertension")

POST http://localhost:8000/api/v1/patient/disease
(Add: "Asthma")
```

### Get All Diseases
```bash
GET http://localhost:8000/api/v1/patient/diseases
Authorization: Bearer PATIENT_TOKEN

Expected: Returns list of 3 diseases
```

### Add Allergy
```bash
POST http://localhost:8000/api/v1/patient/allergy
Authorization: Bearer PATIENT_TOKEN

{
  "allergy": "Penicillin",
  "severity": "severe"
}

Expected: Status 200
```

### Add Another Allergy
```bash
POST http://localhost:8000/api/v1/patient/allergy

{
  "allergy": "Sulfonamides",
  "severity": "moderate"
}
```

### Get All Allergies
```bash
GET http://localhost:8000/api/v1/patient/allergies
Authorization: Bearer PATIENT_TOKEN

Expected: Returns list of 2 allergies
```

### Add Medicine
```bash
POST http://localhost:8000/api/v1/patient/medicine
Authorization: Bearer PATIENT_TOKEN

{
  "medicine": "Metformin",
  "dosage": "500mg",
  "frequency": "Twice daily"
}

Expected: Status 200
```

### Add More Medicines
```bash
POST http://localhost:8000/api/v1/patient/medicine
(Add: "Lisinopril 10mg, Once daily")

POST http://localhost:8000/api/v1/patient/medicine
(Add: "Salbutamol, As needed")
```

### Get All Medicines
```bash
GET http://localhost:8000/api/v1/patient/medicines
Authorization: Bearer PATIENT_TOKEN

Expected: Returns list of 3 medicines
```

---

## 4. Emergency Profile

### Get Emergency Profile
```bash
GET http://localhost:8000/api/v1/emergency/profile
Authorization: Bearer PATIENT_TOKEN

Expected: Status 200
Should contain:
- blood_group: "A+"
- chronic_diseases: [...3 diseases]
- allergies: [...2 allergies]
- current_medications: [...3 medicines]
- emergency_contact info
```

This is the critical data shown to doctors in emergencies.

---

## 5. QR Code Generation

### Generate QR Code
```bash
GET http://localhost:8000/api/v1/qr/generate
Authorization: Bearer PATIENT_TOKEN

Expected: Status 200
Returns:
- patient_id
- qr_code: base64 encoded PNG image
- status: "created" or "regenerated"

Save the qr_code value for scanning test
```

### Scan QR Code (Doctor Access)
```bash
POST http://localhost:8000/api/v1/qr/scan

{
  "encrypted_token": "gAAAAABm..."  // Use from generate response
}

Expected: Status 200
Returns emergency profile (same as GET /emergency/profile)

IMPORTANT: This action is logged for audit trail
```

---

## 6. Report Upload & AI Processing

### Prepare Test Report File
Create a simple text file or use a real medical PDF:
```
File: patient_report.txt
Content:
Blood Group: O+
Diagnosis: Hypertension (recently diagnosed)
Medications: Amlodipine 5mg daily
Allergies: ACE inhibitors
```

### Upload Report
```bash
POST http://localhost:8000/api/v1/reports/upload
Authorization: Bearer PATIENT_TOKEN
Content-Type: multipart/form-data

Parameters:
- file: patient_report.txt (or .pdf)
- report_type: lab_report

Expected: Status 200
Returns:
- report_id
- url (Cloudinary link)
- extracted_data from AI:
  {
    "blood_group": "O+",
    "diseases": ["Hypertension"],
    "medicines": [{"name": "Amlodipine", "dosage": "5mg", "frequency": "daily"}],
    "allergies": ["ACE inhibitors"],
    "summary": "...",
    "risk_level": "medium"
  }
```

### Get Report History
```bash
GET http://localhost:8000/api/v1/reports/history
Authorization: Bearer PATIENT_TOKEN

Expected: Returns list of uploaded reports with URLs
```

### Get AI Summary
```bash
GET http://localhost:8000/api/v1/reports/summary
Authorization: Bearer PATIENT_TOKEN

Expected: Status 200
Returns latest AI-generated summary and risk level
```

---

## 7. Doctor Dashboard

### Doctor Views Patient Profile
```bash
GET http://localhost:8000/api/v1/doctor/patient/1
Authorization: Bearer DOCTOR_TOKEN

Expected: Status 200
Returns emergency profile for patient id 1
IMPORTANT: This logs doctor access with IP address and timestamp
```

### Doctor Adds Treatment Notes
```bash
POST http://localhost:8000/api/v1/doctor/treatment
Authorization: Bearer DOCTOR_TOKEN

{
  "patient_id": 1,
  "notes": "Started new hypertension medication. Monitor BP daily.",
  "medications": ["Lisinopril 10mg"],
  "follow_up_date": "2026-08-18T00:00:00"
}

Expected: Status 200
Timestamp and doctor_id automatically recorded
```

### Patient Views Audit Logs
```bash
GET http://localhost:8000/api/v1/doctor/audit-logs/1
Authorization: Bearer PATIENT_TOKEN

Expected: Status 200
Shows who accessed patient's profile and when:
- doctor_id
- action: "accessed_emergency_profile"
- timestamp
- ip_address
```

### Doctor Views Own Activity
```bash
GET http://localhost:8000/api/v1/doctor/my-activity
Authorization: Bearer DOCTOR_TOKEN

Expected: Status 200
Returns all patients doctor accessed and when
```

---

## 8. Error Handling Tests

### Invalid Credentials
```bash
POST /auth/login
{
  "email": "patient@example.com",
  "password": "WrongPassword"
}

Expected: Status 401, detail: "Invalid credentials"
```

### Missing Token
```bash
GET /patient/profile
(No Authorization header)

Expected: Status 401, detail: "Could not validate credentials"
```

### Patient Can't Access Doctor Routes
```bash
GET /doctor/patient/1
Authorization: Bearer PATIENT_TOKEN

Expected: Status 403, detail: "Only doctors can access patient profiles"
```

### Non-existent Patient
```bash
GET /doctor/patient/9999
Authorization: Bearer DOCTOR_TOKEN

Expected: Status 404, detail: "Patient not found"
```

### Duplicate Profile
```bash
POST /patient/profile (second time)
Authorization: Bearer PATIENT_TOKEN

Expected: Status 400, detail: "Patient profile already exists"
```

---

## Test Results Summary

Create a checklist:

```
✓ Authentication
  ✓ Register patient
  ✓ Register doctor
  ✓ Login returns token
  ✓ Invalid credentials rejected

✓ Patient Profile
  ✓ Create profile
  ✓ Get profile
  ✓ Update profile
  ✓ Duplicate prevention

✓ Medical History
  ✓ Add/Get diseases
  ✓ Add/Get allergies
  ✓ Add/Get medicines

✓ Emergency Profile
  ✓ Get aggregated data
  ✓ Contains all critical info

✓ QR Code
  ✓ Generate QR
  ✓ Scan QR without auth
  ✓ Returns emergency profile

✓ Report Upload
  ✓ Upload file to Cloudinary
  ✓ AI extracts data
  ✓ Data stored in database

✓ Doctor Access
  ✓ View patient profile
  ✓ Add treatment notes
  ✓ Access logged for audit

✓ Authorization
  ✓ Doctors can't use patient routes
  ✓ Patients can't view others' data
  ✓ All actions require proper role

✓ Error Handling
  ✓ Invalid credentials
  ✓ Missing tokens
  ✓ Authorization errors
  ✓ Not found errors
```

---

## Performance Testing

Load testing with sample data:
```bash
# Create multiple patients
for i in {1..10}; do
  curl -X POST "http://localhost:8000/api/v1/auth/register" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"patient$i@test.com\",\"password\":\"test123\",\"name\":\"Patient $i\",\"phone\":\"+919876543$i\",\"role\":\"patient\"}"
done
```

Monitor:
- Response times
- Database queries
- Memory usage
- API throughput

---

## Automated Testing (Optional)

Create `tests/test_api.py` with pytest:
```python
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_register():
    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": "test@test.com",
            "password": "test123",
            "name": "Test",
            "phone": "+919876543210",
            "role": "patient"
        }
    )
    assert response.status_code == 200
    assert "id" in response.json()

def test_login():
    # First register
    client.post(
        "/api/v1/auth/register",
        json={"email": "test@test.com", "password": "test123", "name": "Test", "phone": "+919876543210", "role": "patient"}
    )
    
    # Then login
    response = client.post(
        "/api/v1/auth/login",
        json={"email": "test@test.com", "password": "test123"}
    )
    assert response.status_code == 200
    assert "access_token" in response.json()
```

Run: `pytest tests/`

---
