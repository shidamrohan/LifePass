import google.generativeai as genai
import PyPDF2
import io
import json
import os


class AIProcessor:
    def __init__(self):
        api_key = os.getenv("GEMINI_API_KEY")
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel("gemini-pro")

    def extract_text_from_pdf(self, pdf_bytes: bytes) -> str:
        """Extract text from PDF bytes"""
        try:
            pdf_reader = PyPDF2.PdfReader(io.BytesIO(pdf_bytes))
            text = ""
            for page in pdf_reader.pages:
                text += page.extract_text()
            return text
        except Exception as e:
            raise ValueError(f"Error extracting text from PDF: {str(e)}")

    def analyze_medical_report(self, report_text: str) -> dict:
        """
        Use Gemini AI to extract medical information from report text.
        Returns: {
            'blood_group': str,
            'diseases': [str],
            'medicines': [{'name': str, 'dosage': str, 'frequency': str}],
            'allergies': [str],
            'summary': str,
            'risk_level': str
        }
        """
        prompt = f"""
        Analyze this medical report and extract key information in JSON format.
        
        Report:
        {report_text}
        
        Extract and return ONLY valid JSON (no markdown, no extra text) with:
        {{
            "blood_group": "blood group if mentioned, else null",
            "diseases": ["list of chronic diseases mentioned"],
            "medicines": [
                {{"name": "medicine name", "dosage": "dosage", "frequency": "frequency"}}
            ],
            "allergies": ["list of allergies"],
            "summary": "brief 2-3 line emergency summary",
            "risk_level": "low/medium/high based on severity"
        }}
        """

        try:
            response = self.model.generate_content(prompt)
            json_str = response.text.strip()
            if json_str.startswith("```json"):
                json_str = json_str[7:]
            if json_str.startswith("```"):
                json_str = json_str[3:]
            if json_str.endswith("```"):
                json_str = json_str[:-3]
            
            result = json.loads(json_str.strip())
            return result
        except Exception as e:
            raise ValueError(f"Error analyzing report with AI: {str(e)}")

    def generate_emergency_summary(self, patient_data: dict) -> str:
        """
        Generate an emergency summary from patient data.
        patient_data should include: blood_group, allergies, diseases, medicines
        """
        prompt = f"""
        Generate a concise emergency medical summary (max 100 words) for doctors:
        
        Blood Group: {patient_data.get('blood_group', 'Unknown')}
        Chronic Diseases: {', '.join(patient_data.get('diseases', []))}
        Current Medications: {', '.join([m.get('name', '') for m in patient_data.get('medicines', [])])}
        Allergies: {', '.join(patient_data.get('allergies', []))}
        
        Focus on life-threatening conditions and critical allergies.
        """

        try:
            response = self.model.generate_content(prompt)
            return response.text
        except Exception as e:
            raise ValueError(f"Error generating summary: {str(e)}")
