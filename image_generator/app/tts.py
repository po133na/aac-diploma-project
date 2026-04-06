import base64
import edge_tts
import tempfile
import os


# Голоса для языков
VOICES = {
    "ru": "ru-RU-DmitryNeural",      # Русский мужской
    "kk": "kk-KZ-AigulNeural",        # Казахский женский
    "en": "en-US-JennyNeural"         # Английский женский
}


async def text_to_speech(text: str, language: str) -> str:
    """
    Преобразует текст в речь используя Edge TTS.
    Поддерживает русский, казахский и английский.
    Возвращает base64 закодированный MP3
    """
    try:
        voice = VOICES.get(language, VOICES["ru"])
        
        # Создаём временный файл
        with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as f:
            temp_path = f.name
        
        # Генерируем аудио
        communicate = edge_tts.Communicate(text, voice)
        await communicate.save(temp_path)
        
        # Читаем и кодируем в base64
        with open(temp_path, 'rb') as f:
            audio_base64 = base64.b64encode(f.read()).decode('utf-8')
        
        # Удаляем временный файл
        os.unlink(temp_path)
        
        return audio_base64
        
    except Exception as e:
        print(f"TTS error: {e}")
        raise