"""
Image post-processing utilities.
"""
import logging
from PIL import Image, ImageOps

logger = logging.getLogger(__name__)


class ImageProcessor:
    """Image post-processing for AAC cards."""
    
    def add_border(self, image: Image.Image, border_size: int = 20, color: str = "white") -> Image.Image:
        """
        Add white border to image.
        
        Args:
            image: PIL Image
            border_size: Border size in pixels
            color: Border color
        
        Returns:
            Image with border
        """
        return ImageOps.expand(image, border=border_size, fill=color)
    
    def create_thumbnail(self, image: Image.Image, size: tuple = (256, 256)) -> Image.Image:
        """
        Create thumbnail from image.
        
        Args:
            image: PIL Image
            size: Thumbnail size (width, height)
        
        Returns:
            Thumbnail image
        """
        # Use LANCZOS for high-quality resizing
        thumbnail = image.copy()
        thumbnail.thumbnail(size, Image.Resampling.LANCZOS)
        return thumbnail
    
    def resize(self, image: Image.Image, size: tuple) -> Image.Image:
        """
        Resize image to specified size.
        
        Args:
            image: PIL Image
            size: Target size (width, height)
        
        Returns:
            Resized image
        """
        return image.resize(size, Image.Resampling.LANCZOS)

