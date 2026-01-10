from deep_translator import GoogleTranslator


async def translate_to_english(text: str, source_lang: str) -> str:
    """
    Переводит текст на английский.
    source_lang: "ru" для русского, "kk" для казахского
    """
    try:
        translator = GoogleTranslator(source=source_lang, target="en")
        result = translator.translate(text)
        return result
    except Exception as e:
        print(f"Translation error: {e}")
        # Если перевод не удался, возвращаем оригинал
        return text