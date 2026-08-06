from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from app.auth import get_current_user
from app.database import get_db
from app.models import AISummary, Allergy, Disease, Medicine, PatientProfile, TreatmentRecord, User, UserRole
from app.schemas import TreatmentNote
from app.services.audit_service import AuditService

router = APIRouter(prefix="/api/v1/hospital", tags=["hospital portal"])

def require_staff(user_id: int, db: Session) -> User:
    user = db.query(User).filter(User.id == user_id).first()
    if not user or user.role != UserRole.HOSPITAL_STAFF:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only authorised hospital staff can access this portal")
    return user

@router.get("/patient/{patient_id}", response_model=dict)
def get_patient_profile(patient_id: int, request: Request, current_user_id: int = Depends(get_current_user), db: Session = Depends(get_db)):
    require_staff(current_user_id, db)
    profile = db.query(PatientProfile).filter(PatientProfile.id == patient_id).first()
    if not profile: raise HTTPException(status_code=404, detail="Patient not found")
    AuditService.log_access(db, current_user_id, patient_id, "accessed_emergency_profile", request.client.host)
    patient = db.query(User).filter(User.id == profile.user_id).first()
    diseases = db.query(Disease).filter(Disease.patient_id == patient_id).all()
    allergies = db.query(Allergy).filter(Allergy.patient_id == patient_id).all()
    medicines = db.query(Medicine).filter(Medicine.patient_id == patient_id).all()
    summary = db.query(AISummary).filter(AISummary.patient_id == patient_id).order_by(AISummary.generated_at.desc()).first()
    return {"patient_id": patient_id, "patient_name": patient.name if patient else "Unknown", "blood_group": profile.blood_group, "dob": profile.dob, "gender": profile.gender, "emergency_contact": profile.emergency_contact, "emergency_contact_phone": profile.emergency_contact_phone, "chronic_diseases": [x.disease_name for x in diseases], "allergies": [{"allergy": x.allergy, "severity": x.severity} for x in allergies], "current_medications": [{"name": x.medicine, "dosage": x.dosage, "frequency": x.frequency} for x in medicines], "ai_summary": summary.summary if summary else None, "risk_level": summary.risk_level if summary else None}

@router.post("/treatment", response_model=dict)
def add_treatment(treatment: TreatmentNote, request: Request, current_user_id: int = Depends(get_current_user), db: Session = Depends(get_db)):
    require_staff(current_user_id, db)
    if not db.query(PatientProfile).filter(PatientProfile.id == treatment.patient_id).first(): raise HTTPException(status_code=404, detail="Patient not found")
    record = TreatmentRecord(patient_id=treatment.patient_id, doctor_id=current_user_id, notes=treatment.notes, medications=",".join(treatment.medications or []), follow_up_date=treatment.follow_up_date)
    db.add(record); db.commit(); db.refresh(record)
    AuditService.log_access(db, current_user_id, treatment.patient_id, "added_treatment_notes", request.client.host)
    return {"message": "Treatment record saved", "record_id": record.id, "timestamp": datetime.utcnow()}

@router.get("/my-activity", response_model=dict)
def get_activity(current_user_id: int = Depends(get_current_user), db: Session = Depends(get_db)):
    require_staff(current_user_id, db)
    logs = AuditService.get_doctor_activity(db, current_user_id)
    return {"activity": [{"patient_id": x.patient_id, "action": x.action, "timestamp": x.time} for x in logs]}
