from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime

from app.database import get_db
from app.auth import get_current_user
from app.models import User, UserRole, PatientProfile, AuditLog, EmergencyProfile

router = APIRouter(prefix="/api/v1/admin", tags=["admin"])

def require_admin(
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.id == current_user_id).first()
    if not user or user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )
    return user


@router.get("/stats")
def get_admin_stats(
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """Get system-wide statistics for the admin dashboard."""
    total_hospitals = db.query(User).filter(User.role == UserRole.HOSPITAL_STAFF).count()
    total_patients = db.query(PatientProfile).count()
    
    # Active emergencies could be defined as treatment records or scans within the last 24h
    recent_logs = db.query(AuditLog).filter(AuditLog.time >= datetime.utcnow().replace(hour=0, minute=0, second=0)).count()

    return {
        "total_hospitals": total_hospitals,
        "total_patients": total_patients,
        "active_emergencies": recent_logs  # Using recent audit logs as proxy for active usage
    }


@router.get("/hospitals")
def get_hospitals(
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """List all registered hospital staff."""
    hospitals = db.query(User).filter(User.role == UserRole.HOSPITAL_STAFF).all()
    return [
        {
            "id": h.id,
            "name": h.name,
            "email": h.email,
            "created_at": h.created_at
        }
        for h in hospitals
    ]


@router.get("/patients")
def get_patients(
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """List all registered patients (read-only for system oversight)."""
    patients = db.query(PatientProfile).join(User).all()
    return [
        {
            "id": p.id,
            "patient_id": p.id, # For UI matching
            "name": p.user.name if hasattr(p, 'user') and p.user else "Unknown",
            "blood_group": p.blood_group,
            "risk_level": "Unknown", # Can be fetched from AISummary if needed
            "dob": p.dob
        }
        for p in patients
    ]


@router.get("/logs")
def get_system_logs(
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """Retrieve system-wide audit logs."""
    logs = db.query(AuditLog).order_by(AuditLog.time.desc()).limit(100).all()
    return [
        {
            "id": log.id,
            "doctor_id": log.doctor_id,
            "patient_id": log.patient_id,
            "action": log.action,
            "time": log.time,
            "ip_address": log.ip_address
        }
        for log in logs
    ]
