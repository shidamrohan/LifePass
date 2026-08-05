import cloudinary
import cloudinary.uploader
import os


class CloudinaryService:
    def __init__(self):
        cloudinary.config(
            cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
            api_key=os.getenv("CLOUDINARY_API_KEY"),
            api_secret=os.getenv("CLOUDINARY_API_SECRET"),
        )

    def upload_file(self, file_obj, filename: str, folder: str = "lifepass/reports") -> dict:
        """
        Upload file to Cloudinary.
        Returns: {
            'url': str,
            'public_id': str,
            'resource_type': str
        }
        """
        try:
            result = cloudinary.uploader.upload(
                file_obj,
                public_id=f"{folder}/{filename}",
                resource_type="auto",
            )
            return {
                "url": result.get("secure_url"),
                "public_id": result.get("public_id"),
                "resource_type": result.get("resource_type"),
            }
        except Exception as e:
            raise ValueError(f"Error uploading file to Cloudinary: {str(e)}")

    def delete_file(self, public_id: str) -> bool:
        """Delete file from Cloudinary"""
        try:
            result = cloudinary.uploader.destroy(public_id)
            return result.get("result") == "ok"
        except Exception as e:
            raise ValueError(f"Error deleting file from Cloudinary: {str(e)}")

    def get_file_url(self, public_id: str) -> str:
        """Get secure URL for a file"""
        return cloudinary.CloudinaryImage(public_id).build_url(secure=True)
