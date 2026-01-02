"""
Prompt building utilities for image generation.
"""
from typing import Optional


def build_prompt(word: str, style: str = "icon") -> str:
    """
    Build prompt for image generation.
    
    Args:
        word: English word
        style: Style hint (icon, illustration, etc.)
    
    Returns:
        Formatted prompt
    """
    base_prompt = f"{word}, simple {style}, flat design, minimalist, white background, high contrast, centered"
    return base_prompt


def build_negative_prompt() -> str:
    """Build negative prompt to avoid unwanted elements."""
    return "text, words, letters, complex, detailed, realistic, photograph, watermark, signature"

