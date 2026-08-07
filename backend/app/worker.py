import time
import httpx
import logging
from datetime import datetime
from dotenv import load_dotenv

# Load env vars
load_dotenv()

from app.supabase_client import supabase
from app.ai import AIProcessor

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

ai_processor = AIProcessor()

def process_report(report):
    report_id = report["id"]
    patient_id = report["patient_id"]
    file_url = report["file_url"]
    report_type = report["report_type"]
    
    logger.info(f"Processing report {report_id} for patient {patient_id}")
    
    try:
        # 1. Mark as processing
        supabase.table("medical_reports").update({"status": "processing"}).eq("id", report_id).execute()
        
        # 2. Download file
        logger.info(f"Downloading file from {file_url}")
        with httpx.Client() as client:
            response = client.get(file_url)
            response.raise_for_status()
            file_content = response.content
            
        # 3. AI Processing
        logger.info("Sending to Gemini AI...")
        extracted_data = None
        if file_url.lower().endswith(".pdf") or file_url.split("?")[0].lower().endswith(".pdf"):
            text = ai_processor.extract_text_from_pdf(file_content)
            extracted_data = ai_processor.analyze_medical_report(text)
        else:
            extracted_data = ai_processor.analyze_medical_report(file_content.decode("utf-8", errors="ignore"))
            
        if extracted_data:
            logger.info(f"AI Extraction successful for {report_id}")
            # Update blood group
            if extracted_data.get("blood_group"):
                supabase.table("profiles").update({"blood_group": extracted_data["blood_group"]}).eq("id", patient_id).execute()

            # Add diseases
            for disease in extracted_data.get("diseases", []):
                existing = supabase.table("diseases").select("*").eq("patient_id", patient_id).eq("disease_name", disease).execute()
                if not existing.data:
                    supabase.table("diseases").insert({"patient_id": patient_id, "disease_name": disease}).execute()

            # Add allergies
            for allergy in extracted_data.get("allergies", []):
                existing = supabase.table("allergies").select("*").eq("patient_id", patient_id).eq("allergy", allergy).execute()
                if not existing.data:
                    supabase.table("allergies").insert({"patient_id": patient_id, "allergy": allergy, "severity": "moderate"}).execute()

            # Add medicines
            for med in extracted_data.get("medicines", []):
                existing = supabase.table("medicines").select("*").eq("patient_id", patient_id).eq("medicine", med.get("name")).execute()
                if not existing.data:
                    supabase.table("medicines").insert({
                        "patient_id": patient_id, 
                        "medicine": med.get("name"), 
                        "dosage": med.get("dosage", ""), 
                        "frequency": med.get("frequency", "")
                    }).execute()

            # Store AI summary
            supabase.table("ai_summary").insert({
                "patient_id": patient_id,
                "summary": extracted_data.get("summary", ""),
                "risk_level": extracted_data.get("risk_level", "medium"),
                "generated_at": datetime.utcnow().isoformat()
            }).execute()
            
            # 4. Mark as completed
            supabase.table("medical_reports").update({"status": "completed"}).eq("id", report_id).execute()
            logger.info(f"Report {report_id} successfully marked as completed.")
        else:
            raise Exception("AI returned empty extraction data")

    except Exception as e:
        logger.error(f"Error processing report {report_id}: {str(e)}")
        # Mark as failed
        supabase.table("medical_reports").update({"status": "failed"}).eq("id", report_id).execute()


def main_loop():
    logger.info("Starting background worker for medical reports...")
    while True:
        try:
            # Poll for pending reports
            res = supabase.table("medical_reports").select("*").eq("status", "pending").execute()
            pending_reports = res.data
            
            for report in pending_reports:
                process_report(report)
                
        except Exception as e:
            logger.error(f"Database polling error: {str(e)}")
            
        # Wait 5 seconds before checking again
        time.sleep(5)

if __name__ == "__main__":
    main_loop()
