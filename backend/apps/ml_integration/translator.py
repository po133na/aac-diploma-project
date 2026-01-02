"""
Hybrid translation system with 3 levels:
1. Database lookup (verified translations)
2. Offline dictionary (~200 common words)
3. Google Translate API (fallback)
"""
import logging
from typing import Optional, Tuple
from django.conf import settings
from django.db.models import Q

from .models import Translation
from .offline_dictionary import get_offline_translation

logger = logging.getLogger(__name__)


class HybridTranslator:
    """Hybrid translation system for Russian/Kazakh/English."""
    
    def __init__(self):
        self.google_translate_enabled = getattr(settings, 'GOOGLE_TRANSLATE_ENABLED', True)
        self._google_translator = None
    
    def _get_google_translator(self):
        """Lazy load Google Translate client."""
        if self._google_translator is None and self.google_translate_enabled:
            try:
                from googletrans import Translator
                self._google_translator = Translator()
            except ImportError:
                logger.warning("googletrans not installed, Google Translate disabled")
                self.google_translate_enabled = False
        return self._google_translator
    
    def translate(self, word: str, source_lang: str = 'ru', category_hint: str = '') -> Tuple[str, str, str, str]:
        """
        Translate word from source language to all three languages.
        
        Args:
            word: Word to translate
            source_lang: Source language ('ru' or 'kk')
            category_hint: Optional category hint for better translation
        
        Returns:
            Tuple of (word_ru, word_kk, word_en, category)
        """
        word_clean = word.strip()
        if not word_clean:
            raise ValueError("Word cannot be empty")
        
        # Level 1: Database lookup
        translation = self._lookup_database(word_clean, source_lang)
        if translation:
            logger.debug(f"Found translation in database: {word_clean}")
            return translation
        
        # Level 2: Offline dictionary
        offline_result = get_offline_translation(word_clean, source_lang)
        if offline_result:
            word_ru, word_kk, word_en, cat = offline_result
            logger.debug(f"Found translation in offline dictionary: {word_clean}")
            # Save to database for future use
            self._save_to_database(word_ru, word_kk, word_en, cat, is_verified=False)
            return (word_ru, word_kk, word_en, cat)
        
        # Level 3: Google Translate API
        if self.google_translate_enabled:
            try:
                translation = self._translate_google(word_clean, source_lang, category_hint)
                if translation:
                    word_ru, word_kk, word_en, cat = translation
                    # Save to database for future use
                    self._save_to_database(word_ru, word_kk, word_en, cat, is_verified=False)
                    logger.info(f"Translated via Google Translate: {word_clean}")
                    return translation
            except Exception as e:
                logger.error(f"Google Translate failed: {e}")
        
        # Fallback: return word in all languages (not ideal, but better than error)
        logger.warning(f"Could not translate: {word_clean}, using fallback")
        if source_lang == 'ru':
            return (word_clean, word_clean, word_clean, category_hint or 'Objects')
        elif source_lang == 'kk':
            return (word_clean, word_clean, word_clean, category_hint or 'Objects')
        else:
            return (word_clean, word_clean, word_clean, category_hint or 'Objects')
    
    def _lookup_database(self, word: str, source_lang: str) -> Optional[Tuple[str, str, str, str]]:
        """Look up translation in database."""
        try:
            if source_lang == 'ru':
                translation = Translation.objects.filter(word_ru__iexact=word).first()
            elif source_lang == 'kk':
                translation = Translation.objects.filter(word_kk__iexact=word).first()
            else:
                translation = Translation.objects.filter(word_en__iexact=word).first()
            
            if translation:
                return (translation.word_ru, translation.word_kk, translation.word_en, translation.category)
        except Exception as e:
            logger.error(f"Database lookup failed: {e}")
        
        return None
    
    def _save_to_database(self, word_ru: str, word_kk: str, word_en: str, category: str, is_verified: bool = False):
        """Save translation to database."""
        try:
            Translation.objects.get_or_create(
                word_ru=word_ru,
                defaults={
                    'word_ru': word_ru,
                    'word_kk': word_kk,
                    'word_en': word_en,
                    'category': category,
                    'is_verified': is_verified,
                }
            )
        except Exception as e:
            logger.error(f"Failed to save translation to database: {e}")
    
    def _translate_google(self, word: str, source_lang: str, category_hint: str) -> Optional[Tuple[str, str, str, str]]:
        """Translate using Google Translate API."""
        translator = self._get_google_translator()
        if not translator:
            return None
        
        try:
            word_ru = word_kk = word_en = word
            
            if source_lang == 'ru':
                # Translate to English and Kazakh
                en_result = translator.translate(word, src='ru', dest='en')
                kk_result = translator.translate(word, src='ru', dest='kk')
                word_en = en_result.text.lower()
                word_kk = kk_result.text.lower()
                word_ru = word.lower()
            elif source_lang == 'kk':
                # Translate to English and Russian
                en_result = translator.translate(word, src='kk', dest='en')
                ru_result = translator.translate(word, src='kk', dest='ru')
                word_en = en_result.text.lower()
                word_ru = ru_result.text.lower()
                word_kk = word.lower()
            else:
                # Source is English, translate to Russian and Kazakh
                ru_result = translator.translate(word, src='en', dest='ru')
                kk_result = translator.translate(word, src='en', dest='kk')
                word_ru = ru_result.text.lower()
                word_kk = kk_result.text.lower()
                word_en = word.lower()
            
            return (word_ru, word_kk, word_en, category_hint or 'Objects')
        except Exception as e:
            logger.error(f"Google Translate error: {e}")
            return None
    
    def get_translation_stats(self) -> dict:
        """Get statistics about translation system usage."""
        db_count = Translation.objects.count()
        verified_count = Translation.objects.filter(is_verified=True).count()
        offline_count = len(get_offline_translation.__globals__['OFFLINE_DICTIONARY'])
        
        return {
            'database_translations': db_count,
            'verified_translations': verified_count,
            'offline_dictionary_size': offline_count,
            'google_translate_enabled': self.google_translate_enabled,
        }

