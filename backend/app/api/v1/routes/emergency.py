from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
import json
from app.database import get_db
from app.auth import get_current_user
from app.models import (
    User,
    PatientProfile,
    EmergencyProfile,
    Disease,
    Allergy,
    Medicine,
    AISummary,
    UserRole,
)
from app.ai import AIProcessor

router = APIRouter(prefix="/api/v1/emergency", tags=["emergency"])
ai_processor = AIProcessor()


def build_emergency_profile(db: Session, patient_id: int) -> dict:
    """Build emergency health profile from patient data"""
    diseases = (
        db.query(Disease).filter(Disease.patient_id == patient_id).all()
    )
    allergies = (
        db.query(Allergy).filter(Allergy.patient_id == patient_id).all()
    )
    medicines = (
        db.query(Medicine).filter(Medicine.patient_id == patient_id).all()
    )
    profile = db.query(PatientProfile).filter(PatientProfile.id == patient_id).first()
    summary = (
        db.query(AISummary)
        .filter(AISummary.patient_id == patient_id)
        .order_by(AISummary.generated_at.desc())
        .first()
    )

    return {
        "blood_group": profile.blood_group if profile else None,
        "chronic_diseases": [d.disease_name for d in diseases],
        "allergies": [f"{a.allergy} ({a.severity})" for a in allergies],
        "current_medications": [
            {
                "name": m.medicine,
                "dosage": m.dosage,
                "frequency": m.frequency,
            }
            for m in medicines
        ],
        "emergency_contact": profile.emergency_contact if profile else None,
        "emergency_contact_phone": profile.emergency_contact_phone if profile else None,
        "ai_summary": summary.summary if summary else None,
        "last_updated": summary.generated_at if summary else None,
    }


@router.get("/profile", response_model=dict)
def get_emergency_profile(
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get emergency health profile for current patient"""
    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    emergency_data = build_emergency_profile(db, profile.id)
    return emergency_data


@router.post("/regenerate", response_model=dict)
def regenerate_emergency_summary(
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Regenerate AI summary for emergency profile"""
    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    # Build current patient data
    emergency_data = build_emergency_profile(db, profile.id)

    # Generate new summary
    try:
        new_summary = ai_processor.generate_emergency_summary(emergency_data)
        
        # Store summary
        from app.models import AISummary
        ai_summary = AISummary(
            patient_id=profile.id,
            summary=new_summary,
            risk_level="medium",  # Could be enhanced with AI analysis
            generated_at=datetime.utcnow(),
        )
        db.add(ai_summary)
        db.commit()

        emergency_data["ai_summary"] = new_summary
        emergency_data["last_updated"] = datetime.utcnow()

        return {
            "message": "Emergency summary regenerated",
            "profile": emergency_data,
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error generating summary: {str(e)}",
        )
