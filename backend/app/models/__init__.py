from sqlalchemy import Column, Integer, String, DateTime, Float, ForeignKey, Text, Enum, ARRAY
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
import enum

Base = declarative_base()


class UserRole(str, enum.Enum):
    PATIENT = "patient"
    DOCTOR = "doctor"
    ADMIN = "admin"


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    name = Column(String)
    phone = Column(String)
    password = Column(String)
    role = Column(Enum(UserRole), default=UserRole.PATIENT)
    created_at = Column(DateTime, default=datetime.utcnow)


class PatientProfile(Base):
    __tablename__ = "patient_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True)
    dob = Column(DateTime)
    gender = Column(String)
    blood_group = Column(String)
    height = Column(Float)
    weight = Column(Float)
    emergency_contact = Column(String)
    emergency_contact_phone = Column(String)


class Disease(Base):
    __tablename__ = "diseases"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patient_profiles.id"))
    disease_name = Column(String)
    diagnosed_date = Column(DateTime, nullable=True)


class Allergy(Base):
    __tablename__ = "allergies"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patient_profiles.id"))
    allergy = Column(String)
    severity = Column(String)  # mild, moderate, severe


class Medicine(Base):
    __tablename__ = "medicines"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patient_profiles.id"))
    medicine = Column(String)
    dosage = Column(String)
    frequency = Column(String)


class Report(Base):
    __tablename__ = "reports"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patient_profiles.id"))
    url = Column(String)
    report_type = Column(String)  # prescription, lab_report, discharge_summary
    upload_date = Column(DateTime, default=datetime.utcnow)


class AISummary(Base):
    __tablename__ = "ai_summaries"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patient_profiles.id"))
    summary = Column(Text)
    risk_level = Column(String)  # low, medium, high
    generated_at = Column(DateTime, default=datetime.utcnow)


class EmergencyProfile(Base):
    __tablename__ = "emergency_profiles"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patient_profiles.id"), unique=True)
    blood_group = Column(String)
    allergies = Column(ARRAY(String))
    chronic_diseases = Column(ARRAY(String))
    current_medications = Column(Text)  # JSON string
    ai_summary = Column(Text)
    last_updated = Column(DateTime, default=datetime.utcnow)


class QRCode(Base):
    __tablename__ = "qr_codes"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patient_profiles.id"), unique=True)
    encrypted_token = Column(String, unique=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    doctor_id = Column(Integer, ForeignKey("users.id"))
    patient_id = Column(Integer, ForeignKey("patient_profiles.id"))
    action = Column(String)
    time = Column(DateTime, default=datetime.utcnow)
    ip_address = Column(String)
