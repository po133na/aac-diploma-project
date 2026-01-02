"""
ML Service for AAC Communication Cards.
FastAPI service for image generation using Stable Diffusion.
"""
import os
import logging
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional

from models.stable_diffusion import ImageGenerator
from models.image_processor import ImageProcessor
from utils.s3_uploader import S3Uploader

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="AAC ML Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize components
image_generator = None
image_processor = ImageProcessor()
s3_uploader = S3Uploader()


class GenerateRequest(BaseModel):
    """Request model for image generation."""
    word: str
    prompt: Optional[str] = None
    model: str = "stable-diffusion-v1-5"
    num_inference_steps: int = 20
    guidance_scale: float = 7.5


class GenerateResponse(BaseModel):
    """Response model for image generation."""
    image_url: str
    thumbnail_url: str
    generation_params: dict


@app.on_event("startup")
async def startup_event():
    """Initialize image generator on startup."""
    global image_generator
    logger.info("Initializing Stable Diffusion model...")
    try:
        image_generator = ImageGenerator()
        logger.info("Stable Diffusion model loaded successfully")
    except Exception as e:
        logger.error(f"Failed to load model: {e}")
        raise


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "model_loaded": image_generator is not None
    }


@app.post("/generate", response_model=GenerateResponse)
async def generate_image(request: GenerateRequest):
    """
    Generate image for a word using Stable Diffusion.
    
    Args:
        request: Generation request with word and parameters
    
    Returns:
        GenerateResponse with image URLs
    """
    if image_generator is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    try:
        logger.info(f"Generating image for word: {request.word}")
        
        # Build prompt
        prompt = request.prompt or image_generator.build_prompt(request.word)
        
        # Generate image
        image = image_generator.generate(
            prompt=prompt,
            num_inference_steps=request.num_inference_steps,
            guidance_scale=request.guidance_scale,
        )
        
        # Post-process image
        processed_image = image_processor.add_border(image)
        thumbnail = image_processor.create_thumbnail(processed_image)
        
        # Upload to S3
        image_url = s3_uploader.upload_image(processed_image, f"{request.word}_full.png")
        thumbnail_url = s3_uploader.upload_image(thumbnail, f"{request.word}_thumb.png")
        
        generation_params = {
            "prompt": prompt,
            "model": request.model,
            "num_inference_steps": request.num_inference_steps,
            "guidance_scale": request.guidance_scale,
        }
        
        logger.info(f"Successfully generated image for: {request.word}")
        
        return GenerateResponse(
            image_url=image_url,
            thumbnail_url=thumbnail_url,
            generation_params=generation_params
        )
    
    except Exception as e:
        logger.error(f"Image generation failed: {e}")
        raise HTTPException(status_code=500, detail=f"Generation failed: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)

