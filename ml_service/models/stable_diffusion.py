"""
Stable Diffusion image generator.
"""
import logging
import torch
from diffusers import StableDiffusionPipeline, DPMSolverMultistepScheduler
from PIL import Image
from typing import Optional

logger = logging.getLogger(__name__)


class ImageGenerator:
    """Image generator using Stable Diffusion 1.5."""
    
    def __init__(self, model_id: str = "runwayml/stable-diffusion-v1-5"):
        """
        Initialize Stable Diffusion pipeline.
        
        Args:
            model_id: HuggingFace model ID
        """
        self.model_id = model_id
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        logger.info(f"Using device: {self.device}")
        
        # Load pipeline
        logger.info(f"Loading model: {model_id}")
        self.pipe = StableDiffusionPipeline.from_pretrained(
            model_id,
            torch_dtype=torch.float16 if self.device == "cuda" else torch.float32,
        )
        self.pipe = self.pipe.to(self.device)
        
        # Optimize for speed
        if self.device == "cuda":
            # Enable attention slicing for memory efficiency
            self.pipe.enable_attention_slicing()
            # Enable VAE slicing
            self.pipe.enable_vae_slicing()
            # Compile for faster inference (PyTorch 2.0+)
            try:
                self.pipe.unet = torch.compile(self.pipe.unet, mode="reduce-overhead")
                logger.info("Model compiled with torch.compile")
            except Exception as e:
                logger.warning(f"Could not compile model: {e}")
        
        # Use DPM-Solver scheduler for faster generation
        self.pipe.scheduler = DPMSolverMultistepScheduler.from_config(
            self.pipe.scheduler.config
        )
        
        logger.info("Stable Diffusion model loaded successfully")
    
    def build_prompt(self, word: str) -> str:
        """
        Build prompt for image generation.
        
        Args:
            word: English word to generate image for
        
        Returns:
            Formatted prompt
        """
        return f"{word}, simple icon, flat design, minimalist, white background, high contrast, centered, clean illustration"
    
    def generate(
        self,
        prompt: str,
        num_inference_steps: int = 20,
        guidance_scale: float = 7.5,
        negative_prompt: Optional[str] = None,
    ) -> Image.Image:
        """
        Generate image from prompt.
        
        Args:
            prompt: Text prompt for generation
            num_inference_steps: Number of inference steps (default: 20 for speed)
            guidance_scale: Guidance scale (default: 7.5)
            negative_prompt: Optional negative prompt
        
        Returns:
            PIL Image
        """
        if negative_prompt is None:
            negative_prompt = "text, words, letters, complex, detailed, realistic, photograph"
        
        logger.info(f"Generating image with prompt: {prompt}")
        
        with torch.inference_mode():
            result = self.pipe(
                prompt=prompt,
                negative_prompt=negative_prompt,
                num_inference_steps=num_inference_steps,
                guidance_scale=guidance_scale,
                width=512,
                height=512,
            )
        
        image = result.images[0]
        logger.info("Image generated successfully")
        
        return image

