# LifePass API Documentation

**Base URL:** `http://localhost:8000/api/v1`

---

## Authentication Endpoints

### Register
```
POST /auth/register
Content-Type: application/json

{
  "email": "patient@example.com",
  "password": "securepassword",
  "name": "John Doe",
  "phone": "+919876543210",
  "role": "patient"  // patient, doctor, or admin
}

Response:
{
  "id": 1,
  "email": "patient@example.com",
  "name": "John Doe",
  "role": "patient",
  "message": "Registration successful"
}
```

### Login
```
POST /auth/login
Content-Type: application/json

{
  "email": "patient@example.com",
  "password": "securepassword"
}

Response:
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

---

## Patient Profile Endpoints

### Create Patient Profile
```
POST /patient/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "dob": "1990-05-15T00:00:00",
  "gender": "Male",
  "blood_group": "O+",
  "height": 180.5,
  "weight": 75.0,
  "emergency_contact": "Jane Doe",
  "emergency_contact_phone": "+919876543211"
}

Response:
{
  "id": 1,
  "user_id": 1,
  "blood_group": "O+",
  "message": "Patient profile created successfully"
}
```

### Get Patient Profile
```
GET /patient/profile
Authorization: Bearer <token>

Response:
{
  "id": 1,
  "user_id": 1,
  "dob": "1990-05-15T00:00:00",
  "gender": "Male",
  "blood_group": "O+",
  "height": 180.5,
  "weight": 75.0,
  "emergency_contact": "Jane Doe",
  "emergency_contact_phone": "+919876543211"
}
```

### Update Patient Profile
```
PUT /patient/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "blood_group": "A+",
  "weight": 78.0
}

Response:
{
  "id": 1,
  "message": "Patient profile updated successfully"
}
```

---

## Medical History Endpoints

### Add Disease
```
POST /patient/disease
Authorization: Bearer <token>
Content-Type: application/json

{
  "disease_name": "Diabetes Type 2",
  "diagnosed_date": "2015-03-20T00:00:00"
}

Response:
{
  "id": 1,
  "disease_name": "Diabetes Type 2"
}
```

### Get All Diseases
```
GET /patient/diseases
Authorization: Bearer <token>

Response:
{
  "diseases": [
    {
      "id": 1,
      "name": "Diabetes Type 2",
      "date": "2015-03-20T00:00:00"
    }
  ]
}
```

### Add Allergy
```
POST /patient/allergy
Authorization: Bearer <token>
Content-Type: application/json

{
  "allergy": "Penicillin",
  "severity": "severe"  // mild, moderate, severe
}

Response:
{
  "id": 1,
  "allergy": "Penicillin",
  "severity": "severe"
}
```

### Get All Allergies
```
GET /patient/allergies
Authorization: Bearer <token>

Response:
{
  "allergies": [
    {
      "id": 1,
      "allergy": "Penicillin",
      "severity": "severe"
    }
  ]
}
```

### Add Medicine
```
POST /patient/medicine
Authorization: Bearer <token>
Content-Type: application/json

{
  "medicine": "Metformin",
  "dosage": "500mg",
  "frequency": "Twice daily"
}

Response:
{
  "id": 1,
  "medicine": "Metformin",
  "dosage": "500mg",
  "frequency": "Twice daily"
}
```

### Get All Medicines
```
GET /patient/medicines
Authorization: Bearer <token>

Response:
{
  "medicines": [
    {
      "id": 1,
      "name": "Metformin",
      "dosage": "500mg",
      "frequency": "Twice daily"
    }
  ]
}
```

---

## Report Upload & AI Processing

### Upload Medical Report
```
POST /reports/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

Parameters:
  file: <PDF/JPG/PNG file>
  report_type: "lab_report"  // prescription, lab_report, discharge_summary

Response:
{
  "id": 1,
  "url": "https://cloudinary.com/...",
  "report_type": "lab_report",
  "extracted_data": {
    "blood_group": "O+",
    "diseases": ["Hypertension"],
    "medicines": [
      {
        "name": "Aspirin",
        "dosage": "100mg",
        "frequency": "Daily"
      }
    ],
    "allergies": ["NSAIDs"],
    "summary": "Patient has controlled hypertension...",
    "risk_level": "medium"
  },
  "message": "Report uploaded and processed successfully"
}
```

### Get Report History
```
GET /reports/history
Authorization: Bearer <token>

Response:
{
  "reports": [
    {
      "id": 1,
      "type": "lab_report",
      "url": "https://cloudinary.com/...",
      "uploaded": "2026-08-04T22:00:00"
    }
  ]
}
```

### Get AI Summary
```
GET /reports/summary
Authorization: Bearer <token>

Response:
{
  "summary": "Patient has Type 2 diabetes and hypertension. Allergic to penicillin.",
  "risk_level": "medium",
  "generated_at": "2026-08-04T22:00:00"
}
```

---

## Emergency Profile Endpoints

### Get Emergency Profile
```
GET /emergency/profile
Authorization: Bearer <token>

Response:
{
  "blood_group": "O+",
  "chronic_diseases": ["Diabetes Type 2", "Hypertension"],
  "allergies": ["Penicillin (severe)"],
  "current_medications": [
    {
      "name": "Metformin",
      "dosage": "500mg",
      "frequency": "Twice daily"
    }
  ],
  "emergency_contact": "Jane Doe",
  "emergency_contact_phone": "+919876543211",
  "ai_summary": "Critical: Type 2 diabetes with HTN. Penicillin allergy.",
  "last_updated": "2026-08-04T22:00:00"
}
```

### Regenerate Emergency Summary
```
POST /emergency/regenerate
Authorization: Bearer <token>

Response:
{
  "message": "Emergency summary regenerated",
  "profile": { ... }
}
```

---

## QR Code Endpoints

### Generate QR Code
```
GET /qr/generate
Authorization: Bearer <token>

Response:
{
  "patient_id": 1,
  "qr_code": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
  "status": "created",
  "message": "QR code generated successfully"
}
```

### Scan QR Code
```
POST /qr/scan
Content-Type: application/json

{
  "encrypted_token": "gAAAAABmQ5x..."
}

Response:
{
  "patient_id": 1,
  "emergency_profile": {
    "blood_group": "O+",
    "chronic_diseases": [...],
    "allergies": [...],
    "current_medications": [...],
    "emergency_contact": "Jane Doe",
    "emergency_contact_phone": "+919876543211",
    "ai_summary": "...",
    "last_updated": "2026-08-04T22:00:00"
  },
  "message": "QR code scanned successfully"
}
```

---

## Doctor Dashboard Endpoints

### Get Patient Profile (Doctor Access)
```
GET /doctor/patient/{patient_id}
Authorization: Bearer <token>

Response:
{
  "patient_id": 1,
  "patient_name": "John Doe",
  "blood_group": "O+",
  "dob": "1990-05-15T00:00:00",
  "gender": "Male",
  "emergency_contact": "Jane Doe",
  "emergency_contact_phone": "+919876543211",
  "chronic_diseases": ["Diabetes Type 2"],
  "allergies": [
    {
      "allergy": "Penicillin",
      "severity": "severe"
    }
  ],
  "current_medications": [...],
  "ai_summary": "...",
  "risk_level": "medium"
}
```
**Note:** This access is automatically logged for audit trail.

### Add Treatment Notes
```
POST /doctor/treatment
Authorization: Bearer <token>
Content-Type: application/json

{
  "patient_id": 1,
  "notes": "Started insulin therapy. Follow-up in 2 weeks.",
  "medications": ["Insulin Glargine"],
  "follow_up_date": "2026-08-18T00:00:00"
}

Response:
{
  "message": "Treatment notes recorded",
  "patient_id": 1,
  "doctor_id": 2,
  "timestamp": "2026-08-04T22:30:00"
}
```

### Get Patient Access Logs (Audit Trail)
```
GET /doctor/audit-logs/{patient_id}
Authorization: Bearer <token>

Response:
{
  "patient_id": 1,
  "access_logs": [
    {
      "doctor_id": 2,
      "action": "accessed_emergency_profile",
      "timestamp": "2026-08-04T22:30:00",
      "ip_address": "192.168.1.100"
    }
  ]
}
```

### Get Doctor Activity
```
GET /doctor/my-activity
Authorization: Bearer <token>

Response:
{
  "doctor_id": 2,
  "activity": [
    {
      "patient_id": 1,
      "action": "accessed_emergency_profile",
      "timestamp": "2026-08-04T22:30:00"
    }
  ]
}
```

---

## Error Responses

All endpoints return standard error format:

```json
{
  "detail": "Error message explaining what went wrong"
}
```

Common status codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

---

## Testing with Postman

1. **Import Collection:** Copy the endpoints above into Postman
2. **Environment Variables:**
   - `base_url`: http://localhost:8000/api/v1
   - `token`: <JWT from login>

3. **Test Flow:**
   ```
   1. POST /auth/register → Get user ID
   2. POST /auth/login → Get JWT token
   3. POST /patient/profile → Create patient profile
   4. POST /patient/disease → Add diseases
   5. POST /patient/allergy → Add allergies
   6. POST /patient/medicine → Add medicines
   7. POST /reports/upload → Upload medical report
   8. GET /emergency/profile → View emergency profile
   9. GET /qr/generate → Generate QR code
   ```

---
