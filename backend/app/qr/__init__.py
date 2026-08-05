import qrcode
from io import BytesIO
import base64
from cryptography.fernet import Fernet
import os


class QRCodeGenerator:
    def __init__(self):
        self.cipher_key = os.getenv("QR_CIPHER_KEY", Fernet.generate_key())

    def encrypt_patient_id(self, patient_id: int) -> str:
        """Encrypt patient ID for QR code"""
        cipher = Fernet(self.cipher_key)
        encrypted = cipher.encrypt(str(patient_id).encode())
        return encrypted.decode()

    def decrypt_patient_id(self, encrypted_token: str) -> int:
        """Decrypt patient ID from QR code"""
        try:
            cipher = Fernet(self.cipher_key)
            decrypted = cipher.decrypt(encrypted_token.encode())
            return int(decrypted.decode())
        except Exception as e:
            raise ValueError(f"Invalid QR code: {str(e)}")

    def generate_qr_code(self, patient_id: int) -> str:
        """Generate QR code for patient (returns base64 encoded image)"""
        encrypted_token = self.encrypt_patient_id(patient_id)
        
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(encrypted_token)
        qr.make(fit=True)

        img = qr.make_image(fill_color="black", back_color="white")
        
        buffer = BytesIO()
        img.save(buffer, format="PNG")
        buffer.seek(0)
        
        base64_image = base64.b64encode(buffer.getvalue()).decode()
        return base64_image
