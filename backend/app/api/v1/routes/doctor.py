from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from datetime import datetime
from app.database import get_db
from app.auth import get_current_user
from app.models import (
    User,
    PatientProfile,
    AISummary,
    Disease,
    Allergy,
    Medicine,
    UserRole,
    AuditLog,
)
from app.schemas import TreatmentNote
from app.services.audit_service import AuditService

router = APIRouter(prefix="/api/v1/doctor", tags=["doctor"])


@router.get("/patient/{patient_id}", response_model=dict)
def get_patient_profile(
    patient_id: int,
    current_user_id: int = Depends(get_current_user),
    request: Request = None,
    db: Session = Depends(get_db),
):
    """
    Get patient emergency profile (Doctor Dashboard).
    Doctor must be authenticated to access.
    """
    user = db.query(User).filter(User.id == current_user_id).first()
    if not user or user.role != UserRole.DOCTOR:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only doctors can access patient profiles",
        )

    profile = db.query(PatientProfile).filter(PatientProfile.id == patient_id).first()
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient not found",
        )

    # Log access for audit trail
    ip_address = request.client.host if request else "unknown"
    AuditService.log_access(
        db, current_user_id, patient_id, "accessed_emergency_profile", ip_address
    )

    # Build emergency profile
    diseases = db.query(Disease).filter(Disease.patient_id == patient_id).all()
    allergies = db.query(Allergy).filter(Allergy.patient_id == patient_id).all()
    medicines = db.query(Medicine).filter(Medicine.patient_id == patient_id).all()
    summary = (
        db.query(AISummary)
        .filter(AISummary.patient_id == patient_id)
        .order_by(AISummary.generated_at.desc())
        .first()
    )

    patient_data = db.query(User).filter(User.id == profile.user_id).first()

    return {
        "patient_id": patient_id,
        "patient_name": patient_data.name if patient_data else "N/A",
        "blood_group": profile.blood_group,
        "dob": profile.dob,
        "gender": profile.gender,
        "emergency_contact": profile.emergency_contact,
        "emergency_contact_phone": profile.emergency_contact_phone,
        "chronic_diseases": [d.disease_name for d in diseases],
        "allergies": [
            {"allergy": a.allergy, "severity": a.severity} for a in allergies
        ],
        "current_medications": [
            {
                "name": m.medicine,
                "dosage": m.dosage,
                "frequency": m.frequency,
            }
            for m in medicines
        ],
        "ai_summary": summary.summary if summary else None,
        "risk_level": summary.risk_level if summary else None,
    }


@router.post("/treatment", response_model=dict)
def add_treatment_notes(
    treatment: TreatmentNote,
    current_user_id: int = Depends(get_current_user),
    request: Request = None,
    db: Session = Depends(get_db),
):
    """Add treatment notes for a patient (Doctor only)"""
    user = db.query(User).filter(User.id == current_user_id).first()
    if not user or user.role != UserRole.DOCTOR:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only doctors can add treatment notes",
        )

    # Verify patient exists
    patient = db.query(PatientProfile).filter(PatientProfile.id == treatment.patient_id).first()
    if not patient:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient not found",
        )

    # Log the action
    ip_address = request.client.host if request else "unknown"
    AuditService.log_access(
        db, current_user_id, treatment.patient_id, "added_treatment_notes", ip_address
    )

    return {
        "message": "Treatment notes recorded",
        "patient_id": treatment.patient_id,
        "doctor_id": current_user_id,
        "timestamp": datetime.utcnow(),
        "notes": treatment.notes,
    }


@router.get("/audit-logs/{patient_id}", response_model=dict)
def get_patient_access_logs(
    patient_id: int,
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get audit logs for patient access (Patient or Admin only)"""
    user = db.query(User).filter(User.id == current_user_id).first()
    if not user or user.role not in [UserRole.PATIENT, UserRole.ADMIN]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view audit logs",
        )

    # Verify patient owns their own logs if patient role
    profile = db.query(PatientProfile).filter(PatientProfile.id == patient_id).first()
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient not found",
        )

    if user.role == UserRole.PATIENT and profile.user_id != current_user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cannot view other patient's audit logs",
        )

    logs = AuditService.get_patient_access_logs(db, patient_id)

    return {
        "patient_id": patient_id,
        "access_logs": [
            {
                "doctor_id": log.doctor_id,
                "action": log.action,
                "timestamp": log.time,
                "ip_address": log.ip_address,
            }
            for log in logs
        ],
    }


@router.get("/my-activity", response_model=dict)
def get_doctor_activity(
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get activity log for current doctor"""
    user = db.query(User).filter(User.id == current_user_id).first()
    if not user or user.role != UserRole.DOCTOR:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only doctors can view their activity",
        )

    logs = AuditService.get_doctor_activity(db, current_user_id)

    return {
        "doctor_id": current_user_id,
        "activity": [
            {
                "patient_id": log.patient_id,
                "action": log.action,
                "timestamp": log.time,
            }
            for log in logs
        ],
    }
