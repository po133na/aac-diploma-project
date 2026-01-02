"""
Script to seed translation dictionary with offline dictionary words.
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'backend'))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from apps.ml_integration.models import Translation
from apps.ml_integration.offline_dictionary import get_all_offline_words


def seed_translations():
    """Seed translation dictionary from offline dictionary."""
    dictionary = get_all_offline_words()
    
    created = 0
    skipped = 0
    
    for word_ru, (word_kk, word_en, category) in dictionary.items():
        # Check if translation already exists
        if Translation.objects.filter(word_ru__iexact=word_ru).exists():
            skipped += 1
            continue
        
        Translation.objects.create(
            word_ru=word_ru,
            word_kk=word_kk,
            word_en=word_en,
            category=category,
            is_verified=True,  # Offline dictionary is pre-verified
        )
        created += 1
        
        if created % 10 == 0:
            print(f"Created {created} translations...")
    
    print(f"\nCreated {created} new translations")
    print(f"Skipped {skipped} existing translations")
    return created


def main():
    """Main seeding function."""
    print("Starting translation dictionary seeding...")
    print("=" * 50)
    
    seed_translations()
    
    print("\n" + "=" * 50)
    print("Translation seeding completed!")
    print(f"Total translations: {Translation.objects.count()}")


if __name__ == '__main__':
    main()

