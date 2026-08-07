from fastapi import APIRouter, HTTPException, status
import httpx
from datetime import datetime
from pydantic import BaseModel
from app.supabase_client import supabase
from app.ai import AIProcessor

router = APIRouter(prefix="/api/v1/reports", tags=["reports"])
ai_processor = AIProcessor()

class UploadReportRequest(BaseModel):
    file_url: str
    patient_id: str
    report_type: str

@router.post("/upload", response_model=dict)
async def upload_report(req: UploadReportRequest):
    """
    Upload medical report and auto-extract info with AI.
    report_type: prescription, lab_report, discharge_summary
    """
    try:
        # Download file
        async with httpx.AsyncClient() as client:
            response = await client.get(req.file_url)
            if response.status_code != 200:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Failed to download file")
            file_content = response.content

        # Save report metadata
        report_data = {
            "patient_id": req.patient_id,
            "file_url": req.file_url,
            "report_type": req.report_type,
            "upload_date": datetime.utcnow().isoformat()
        }
        report_res = supabase.table("medical_reports").insert(report_data).execute()
        
        # AI Processing
        extracted_data = None
        if req.file_url.lower().endswith(".pdf") or req.file_url.split("?")[0].lower().endswith(".pdf"):
            text = ai_processor.extract_text_from_pdf(file_content)
            extracted_data = ai_processor.analyze_medical_report(text)
        else:
            extracted_data = ai_processor.analyze_medical_report(file_content.decode("utf-8", errors="ignore"))

        if extracted_data:
            # Update blood group
            if extracted_data.get("blood_group"):
                supabase.table("profiles").update({"blood_group": extracted_data["blood_group"]}).eq("id", req.patient_id).execute()

            # Add diseases
            for disease in extracted_data.get("diseases", []):
                # Check if exists
                existing = supabase.table("diseases").select("*").eq("patient_id", req.patient_id).eq("disease_name", disease).execute()
                if not existing.data:
                    supabase.table("diseases").insert({"patient_id": req.patient_id, "disease_name": disease}).execute()

            # Add allergies
            for allergy in extracted_data.get("allergies", []):
                existing = supabase.table("allergies").select("*").eq("patient_id", req.patient_id).eq("allergy", allergy).execute()
                if not existing.data:
                    supabase.table("allergies").insert({"patient_id": req.patient_id, "allergy": allergy, "severity": "moderate"}).execute()

            # Add medicines
            for med in extracted_data.get("medicines", []):
                existing = supabase.table("medicines").select("*").eq("patient_id", req.patient_id).eq("medicine", med.get("name")).execute()
                if not existing.data:
                    supabase.table("medicines").insert({
                        "patient_id": req.patient_id, 
                        "medicine": med.get("name"), 
                        "dosage": med.get("dosage", ""), 
                        "frequency": med.get("frequency", "")
                    }).execute()

            # Store AI summary
            supabase.table("ai_summary").insert({
                "patient_id": req.patient_id,
                "summary": extracted_data.get("summary", ""),
                "risk_level": extracted_data.get("risk_level", "medium"),
                "generated_at": datetime.utcnow().isoformat()
            }).execute()

        return {
            "id": report_res.data[0]["id"] if report_res.data else None,
            "url": req.file_url,
            "report_type": req.report_type,
            "extracted_data": extracted_data,
            "message": "Report uploaded and processed successfully",
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error processing report: {str(e)}",
        )

@router.get("/history/{patient_id}", response_model=dict)
def get_report_history(patient_id: str):
    """Get all reports for patient"""
    try:
        res = supabase.table("medical_reports").select("*").eq("patient_id", patient_id).order("upload_date", desc=True).execute()
        return {
            "reports": [
                {
                    "id": r["id"],
                    "type": r["report_type"],
                    "url": r["url"],
                    "uploaded": r["upload_date"],
                }
                for r in res.data
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/summary/{patient_id}", response_model=dict)
def get_ai_summary(patient_id: str):
    """Get latest AI summary of patient's medical data"""
    try:
        res = supabase.table("ai_summary").select("*").eq("patient_id", patient_id).order("generated_at", desc=True).limit(1).execute()
        
        if not res.data:
            return {
                "summary": None,
                "risk_level": None,
                "message": "No AI summary generated yet",
            }
        
        summary = res.data[0]
        return {
            "summary": summary["summary"],
            "risk_level": summary["risk_level"],
            "generated_at": summary["generated_at"],
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
