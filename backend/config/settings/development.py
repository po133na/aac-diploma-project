"""
Development settings for AAC Communication Cards project.
"""
from .base import *

DEBUG = True

# Allow all origins in development
CORS_ALLOW_ALL_ORIGINS = True

# Development database can use SQLite for quick setup
# Uncomment to use SQLite instead of PostgreSQL
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.sqlite3',
#         'NAME': BASE_DIR / 'db.sqlite3',
#     }
# }

