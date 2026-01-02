#!/usr/bin/env python
"""
Simple API testing script for AAC Communication Cards System.
Usage: python test_api.py
"""
import requests
import json
import sys
import os

# Configuration
BASE_URL = os.environ.get('API_BASE_URL', 'http://localhost:8000/api/v1')
TOKEN = os.environ.get('API_TOKEN', '')

if not TOKEN:
    print("ERROR: Please set API_TOKEN environment variable")
    print("Example: export API_TOKEN='your-token-here'")
    sys.exit(1)

headers = {
    "Authorization": f"Token {TOKEN}",
    "Content-Type": "application/json"
}

def print_response(title, response):
    """Print formatted response."""
    print(f"\n{'='*60}")
    print(f"{title}")
    print(f"{'='*60}")
    print(f"Status: {response.status_code}")
    try:
        print(json.dumps(response.json(), indent=2, ensure_ascii=False))
    except:
        print(response.text)

def test_cards():
    """Test cards endpoints."""
    print("\n" + "="*60)
    print("TESTING CARDS ENDPOINTS")
    print("="*60)
    
    # List cards
    response = requests.get(f"{BASE_URL}/cards/", headers=headers)
    print_response("1. List Cards", response)
    
    if response.status_code == 200:
        cards = response.json().get('results', [])
        if cards:
            card_id = cards[0]['card_id']
            
            # Get single card
            response = requests.get(f"{BASE_URL}/cards/{card_id}/", headers=headers)
            print_response("2. Get Single Card", response)
            
            # Track usage
            response = requests.post(
                f"{BASE_URL}/cards/{card_id}/use/",
                headers=headers,
                json={"language": "ru"}
            )
            print_response("3. Track Card Usage", response)
            
            # Toggle favorite
            response = requests.post(
                f"{BASE_URL}/cards/{card_id}/toggle-favorite/",
                headers=headers
            )
            print_response("4. Toggle Favorite", response)
    
    # Search cards
    response = requests.get(f"{BASE_URL}/cards/?search=яблоко", headers=headers)
    print_response("5. Search Cards", response)
    
    # Popular cards
    response = requests.get(f"{BASE_URL}/cards/popular/", headers=headers)
    print_response("6. Popular Cards", response)
    
    # Generate new card
    response = requests.post(
        f"{BASE_URL}/cards/generate/",
        headers=headers,
        json={
            "word": "солнце",
            "source_lang": "ru"
        }
    )
    print_response("7. Generate Card", response)

def test_categories():
    """Test categories endpoints."""
    print("\n" + "="*60)
    print("TESTING CATEGORIES ENDPOINTS")
    print("="*60)
    
    response = requests.get(f"{BASE_URL}/categories/", headers=headers)
    print_response("1. List Categories", response)

def test_analytics():
    """Test analytics endpoints."""
    print("\n" + "="*60)
    print("TESTING ANALYTICS ENDPOINTS")
    print("="*60)
    
    # Stats
    response = requests.get(f"{BASE_URL}/analytics/stats/", headers=headers)
    print_response("1. User Statistics", response)
    
    # Activity
    response = requests.get(f"{BASE_URL}/analytics/activity/?days=7", headers=headers)
    print_response("2. Activity Chart (7 days)", response)
    
    # Popular
    response = requests.get(f"{BASE_URL}/analytics/popular/", headers=headers)
    print_response("3. User Popular Cards", response)
    
    # Categories
    response = requests.get(f"{BASE_URL}/analytics/categories/", headers=headers)
    print_response("4. Category Breakdown", response)
    
    # Recommendations
    response = requests.get(f"{BASE_URL}/analytics/recommendations/", headers=headers)
    print_response("5. Recommendations", response)
    
    # Translator stats
    response = requests.get(f"{BASE_URL}/translator-stats/", headers=headers)
    print_response("6. Translation Statistics", response)

def test_users():
    """Test user endpoints."""
    print("\n" + "="*60)
    print("TESTING USER ENDPOINTS")
    print("="*60)
    
    # Get profile
    response = requests.get(f"{BASE_URL}/users/me/", headers=headers)
    print_response("1. Get User Profile", response)
    
    # Update language
    response = requests.patch(
        f"{BASE_URL}/users/language/",
        headers=headers,
        json={"language": "kk"}
    )
    print_response("2. Update Language", response)

def main():
    """Run all tests."""
    print("\n" + "="*60)
    print("AAC COMMUNICATION CARDS - API TESTING")
    print("="*60)
    print(f"Base URL: {BASE_URL}")
    print(f"Token: {TOKEN[:20]}...")
    
    try:
        test_categories()
        test_cards()
        test_analytics()
        test_users()
        
        print("\n" + "="*60)
        print("TESTING COMPLETE")
        print("="*60)
        
    except requests.exceptions.ConnectionError:
        print("\nERROR: Could not connect to API server")
        print("Make sure Django server is running on http://localhost:8000")
        sys.exit(1)
    except Exception as e:
        print(f"\nERROR: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()

