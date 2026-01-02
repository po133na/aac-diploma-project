"""
Script to seed database with initial categories and basic cards.
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'backend'))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from apps.cards.models import Category, Card
from apps.ml_integration.offline_dictionary import get_all_offline_words
from apps.ml_integration.translator import HybridTranslator


def create_categories():
    """Create default categories."""
    categories_data = [
        {'name_ru': 'Еда', 'name_kk': 'Тамақ', 'name_en': 'Food', 'icon': 'food', 'order': 1},
        {'name_ru': 'Действия', 'name_kk': 'Әрекеттер', 'name_en': 'Actions', 'icon': 'actions', 'order': 2},
        {'name_ru': 'Эмоции', 'name_kk': 'Эмоциялар', 'name_en': 'Emotions', 'icon': 'emotions', 'order': 3},
        {'name_ru': 'Места', 'name_kk': 'Орындар', 'name_en': 'Places', 'icon': 'places', 'order': 4},
        {'name_ru': 'Люди', 'name_kk': 'Адамдар', 'name_en': 'People', 'icon': 'people', 'order': 5},
        {'name_ru': 'Животные', 'name_kk': 'Жануарлар', 'name_en': 'Animals', 'icon': 'animals', 'order': 6},
        {'name_ru': 'Предметы', 'name_kk': 'Заттар', 'name_en': 'Objects', 'icon': 'objects', 'order': 7},
    ]
    
    created = 0
    for cat_data in categories_data:
        category, created_flag = Category.objects.get_or_create(
            name_en=cat_data['name_en'],
            defaults=cat_data
        )
        if created_flag:
            created += 1
            print(f"Created category: {category.name_en}")
        else:
            print(f"Category already exists: {category.name_en}")
    
    print(f"\nCreated {created} new categories")
    return Category.objects.all()


def create_cards_from_dictionary(categories):
    """Create cards from offline dictionary."""
    translator = HybridTranslator()
    dictionary = get_all_offline_words()
    
    # Map category names to Category objects
    category_map = {cat.name_en: cat for cat in categories}
    
    created = 0
    skipped = 0
    
    for word_ru, (word_kk, word_en, cat_name) in dictionary.items():
        category = category_map.get(cat_name)
        
        # Check if card already exists
        if Card.objects.filter(word_en__iexact=word_en).exists():
            skipped += 1
            continue
        
        card = Card.objects.create(
            word_ru=word_ru,
            word_kk=word_kk,
            word_en=word_en,
            category=category,
            is_custom=False,
            is_approved=True,
            generation_status=Card.GenerationStatus.PENDING,
        )
        created += 1
        
        if created % 10 == 0:
            print(f"Created {created} cards...")
    
    print(f"\nCreated {created} new cards")
    print(f"Skipped {skipped} existing cards")
    return created


def main():
    """Main seeding function."""
    print("Starting database seeding...")
    print("=" * 50)
    
    # Create categories
    print("\n1. Creating categories...")
    categories = create_categories()
    
    # Create cards from dictionary
    print("\n2. Creating cards from offline dictionary...")
    create_cards_from_dictionary(categories)
    
    print("\n" + "=" * 50)
    print("Database seeding completed!")
    print(f"Total categories: {Category.objects.count()}")
    print(f"Total cards: {Card.objects.count()}")


if __name__ == '__main__':
    main()

