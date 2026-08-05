from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile
from sqlalchemy.orm import Session
from datetime import datetime
import json
from app.database import get_db
from app.auth import get_current_user
from app.models import (
    User,
    PatientProfile,
    Report,
    AISummary,
    Disease,
    Allergy,
    Medicine,
    EmergencyProfile,
    UserRole,
)
from app.services.cloudinary_service import CloudinaryService
from app.ai import AIProcessor

router = APIRouter(prefix="/api/v1/reports", tags=["reports"])
cloudinary_service = CloudinaryService()
ai_processor = AIProcessor()


@router.post("/upload", response_model=dict)
async def upload_report(
    file: UploadFile = File(...),
    report_type: str = "lab_report",
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Upload medical report and auto-extract info with AI.
    report_type: prescription, lab_report, discharge_summary
    """
    user = db.query(User).filter(User.id == current_user_id).first()
    if not user or user.role != UserRole.PATIENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only patients can upload reports",
        )

    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    try:
        # Upload file to Cloudinary
        file_content = await file.read()
        upload_result = cloudinary_service.upload_file(
            file_content, f"{current_user_id}_{file.filename}", folder="lifepass/reports"
        )

        # Save report metadata
        db_report = Report(
            patient_id=profile.id,
            url=upload_result["url"],
            report_type=report_type,
            upload_date=datetime.utcnow(),
        )
        db.add(db_report)
        db.commit()
        db.refresh(db_report)

        # AI Processing
        extracted_data = None
        if file.filename.lower().endswith(".pdf"):
            text = ai_processor.extract_text_from_pdf(file_content)
            extracted_data = ai_processor.analyze_medical_report(text)
        else:
            # For image files, send directly to Gemini
            extracted_data = ai_processor.analyze_medical_report(file_content.decode("utf-8", errors="ignore"))

        # Store extracted data and update patient profile
        if extracted_data:
            # Update blood group
            if extracted_data.get("blood_group"):
                profile.blood_group = extracted_data["blood_group"]

            # Add diseases
            for disease in extracted_data.get("diseases", []):
                existing = (
                    db.query(Disease)
                    .filter(
                        Disease.patient_id == profile.id,
                        Disease.disease_name == disease,
                    )
                    .first()
                )
                if not existing:
                    db.add(Disease(patient_id=profile.id, disease_name=disease))

            # Add allergies
            for allergy in extracted_data.get("allergies", []):
                existing = (
                    db.query(Allergy)
                    .filter(
                        Allergy.patient_id == profile.id,
                        Allergy.allergy == allergy,
                    )
                    .first()
                )
                if not existing:
                    db.add(Allergy(patient_id=profile.id, allergy=allergy, severity="moderate"))

            # Add medicines
            for med in extracted_data.get("medicines", []):
                existing = (
                    db.query(Medicine)
                    .filter(
                        Medicine.patient_id == profile.id,
                        Medicine.medicine == med.get("name"),
                    )
                    .first()
                )
                if not existing:
                    db.add(
                        Medicine(
                            patient_id=profile.id,
                            medicine=med.get("name"),
                            dosage=med.get("dosage", ""),
                            frequency=med.get("frequency", ""),
                        )
                    )

            # Store AI summary
            db_summary = AISummary(
                patient_id=profile.id,
                summary=extracted_data.get("summary", ""),
                risk_level=extracted_data.get("risk_level", "medium"),
                generated_at=datetime.utcnow(),
            )
            db.add(db_summary)

            db.commit()

        return {
            "id": db_report.id,
            "url": db_report.url,
            "report_type": db_report.report_type,
            "extracted_data": extracted_data,
            "message": "Report uploaded and processed successfully",
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error processing report: {str(e)}",
        )


@router.get("/history", response_model=dict)
def get_report_history(
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get all reports for patient"""
    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    reports = (
        db.query(Report)
        .filter(Report.patient_id == profile.id)
        .order_by(Report.upload_date.desc())
        .all()
    )

    return {
        "reports": [
            {
                "id": r.id,
                "type": r.report_type,
                "url": r.url,
                "uploaded": r.upload_date,
            }
            for r in reports
        ]
    }


@router.get("/summary", response_model=dict)
def get_ai_summary(
    current_user_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get latest AI summary of patient's medical data"""
    profile = (
        db.query(PatientProfile).filter(PatientProfile.user_id == current_user_id).first()
    )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found",
        )

    summary = (
        db.query(AISummary)
        .filter(AISummary.patient_id == profile.id)
        .order_by(AISummary.generated_at.desc())
        .first()
    )

    if not summary:
        return {
            "summary": None,
            "risk_level": None,
            "message": "No AI summary generated yet",
        }

    return {
        "summary": summary.summary,
        "risk_level": summary.risk_level,
        "generated_at": summary.generated_at,
    }
