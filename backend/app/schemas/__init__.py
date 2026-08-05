from pydantic import BaseModel
from datetime import datetime
from enum import Enum


class UserRole(str, Enum):
    PATIENT = "patient"
    DOCTOR = "doctor"
    ADMIN = "admin"


class UserCreate(BaseModel):
    email: str
    password: str
    name: str
    phone: str
    role: UserRole


class UserLogin(BaseModel):
    email: str
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str


class PatientProfileCreate(BaseModel):
    dob: datetime
    gender: str
    blood_group: str
    height: float
    weight: float
    emergency_contact: str
    emergency_contact_phone: str


class PatientProfileUpdate(BaseModel):
    blood_group: str = None
    height: float = None
    weight: float = None
    emergency_contact: str = None
    emergency_contact_phone: str = None


class DiseaseCreate(BaseModel):
    disease_name: str
    diagnosed_date: datetime = None


class AllergyCreate(BaseModel):
    allergy: str
    severity: str  # mild, moderate, severe


class MedicineCreate(BaseModel):
    medicine: str
    dosage: str
    frequency: str


class EmergencyHealthProfile(BaseModel):
    patient_id: int
    blood_group: str
    allergies: list[str]
    chronic_diseases: list[str]
    current_medications: list[dict]
    emergency_contact: str
    emergency_contact_phone: str
    ai_summary: str = None
    last_updated: datetime


class ReportUpload(BaseModel):
    report_type: str  # prescription, lab_report, discharge_summary
    file_url: str
    upload_date: datetime


class TreatmentNote(BaseModel):
    patient_id: int
    doctor_id: int
    notes: str
    medications: list[str] = None
    follow_up_date: datetime = None


class AuditLog(BaseModel):
    doctor_id: int
    patient_id: int
    action: str
    time: datetime
    ip_address: str
