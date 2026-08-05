from sqlalchemy.orm import Session
from datetime import datetime
from app.models import AuditLog


class AuditService:
    @staticmethod
    def log_access(
        db: Session, 
        doctor_id: int, 
        patient_id: int, 
        action: str, 
        ip_address: str
    ) -> AuditLog:
        """Log doctor access to patient profile"""
        audit = AuditLog(
            doctor_id=doctor_id,
            patient_id=patient_id,
            action=action,
            time=datetime.utcnow(),
            ip_address=ip_address,
        )
        db.add(audit)
        db.commit()
        db.refresh(audit)
        return audit

    @staticmethod
    def get_patient_access_logs(db: Session, patient_id: int, limit: int = 50):
        """Get all access logs for a patient"""
        return (
            db.query(AuditLog)
            .filter(AuditLog.patient_id == patient_id)
            .order_by(AuditLog.time.desc())
            .limit(limit)
            .all()
        )

    @staticmethod
    def get_doctor_activity(db: Session, doctor_id: int, limit: int = 50):
        """Get all activity for a doctor"""
        return (
            db.query(AuditLog)
            .filter(AuditLog.doctor_id == doctor_id)
            .order_by(AuditLog.time.desc())
            .limit(limit)
            .all()
        )
