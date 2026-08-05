from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
from app.database import get_db
from app.auth import get_current_user
from app.models import User, PatientProfile, Disease, Allergy, Medicine, UserRole
from app.schemas import (
    PatientProfileCreate,
    PatientProfileUpdate,
    DiseaseCreate,
    AllergyCreate,
    MedicineCreate,
)

router = APIRouter(prefix="/api/v1/patient", tags=["patient"])


@router.post("/profile", response_model=dict)
def create_patient_profile(
    profile: PatientProfileCreate,
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create patient profile"""
    user = db.query(User).filter(User.id == current_user_id).first()
    if not user or user.role != UserRole.PATIENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only patients can create profiles",
        )

    existing_profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if existing_profile:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Patient profile already exists",
        )

    db_profile = PatientProfile(
        user_id=current_user_id,
        dob=profile.dob,
        gender=profile.gender,
        blood_group=profile.blood_group,
        height=profile.height,
        weight=profile.weight,
        emergency_contact=profile.emergency_contact,
        emergency_contact_phone=profile.emergency_contact_phone,
    )
    db.add(db_profile)
    db.commit()
    db.refresh(db_profile)

    return {
        "id": db_profile.id,
        "user_id": db_profile.user_id,
        "blood_group": db_profile.blood_group,
        "message": "Patient profile created successfully",
    }


@router.get("/profile", response_model=dict)
def get_patient_profile(
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get patient profile"""
    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    return {
        "id": profile.id,
        "user_id": profile.user_id,
        "dob": profile.dob,
        "gender": profile.gender,
        "blood_group": profile.blood_group,
        "height": profile.height,
        "weight": profile.weight,
        "emergency_contact": profile.emergency_contact,
        "emergency_contact_phone": profile.emergency_contact_phone,
    }


@router.put("/profile", response_model=dict)
def update_patient_profile(
    profile_update: PatientProfileUpdate,
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update patient profile"""
    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    update_data = profile_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(profile, field, value)

    db.commit()
    db.refresh(profile)

    return {
        "id": profile.id,
        "message": "Patient profile updated successfully",
    }


@router.post("/disease", response_model=dict)
def add_disease(
    disease: DiseaseCreate,
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Add disease to patient profile"""
    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    db_disease = Disease(
        patient_id=profile.id,
        disease_name=disease.disease_name,
        diagnosed_date=disease.diagnosed_date or datetime.utcnow(),
    )
    db.add(db_disease)
    db.commit()
    db.refresh(db_disease)

    return {"id": db_disease.id, "disease_name": db_disease.disease_name}


@router.get("/diseases", response_model=dict)
def get_diseases(
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get all diseases for patient"""
    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    diseases = db.query(Disease).filter(Disease.patient_id == profile.id).all()
    return {
        "diseases": [{"id": d.id, "name": d.disease_name, "date": d.diagnosed_date} for d in diseases]
    }


@router.post("/allergy", response_model=dict)
def add_allergy(
    allergy: AllergyCreate,
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Add allergy to patient profile"""
    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    db_allergy = Allergy(
        patient_id=profile.id, allergy=allergy.allergy, severity=allergy.severity
    )
    db.add(db_allergy)
    db.commit()
    db.refresh(db_allergy)

    return {"id": db_allergy.id, "allergy": db_allergy.allergy, "severity": db_allergy.severity}


@router.get("/allergies", response_model=dict)
def get_allergies(
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get all allergies for patient"""
    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    allergies = db.query(Allergy).filter(Allergy.patient_id == profile.id).all()
    return {
        "allergies": [
            {"id": a.id, "allergy": a.allergy, "severity": a.severity} for a in allergies
        ]
    }


@router.post("/medicine", response_model=dict)
def add_medicine(
    medicine: MedicineCreate,
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Add medicine to patient profile"""
    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    db_medicine = Medicine(
        patient_id=profile.id,
        medicine=medicine.medicine,
        dosage=medicine.dosage,
        frequency=medicine.frequency,
    )
    db.add(db_medicine)
    db.commit()
    db.refresh(db_medicine)

    return {
        "id": db_medicine.id,
        "medicine": db_medicine.medicine,
        "dosage": db_medicine.dosage,
        "frequency": db_medicine.frequency,
    }


@router.get("/medicines", response_model=dict)
def get_medicines(
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get all medicines for patient"""
    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    medicines = db.query(Medicine).filter(Medicine.patient_id == profile.id).all()
    return {
        "medicines": [
            {"id": m.id, "name": m.medicine, "dosage": m.dosage, "frequency": m.frequency}
            for m in medicines
        ]
    }
