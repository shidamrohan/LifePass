import os
import sys
from datetime import datetime
from sqlalchemy import text

# Adjust path to import backend app
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import engine, SessionLocal
from app.models import Base, User, UserRole
from app.auth import get_password_hash

def seed():
    print("Initializing Database and Seeding with Raw SQL...")
    
    # Ensure tables exist
    Base.metadata.create_all(bind=engine)
    
    # Use raw connection to execute inserts with string representation of roles
    with engine.begin() as conn:
        # Check if staff exists
        res = conn.execute(text("SELECT id FROM users WHERE email = :email"), {"email": "staff@hospital.com"}).fetchone()
        if not res:
            print("Seeding Hospital Staff user...")
            hashed_pwd = get_password_hash("Password123")
            conn.execute(
                text("""
                    INSERT INTO users (email, name, phone, password, role, created_at)
                    VALUES ('staff@hospital.com', 'Dr. Sarah Connor', '+1 (555) 019-9000', :password, 'hospital_staff', :now)
                """),
                {"password": hashed_pwd, "now": datetime.utcnow()}
            )
            print("Hospital Staff created: staff@hospital.com / Password123")
        else:
            print("Hospital Staff user already exists.")

        # Check if patient exists
        res_patient = conn.execute(text("SELECT id FROM users WHERE email = :email"), {"email": "patient@gmail.com"}).fetchone()
        if not res_patient:
            print("Seeding Patient user...")
            hashed_pwd = get_password_hash("Password123")
            
            # Insert User
            user_id = conn.execute(
                text("""
                    INSERT INTO users (email, name, phone, password, role, created_at)
                    VALUES ('patient@gmail.com', 'John Doe', '+1 (555) 019-2831', :password, 'patient', :now)
                    RETURNING id
                """),
                {"password": hashed_pwd, "now": datetime.utcnow()}
            ).fetchone()[0]
            print(f"Patient user created (User ID: {user_id})")

            # Insert Patient Profile
            profile_id = conn.execute(
                text("""
                    INSERT INTO patient_profiles (user_id, dob, gender, blood_group, height, weight, emergency_contact, emergency_contact_phone)
                    VALUES (:user_id, :dob, 'Male', 'O-', 180.5, 78.2, 'Jane Doe (Spouse)', '+1 (555) 019-2832')
                    RETURNING id
                """),
                {
                    "user_id": user_id,
                    "dob": datetime(1990, 5, 14)
                }
            ).fetchone()[0]
            print(f"Patient Profile created (Profile ID: {profile_id})")

            # Insert Diseases
            conn.execute(
                text("""
                    INSERT INTO diseases (patient_id, disease_name, diagnosed_date)
                    VALUES (:profile_id, 'Type-1 Diabetes', :diagnosed),
                           (:profile_id, 'Hypertension', :diagnosed)
                """),
                {"profile_id": profile_id, "diagnosed": datetime(2015, 8, 20)}
            )

            # Insert Allergies
            conn.execute(
                text("""
                    INSERT INTO allergies (patient_id, allergy, severity)
                    VALUES (:profile_id, 'Penicillin', 'Severe'),
                           (:profile_id, 'Peanuts', 'Mild')
                """),
                {"profile_id": profile_id}
            )

            # Insert Medicines
            conn.execute(
                text("""
                    INSERT INTO medicines (patient_id, medicine, dosage, frequency)
                    VALUES (:profile_id, 'Lisinopril', '10mg', 'Once daily'),
                           (:profile_id, 'Insulin Glargine', '10 units', 'Every night')
                """),
                {"profile_id": profile_id}
            )

            # Insert AISummary
            conn.execute(
                text("""
                    INSERT INTO ai_summaries (patient_id, summary, risk_level, generated_at)
                    VALUES (:profile_id, :summary, 'high', :now)
                """),
                {
                    "profile_id": profile_id,
                    "summary": "Patient is a 36-year-old male with Type-1 Diabetes and Hypertension. Patient has a severe allergy to Penicillin which must be avoided in emergency procedures. Current medications include daily Lisinopril and nightly Insulin.",
                    "now": datetime.utcnow()
                }
            )
            print("Medical data seeded successfully.")
        else:
            print("Patient user already exists.")

        # Check if admin exists
        res_admin = conn.execute(text("SELECT id FROM users WHERE email = :email"), {"email": "admin@lifepass.com"}).fetchone()
        if not res_admin:
            print("Seeding Admin user...")
            hashed_pwd = get_password_hash("Password123")
            conn.execute(
                text("""
                    INSERT INTO users (email, name, phone, password, role, created_at)
                    VALUES ('admin@lifepass.com', 'System Administrator', '+1 (555) 000-0000', :password, 'admin', :now)
                """),
                {"password": hashed_pwd, "now": datetime.utcnow()}
            )
            print("Admin user created: admin@lifepass.com / Password123")
        else:
            print("Admin user already exists.")

if __name__ == "__main__":
    seed()
