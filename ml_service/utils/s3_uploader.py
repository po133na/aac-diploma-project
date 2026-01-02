"""
S3/MinIO uploader for generated images.
"""
import os
import logging
import io
import boto3
from botocore.exceptions import ClientError
from PIL import Image
from typing import Optional

logger = logging.getLogger(__name__)


class S3Uploader:
    """Uploader for S3/MinIO storage."""
    
    def __init__(self):
        """Initialize S3 client."""
        self.access_key = os.environ.get('AWS_ACCESS_KEY_ID', '')
        self.secret_key = os.environ.get('AWS_SECRET_ACCESS_KEY', '')
        self.bucket_name = os.environ.get('AWS_STORAGE_BUCKET_NAME', 'aac-cards')
        self.endpoint_url = os.environ.get('AWS_S3_ENDPOINT_URL', '')  # For MinIO
        self.region = os.environ.get('AWS_S3_REGION_NAME', 'us-east-1')
        
        # Initialize S3 client
        if self.access_key and self.secret_key:
            self.s3_client = boto3.client(
                's3',
                aws_access_key_id=self.access_key,
                aws_secret_access_key=self.secret_key,
                endpoint_url=self.endpoint_url if self.endpoint_url else None,
                region_name=self.region,
            )
        else:
            logger.warning("S3 credentials not configured, uploads will fail")
            self.s3_client = None
    
    def upload_image(self, image: Image.Image, filename: str) -> str:
        """
        Upload image to S3/MinIO.
        
        Args:
            image: PIL Image
            filename: Filename for upload
        
        Returns:
            URL of uploaded image
        """
        if not self.s3_client:
            # Return placeholder URL if S3 not configured
            logger.warning("S3 not configured, returning placeholder URL")
            return f"https://placeholder.com/{filename}"
        
        try:
            # Convert image to bytes
            img_buffer = io.BytesIO()
            image.save(img_buffer, format='PNG')
            img_buffer.seek(0)
            
            # Upload to S3
            key = f"cards/{filename}"
            self.s3_client.upload_fileobj(
                img_buffer,
                self.bucket_name,
                key,
                ExtraArgs={'ContentType': 'image/png'}
            )
            
            # Generate URL
            if self.endpoint_url:
                # MinIO URL
                url = f"{self.endpoint_url}/{self.bucket_name}/{key}"
            else:
                # AWS S3 URL
                url = f"https://{self.bucket_name}.s3.{self.region}.amazonaws.com/{key}"
            
            logger.info(f"Uploaded image to: {url}")
            return url
        
        except ClientError as e:
            logger.error(f"Failed to upload image: {e}")
            raise
        except Exception as e:
            logger.error(f"Unexpected error uploading image: {e}")
            raise

