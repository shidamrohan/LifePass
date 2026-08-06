from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
from app.database import get_db
from app.auth import get_current_user
from app.models import User, PatientProfile, QRCode, UserRole
from app.qr import QRCodeGenerator

router = APIRouter(prefix="/api/v1/qr", tags=["qr"])
qr_generator = QRCodeGenerator()


@router.get("/generate", response_model=dict)
def generate_qr_code(
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Generate QR code for patient's emergency profile"""
    user = db.query(User).filter(User.id == current_user_id).first()
    if not user or user.role != UserRole.PATIENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only patients can generate QR codes",
        )

    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    # Check if QR already exists
    existing_qr = db.query(QRCode).filter(QRCode.patient_id == profile.id).first()
    
    try:
        if existing_qr:
            # Regenerate QR image with existing token
            qr_image = qr_generator.generate_qr_code(profile.id)
            return {
                "patient_id": profile.id,
                "qr_code": qr_image,
                "encrypted_token": existing_qr.encrypted_token,
                "status": "regenerated",
                "message": "QR code regenerated",
            }
        else:
            # Create new QR
            encrypted_token = qr_generator.encrypt_patient_id(profile.id)
            # Generate the image from the same token stored for scanning.
            qr_image = qr_generator.generate_qr_code(profile.id)

            db_qr = QRCode(
                patient_id=profile.id,
                encrypted_token=encrypted_token,
                created_at=datetime.utcnow(),
            )
            db.add(db_qr)
            db.commit()

            return {
                "patient_id": profile.id,
                "qr_code": qr_image,
                "encrypted_token": encrypted_token,
                "status": "created",
                "message": "QR code generated successfully",
            }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error generating QR code: {str(e)}",
        )


@router.post("/scan", response_model=dict)
def scan_qr_code(
    qr_data: dict,
    db: Session = Depends(get_db),
):
    """
    Scan QR code and retrieve emergency profile.
    qr_data: {'encrypted_token': 'base64_encrypted_patient_id'}
    """
    try:
        encrypted_token = qr_data.get("encrypted_token")
        if not encrypted_token:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Missing encrypted_token",
            )

        # Decrypt patient ID
        patient_id = qr_generator.decrypt_patient_id(encrypted_token)

        # Verify patient exists
        profile = db.query(PatientProfile).filter(PatientProfile.id == patient_id).first()
        if not profile:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Patient not found",
            )

        # Build emergency profile for doctor
        from app.api.v1.routes.emergency import build_emergency_profile
        emergency_data = build_emergency_profile(db, patient_id)

        return {
            "patient_id": patient_id,
            "emergency_profile": emergency_data,
            "message": "QR code scanned successfully",
        }

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error scanning QR code: {str(e)}",
        )
