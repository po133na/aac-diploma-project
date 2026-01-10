import base64
from gtts import gTTS
from io import BytesIO


async def text_to_speech(text: str, language: str) -> str:
    """
    Преобразует текст в речь.
    language: "ru", "kk", "en"
    Возвращает base64 закодированный MP3
    """
    # gTTS поддерживает: ru, en, и другие
    # Для казахского используем русский голос (похожее произношение)
    lang_map = {
        "ru": "ru",
        "kk": "ru",  # Казахский озвучиваем русским (gTTS не поддерживает kk)
        "en": "en"
    }
    
    tts_lang = lang_map.get(language, "ru")
    
    try:
        tts = gTTS(text=text, lang=tts_lang)
        buffer = BytesIO()
        tts.write_to_fp(buffer)
        buffer.seek(0)
        audio_base64 = base64.b64encode(buffer.read()).decode("utf-8")
        return audio_base64
    except Exception as e:
        print(f"TTS error: {e}")
        raise