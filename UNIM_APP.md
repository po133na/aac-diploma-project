# Unim — AAC-приложение для детей с нарушениями речи

## Что такое приложение

**Unim** — мобильное iOS-приложение класса AAC (Augmentative and Alternative Communication), предназначенное для детей с аутизмом и нарушениями речи. Приложение позволяет ребёнку общаться с помощью визуальных карточек: нажатием на карточку формируется предложение, которое приложение зачитывает вслух.

Приложение написано на **SwiftUI** (iOS 17+) с архитектурой **MVVM** и backend-взаимодействием через REST API.

---

## Основной функционал

### Карточки (Cards)

- **20 базовых карточек** доступны всем пользователям из системной категории «Basics» — без генерации.
- Пользователь может создавать свои карточки тремя способами:
  - **AI-генерация**: ввести слово/описание → AI создаёт изображение (стили: Cartoon, Realistic, Watercolor, Simple).
  - **Камера**: сфотографировать объект и назвать карточку.
  - **Галерея**: выбрать фото из библиотеки.
- Карточки хранятся на сервере в формате base64 PNG.
- Каждая карточка поддерживает 3 языка (ru / kk / en): поля `word_ru`, `word_kk`, `word_en`.
- Карточки можно переименовывать, удалять, добавлять в категории.

### Конструктор предложений (Sentence Builder)

- Главный экран — строитель предложений: пользователь нажимает на карточки, они добавляются как «токены» в верхнюю панель.
- Можно также напечатать текст вручную.
- Кнопка **Speak** произносит собранное предложение через TTS.

### Text-to-Speech (TTS)

- Приоритет: серверный TTS через `POST /tts/card/{id}` или `POST /tts` (возвращает base64 MP3).
- Fallback: `AVSpeechSynthesizer` — работает офлайн.
- Поддерживает языки: русский (`ru-RU`), казахский (`kk-KZ`), английский (`en-US`).
- Можно озвучить отдельную карточку, набранное предложение или сохранённую фразу.

### Категории (Categories)

- Системные категории: созданы бэкендом, доступны всем (например, «Basics», «Без категории»/Unassigned).
- Пользовательские категории: создаются в мастере из 4 шагов:
  1. Ввод названия.
  2. AI-генерация обложки (или выбор из галереи / повторная генерация).
  3. Добавление карточек из пула «Без категории».
  4. Сохранение.
- Каждая категория имеет имя на трёх языках, emoji-иконку и обложку (base64).
- Категорию можно удалить (кроме системных).

### Профиль и аналитика

- Страница профиля (`ProfileView`) содержит:
  - Данные пользователя (имя, email).
  - **ActivityCard** со статистикой: всего карточек, фраз, использований; топ-5 карточек и фраз; недельный bar-chart; текущий streak.
  - Настройки: смена языка, переключение темы (светлая / тёмная).
  - Выход из аккаунта и удаление аккаунта.

### Аутентификация

- Регистрация (2 шага), логин, восстановление пароля.
- При первом запуске — выбор языка интерфейса.
- Токен сохраняется в `UserDefaults`/Keychain.

### iOS Widget (AACWidget)

- Отдельный target `AACWidget` — WidgetKit расширение.
- Показывает недавние карточки на домашнем экране.
- Данные передаются через `WidgetDataManager` (App Group).

### Туториал

- `TutorialManager` + `TutorialOverlayView` — пошаговый онбординг для новых пользователей.
- Анкоры: `plusButton`, `speakButton`, `tapCard`, `longPressCard`, `statsTab`, `languageTheme`.

---

## Архитектура

### Структура папок

```
diploma2/
├── UnimApp.swift              — точка входа (@main)
├── AppDelegate.swift
├── ContentView.swift
├── Stubs.swift                — моковые данные для Preview
│
├── Core/
│   ├── DI/
│   │   └── AppContainer.swift  — (зарезервировано под DI-контейнер)
│   ├── Navigation/
│   │   ├── MainTabView.swift   — корневой таб-бар (Home / Settings)
│   │   ├── AppRouter.swift
│   │   └── TabRoutes.swift
│   ├── Theme/
│   │   ├── AppColors.swift     — семантические цвета (статические обёртки)
│   │   ├── AppTheme.swift      — ThemeManager (@Published colorScheme)
│   │   └── AppFonts.swift
│   ├── Extensions/
│   │   ├── View+Ext.swift      — .tutorialAnchor(), .if()
│   │   ├── Color+Ext.swift     — Color(hex:)
│   │   └── String+Ext.swift
│   └── Tutorial/
│       └── TutorialOverlay.swift
│
├── Models/
│   ├── Domain/
│   │   ├── Models.swift        — User, Card, Category, Phrase, Stats, AppLanguage
│   │   ├── Card.swift
│   │   ├── Folder.swift
│   │   └── User.swift
│   └── SwiftData/              — локальные SD-модели (офлайн кэш)
│       ├── SDCard.swift
│       ├── SDFolder.swift
│       ├── SDUser.swift
│       └── SDPhrase.swift
│
├── Services/
│   ├── Services.swift          — CardService, CategoryService, PhraseService, TTSService, StatsService
│   ├── Network/
│   │   ├── APIClient.swift     — URLSession-обёртка, авторизация через Bearer token
│   │   ├── APIEndpoints.swift  — enum APIEndpoint с path/method/body
│   │   └── NetworkMonitor.swift
│   ├── Auth/
│   │   └── AuthService.swift
│   ├── Cache/
│   │   └── CacheService.swift
│   ├── Camera/
│   │   └── CameraService.swift
│   ├── ImageGen/
│   │   └── ImageGenService.swift
│   ├── TTS/
│   │   └── TTSService.swift
│   ├── Sync/
│   │   ├── SyncService.swift
│   │   └── PendingActionQueue.swift
│   └── WidgetDataManager.swift
│
├── Features/
│   ├── Auth/
│   │   ├── Models/AuthModels.swift
│   │   ├── ViewModels/AuthViewModel.swift
│   │   └── Views/
│   │       ├── AuthRootView.swift
│   │       ├── LoginView.swift
│   │       ├── RegisterStep1View.swift
│   │       ├── RegisterStep2View.swift
│   │       ├── RegisterSuccessView.swift
│   │       ├── ForgotPasswordView.swift
│   │       ├── LanguageSelectView.swift
│   │       └── Components/AuthComponents.swift
│   ├── Home/
│   │   ├── ViewModels/HomeViewModel.swift
│   │   └── Views/
│   │       ├── HomeView.swift          — главный экран + SentenceBuilderBar
│   │       ├── CardManagerView.swift   — мастер создания карточек/категорий
│   │       └── CardGridView.swift
│   ├── Gallery/
│   │   ├── ViewModels/GalleryViewModel.swift
│   │   └── Views/
│   │       ├── GalleryView.swift
│   │       ├── FolderView.swift
│   │       └── SavedCardView.swift
│   └── Profile/
│       └── Views/ProfileView.swift     — профиль, статистика, настройки
│
└── Resources/
    ├── en.lproj/Localizable.strings
    ├── ru.lproj/Localizable.strings
    ├── kk.lproj/Localizable.strings
    └── Assets.xcassets/               — цвета light/dark, изображения
```

### Паттерн MVVM

| Слой | Роль |
|---|---|
| **View** | SwiftUI-экраны и компоненты, только UI-логика |
| **ViewModel** | `@ObservableObject`, хранит состояние, вызывает сервисы, форматирует данные для View |
| **Service** | Сетевые вызовы, бизнес-логика, синглтоны (`static let shared`) |
| **Model** | `Codable`-структуры, соответствующие JSON бэкенда |

### Навигация

```
UnimApp
 └── ContentView
      ├── AuthRootView          (если не авторизован)
      │    ├── LanguageSelectView
      │    ├── LoginView
      │    ├── RegisterStep1/2View
      │    └── ForgotPasswordView
      └── MainTabView           (если авторизован)
           ├── HomeView          (tab: Home)
           │    └── CardManagerView  (sheet: создание карточек/категорий)
           └── ProfileView       (tab: Settings)
```

### Передача состояния

- `AuthViewModel` — через `@EnvironmentObject` на весь стек.
- `HomeViewModel` — создаётся в `MainTabView` как `@StateObject`, передаётся через `environmentObject`.
- `ThemeManager.shared` и `LocalizationManager.shared` — глобальные синглтоны, также через `@EnvironmentObject`.

---

## Сервисный слой

### APIClient

Централизованный HTTP-клиент (`Services/Network/APIClient.swift`):
- Bearer-авторизация (токен из UserDefaults).
- Дженерик-методы `request<T: Decodable>` и `requestVoid`.
- Поддержка query-параметров, кастомного timeout, произвольного тела запроса.
- JSON-декодирование с `iso8601` стратегией дат.

### Основные сервисы

| Сервис | Отвечает за |
|---|---|
| `CardService` | CRUD карточек, генерация (AI), пересохранение, счётчик использований |
| `CategoryService` | CRUD категорий, загрузка/генерация обложки, bulk-назначение карточек |
| `PhraseService` | Сохранённые фразы (набор card_ids), использование, TTS фразы |
| `TTSService` | Озвучка: API → fallback AVSpeechSynthesizer; поддержка токенов с разными языками |
| `StatsService` | `GET /user/statistics` → `UserStats` |
| `AuthService` | Логин, регистрация, logout |
| `ImageGenService` | `POST /cards/generate` — AI-генерация изображения |
| `SyncService` | Дельта-синхронизация при восстановлении сети |
| `CacheService` | Локальное кэширование данных |
| `WidgetDataManager` | Передача данных в WidgetKit через App Group |

---

## Модели данных

### Card

```swift
struct Card: Identifiable, Codable {
    let id: Int
    var word: String          // основное слово
    var wordRu: String?       // перевод RU
    var wordKk: String?       // перевод KK
    var wordEn: String?       // перевод EN
    var language: String      // "ru" | "kk" | "en"
    var imageBase64: String   // PNG base64
    var isFavorite: Bool
    var usageCount: Int
    var categoryId: Int?
    var userId: Int?          // nil = системная карточка
}
```

### Category

```swift
struct Category: Identifiable, Codable {
    let id: Int
    var name: String          // RU название
    var nameKk: String?
    var nameEn: String?
    var icon: String?         // emoji
    var coverImageBase64: String?
    var userId: Int?          // nil = системная категория
    var isSystem: Bool { userId == nil }
}
```

### UserStats

```swift
struct UserStats: Codable {
    let totalCards: Int
    let totalCardUses: Int
    let topCards: [TopCard]
    let topPhrases: [TopPhrase]
    let currentStreak: Int
    let weeklyData: [Double]? // 7 значений для бар-чарта
}
```

---

## Тема и локализация

### Темы (AppTheme)

- Две схемы: **светлая** и **тёмная**.
- Все цвета определены в `Assets.xcassets` как именованные Color Set с вариантами `Any` и `Dark`.
- Ключевые цвета:

| Имя | Светлая | Тёмная | Роль |
|---|---|---|---|
| `AppBg` | #EAF4FB | #0F1B24 | Основной фон |
| `AppSurface` | #FFFFFF | #1C2B38 | Карточки / шиты |
| `AppTextPrimary` | #1C3F6E | #D8EEFB | Основной текст |
| `AppTextSecondary` | #6B8BAE | #7A9AB5 | Подзаголовки |
| Акцент (кнопки) | #5BAECC | #5BAECC | CTA-кнопки |

### Локализация (LocalizationManager)

- `LocalizationManager` — `@ObservableObject` синглтон.
- Хранит `currentLanguage: AppLanguage` (`kk` / `ru` / `en`).
- Файлы строк: `en.lproj/Localizable.strings`, `ru.lproj/Localizable.strings`, `kk.lproj/Localizable.strings`.
- Все UI-тексты обращаются к `LocalizationManager.shared.someKey`.
- Карточки и категории хранят название на каждом языке отдельно (`wordRu`, `wordKk`, `wordEn`); метод `localizedWord(language:)` выбирает нужное.

---

## REST API

Базовый URL задаётся в `APIClient`. Все запросы — JSON, авторизация Bearer.

| Метод | Путь | Описание |
|---|---|---|
| POST | `/auth/login` | Вход |
| POST | `/auth/register` | Регистрация |
| POST | `/auth/logout` | Выход |
| GET | `/user/profile` | Профиль |
| PATCH | `/user/profile` | Обновить профиль |
| GET | `/cards` | Список карточек (фильтры: category_id, favorites_only, search) |
| POST | `/cards` | Создать карточку |
| POST | `/cards/generate` | AI-генерация карточки |
| POST | `/cards/save` | Сохранить карточку (из галереи) |
| PATCH | `/cards/{id}` | Обновить карточку |
| DELETE | `/cards/{id}` | Удалить |
| POST | `/cards/{id}/use` | Инкремент счётчика |
| POST | `/cards/{id}/regenerate` | Перегенерировать изображение |
| GET | `/categories` | Список категорий |
| POST | `/categories` | Создать категорию |
| DELETE | `/categories/{id}` | Удалить |
| POST | `/categories/{id}/cover` | Загрузить обложку |
| POST | `/categories/{id}/cover/generate` | AI-генерация обложки |
| POST | `/categories/{id}/cards` | Bulk-назначение карточек |
| POST | `/tts` | TTS текста → base64 MP3 |
| POST | `/tts/card/{id}` | TTS карточки |
| GET | `/user/statistics` | Статистика пользователя |

---

## Поток создания карточки (AI)

```
CardManagerView
 └── CreateCardFlow (sheet)
      Step 1: Выбор источника (AI / Камера / Галерея)
      Step 2: Описание изображения + выбор стиля
            → ImageGenService.generateImage(word, language, style)
            → POST /cards/generate  →  Card{id, imageBase64}
      Step 3: Превью → Сохранить / Перегенерировать
      Step 4: Назвать карточку
      Step 5: Выбрать категорию → PATCH /cards/{id}
      Step 6: Успех
```

## Поток создания категории

```
CreateCategoryFlow (sheet)
 Step 1: Название категории
 Step 2: Автоматическая AI-генерация обложки
       → POST /categories  →  Category
       → POST /categories/{id}/cover/generate
 Step 3: Превью обложки (перегенерировать / выбрать из галереи)
 Step 4: Добавить карточки из пула "Без категории"
 Step 5: Сохранение → bulk-назначение карточек
 Step 6: Успех
```
