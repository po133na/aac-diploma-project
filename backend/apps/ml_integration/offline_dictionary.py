"""
Offline translation dictionary for common AAC words.
Contains ~200 common words in Russian, Kazakh, and English.
"""
from typing import Dict, Optional, Tuple


# Offline dictionary: {word_ru: (word_kk, word_en, category)}
OFFLINE_DICTIONARY: Dict[str, Tuple[str, str, str]] = {
    # Food items
    'яблоко': ('алма', 'apple', 'Food'),
    'банан': ('банан', 'banana', 'Food'),
    'хлеб': ('нан', 'bread', 'Food'),
    'молоко': ('сүт', 'milk', 'Food'),
    'вода': ('су', 'water', 'Food'),
    'сок': ('шырын', 'juice', 'Food'),
    'сыр': ('ірімшік', 'cheese', 'Food'),
    'яйцо': ('жумыртқа', 'egg', 'Food'),
    'мясо': ('ет', 'meat', 'Food'),
    'рыба': ('балық', 'fish', 'Food'),
    'рис': ('күріш', 'rice', 'Food'),
    'суп': ('сорпа', 'soup', 'Food'),
    'печенье': ('печенье', 'cookie', 'Food'),
    'конфета': ('кәмпит', 'candy', 'Food'),
    'мороженое': ('балмұздақ', 'ice cream', 'Food'),
    'чай': ('шай', 'tea', 'Food'),
    'кофе': ('кофе', 'coffee', 'Food'),
    'сахар': ('қант', 'sugar', 'Food'),
    'соль': ('тұз', 'salt', 'Food'),
    'овощи': ('көкөніс', 'vegetables', 'Food'),
    'фрукты': ('жеміс', 'fruits', 'Food'),
    
    # Actions
    'есть': ('жеу', 'eat', 'Actions'),
    'пить': ('ішу', 'drink', 'Actions'),
    'спать': ('ұйықтау', 'sleep', 'Actions'),
    'играть': ('ойнау', 'play', 'Actions'),
    'читать': ('оқу', 'read', 'Actions'),
    'писать': ('жазу', 'write', 'Actions'),
    'рисовать': ('сурет салу', 'draw', 'Actions'),
    'бегать': ('жүгіру', 'run', 'Actions'),
    'ходить': ('жүру', 'walk', 'Actions'),
    'сидеть': ('отыру', 'sit', 'Actions'),
    'стоять': ('тұру', 'stand', 'Actions'),
    'прыгать': ('секіру', 'jump', 'Actions'),
    'танцевать': ('билеу', 'dance', 'Actions'),
    'петь': ('ән айту', 'sing', 'Actions'),
    'слушать': ('тыңдау', 'listen', 'Actions'),
    'смотреть': ('көру', 'watch', 'Actions'),
    'открывать': ('ашу', 'open', 'Actions'),
    'закрывать': ('жабу', 'close', 'Actions'),
    'давать': ('беру', 'give', 'Actions'),
    'брать': ('алу', 'take', 'Actions'),
    'помогать': ('көмектесу', 'help', 'Actions'),
    'любить': ('сүю', 'love', 'Actions'),
    'нравиться': ('ұнау', 'like', 'Actions'),
    
    # Emotions
    'радость': ('қуаныш', 'joy', 'Emotions'),
    'грусть': ('қайғы', 'sadness', 'Emotions'),
    'злость': ('ашу', 'anger', 'Emotions'),
    'страх': ('қорқыныш', 'fear', 'Emotions'),
    'удивление': ('таңғалу', 'surprise', 'Emotions'),
    'любовь': ('сүйіспеншілік', 'love', 'Emotions'),
    'счастье': ('бақыт', 'happiness', 'Emotions'),
    'боль': ('ауру', 'pain', 'Emotions'),
    'усталость': ('шаршау', 'tiredness', 'Emotions'),
    'голод': ('аштық', 'hunger', 'Emotions'),
    'жажда': ('шөлдеу', 'thirst', 'Emotions'),
    
    # Places
    'дом': ('үй', 'home', 'Places'),
    'школа': ('мектеп', 'school', 'Places'),
    'больница': ('аурухана', 'hospital', 'Places'),
    'магазин': ('дүкен', 'store', 'Places'),
    'парк': ('саябақ', 'park', 'Places'),
    'кухня': ('аспазхана', 'kitchen', 'Places'),
    'спальня': ('жатақхана', 'bedroom', 'Places'),
    'ванная': ('жуынатын бөлме', 'bathroom', 'Places'),
    'туалет': ('дәретхана', 'toilet', 'Places'),
    'сад': ('бақ', 'garden', 'Places'),
    'улица': ('көше', 'street', 'Places'),
    'машина': ('машина', 'car', 'Places'),
    
    # People
    'мама': ('ана', 'mother', 'People'),
    'папа': ('әке', 'father', 'People'),
    'бабушка': ('әже', 'grandmother', 'People'),
    'дедушка': ('ата', 'grandfather', 'People'),
    'брат': ('аға', 'brother', 'People'),
    'сестра': ('апа', 'sister', 'People'),
    'друг': ('дос', 'friend', 'People'),
    'учитель': ('мұғалім', 'teacher', 'People'),
    'врач': ('дәрігер', 'doctor', 'People'),
    'ребенок': ('бала', 'child', 'People'),
    'мальчик': ('ұл', 'boy', 'People'),
    'девочка': ('қыз', 'girl', 'People'),
    'человек': ('адам', 'person', 'People'),
    
    # Animals
    'кошка': ('мысық', 'cat', 'Animals'),
    'собака': ('ит', 'dog', 'Animals'),
    'птица': ('құс', 'bird', 'Animals'),
    'лошадь': ('жылқы', 'horse', 'Animals'),
    'корова': ('сиыр', 'cow', 'Animals'),
    'свинья': ('шошқа', 'pig', 'Animals'),
    'овца': ('қой', 'sheep', 'Animals'),
    'курица': ('тауық', 'chicken', 'Animals'),
    'утка': ('үйрек', 'duck', 'Animals'),
    'рыба': ('балық', 'fish', 'Animals'),
    'медведь': ('аю', 'bear', 'Animals'),
    'заяц': ('қоян', 'rabbit', 'Animals'),
    'мышь': ('тышқан', 'mouse', 'Animals'),
    'лев': ('арыстан', 'lion', 'Animals'),
    'слон': ('піл', 'elephant', 'Animals'),
    
    # Objects
    'мяч': ('доп', 'ball', 'Objects'),
    'кукла': ('қуыршақ', 'doll', 'Objects'),
    'машина': ('машина', 'car', 'Objects'),
    'книга': ('кітап', 'book', 'Objects'),
    'карандаш': ('қарындаш', 'pencil', 'Objects'),
    'ручка': ('қалам', 'pen', 'Objects'),
    'стол': ('үстел', 'table', 'Objects'),
    'стул': ('орындық', 'chair', 'Objects'),
    'кровать': ('төсек', 'bed', 'Objects'),
    'окно': ('терезе', 'window', 'Objects'),
    'дверь': ('есік', 'door', 'Objects'),
    'телефон': ('телефон', 'phone', 'Objects'),
    'компьютер': ('компьютер', 'computer', 'Objects'),
    'телевизор': ('теледидар', 'TV', 'Objects'),
    'лампа': ('шам', 'lamp', 'Objects'),
    'часы': ('сағат', 'clock', 'Objects'),
    'зеркало': ('айна', 'mirror', 'Objects'),
    'полотенце': ('сүлгі', 'towel', 'Objects'),
    'мыло': ('сабын', 'soap', 'Objects'),
    'зубная щетка': ('тіс щеткасы', 'toothbrush', 'Objects'),
    'расческа': ('тарақ', 'comb', 'Objects'),
    
    # Colors
    'красный': ('қызыл', 'red', 'Objects'),
    'синий': ('көк', 'blue', 'Objects'),
    'зеленый': ('жасыл', 'green', 'Objects'),
    'желтый': ('сары', 'yellow', 'Objects'),
    'белый': ('ақ', 'white', 'Objects'),
    'черный': ('қара', 'black', 'Objects'),
    'оранжевый': ('қызғылт сары', 'orange', 'Objects'),
    'фиолетовый': ('күлгін', 'purple', 'Objects'),
    'розовый': ('қызғылт', 'pink', 'Objects'),
    'коричневый': ('қоңыр', 'brown', 'Objects'),
    
    # Numbers
    'один': ('бір', 'one', 'Objects'),
    'два': ('екі', 'two', 'Objects'),
    'три': ('үш', 'three', 'Objects'),
    'четыре': ('төрт', 'four', 'Objects'),
    'пять': ('бес', 'five', 'Objects'),
    'шесть': ('алты', 'six', 'Objects'),
    'семь': ('жеті', 'seven', 'Objects'),
    'восемь': ('сегіз', 'eight', 'Objects'),
    'девять': ('тоғыз', 'nine', 'Objects'),
    'десять': ('он', 'ten', 'Objects'),
    
    # Nature
    'солнце': ('күн', 'sun', 'Objects'),
    'луна': ('ай', 'moon', 'Objects'),
    'звезда': ('жұлдыз', 'star', 'Objects'),
    'дерево': ('ағаш', 'tree', 'Objects'),
    'цветок': ('гүл', 'flower', 'Objects'),
    'трава': ('шөп', 'grass', 'Objects'),
    'небо': ('аспан', 'sky', 'Objects'),
    'облако': ('бұлт', 'cloud', 'Objects'),
    'дождь': ('жаңбыр', 'rain', 'Objects'),
    'снег': ('қар', 'snow', 'Objects'),
    'вода': ('су', 'water', 'Objects'),
    'огонь': ('от', 'fire', 'Objects'),
    
    # Body parts
    'голова': ('бас', 'head', 'Objects'),
    'глаз': ('көз', 'eye', 'Objects'),
    'ухо': ('құлақ', 'ear', 'Objects'),
    'нос': ('мұрын', 'nose', 'Objects'),
    'рот': ('ауыз', 'mouth', 'Objects'),
    'рука': ('қол', 'hand', 'Objects'),
    'нога': ('аяқ', 'foot', 'Objects'),
    'палец': ('саусақ', 'finger', 'Objects'),
    
    # Common phrases
    'да': ('иә', 'yes', 'Actions'),
    'нет': ('жоқ', 'no', 'Actions'),
    'спасибо': ('рахмет', 'thank you', 'Actions'),
    'пожалуйста': ('өтінемін', 'please', 'Actions'),
    'извините': ('кешіріңіз', 'sorry', 'Actions'),
    'привет': ('сәлем', 'hello', 'Actions'),
    'пока': ('сау бол', 'goodbye', 'Actions'),
}


def get_offline_translation(word: str, source_lang: str = 'ru') -> Optional[Tuple[str, str, str]]:
    """
    Get translation from offline dictionary.
    
    Args:
        word: Word to translate (lowercased)
        source_lang: Source language ('ru' or 'kk')
    
    Returns:
        Tuple of (word_ru, word_kk, word_en, category) or None if not found
    """
    word_lower = word.lower().strip()
    
    if source_lang == 'ru':
        if word_lower in OFFLINE_DICTIONARY:
            kk, en, cat = OFFLINE_DICTIONARY[word_lower]
            return (word_lower, kk, en, cat)
    elif source_lang == 'kk':
        # Search by Kazakh word
        for ru_word, (kk_word, en_word, cat) in OFFLINE_DICTIONARY.items():
            if kk_word.lower() == word_lower:
                return (ru_word, kk_word, en_word, cat)
    
    return None


def get_all_offline_words() -> Dict[str, Tuple[str, str, str]]:
    """Get all words from offline dictionary."""
    return OFFLINE_DICTIONARY.copy()

