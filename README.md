# 🎬 Reels App — Flutter MVVM Clean Architecture

A production-ready, interview-quality Flutter app that replicates Instagram/TikTok-style short video reels. Built with **Clean Architecture**, **MVVM**, and best-practice patterns throughout.

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # App-wide magic values
│   ├── di/
│   │   └── service_locator.dart        # GetIt dependency injection setup
│   ├── errors/
│   │   ├── exceptions.dart             # Data-layer exceptions
│   │   └── failures.dart               # Domain-layer failures
│   └── utils/
│       ├── app_logger.dart             # Centralized logger (Logger pkg)
│       ├── either.dart                 # Functional Either<L,R> type
│       └── format_utils.dart           # Number formatting (1.2K, 4.5M)
│
├── data/                               # DATA LAYER
│   ├── datasources/
│   │   ├── local/
│   │   │   └── video_cache_datasource.dart   # File-based video cache (MD5 keys)
│   │   └── remote/
│   │       └── reels_remote_datasource.dart  # Firestore reads/writes
│   ├── models/
│   │   └── reel_model.dart             # Firestore ↔ Entity mapper
│   └── repositories/
│       └── reels_repository_impl.dart  # Concrete repo implementation
│
├── domain/                             # DOMAIN LAYER (pure Dart)
│   ├── entities/
│   │   └── reel_entity.dart            # Immutable domain entity
│   ├── repositories/
│   │   └── reels_repository.dart       # Abstract contract
│   └── usecases/
│       ├── fetch_reels_usecase.dart    # Paginated fetch
│       ├── toggle_like_usecase.dart    # Like/unlike with Firestore
│       └── cache_video_usecase.dart    # Cache video to disk
│
├── presentation/                       # PRESENTATION LAYER (MVVM)
│   ├── viewmodels/
│   │   ├── reels_viewmodel.dart        # Core ChangeNotifier ViewModel
│   │   └── video_controller_state.dart # Per-video controller holder
│   ├── views/
│   │   └── reels_screen.dart           # Single screen (PageView)
│   └── widgets/
│       ├── reel_page_item.dart         # Full-screen reel container
│       ├── reel_video_player.dart      # VideoPlayer with loading/error states
│       ├── reel_info_overlay.dart      # Username, caption, follow button
│       ├── reel_action_bar.dart        # Like, comment, share, mute, vinyl
│       ├── reel_avatar.dart            # Cached circular avatar
│       ├── scrolling_audio_label.dart  # TikTok-style marquee audio label
│       ├── reels_initial_loader.dart   # Shimmer skeleton
│       └── reels_error_widget.dart     # Error state with retry
│
└── main.dart                           # Entry point + DI bootstrap

test/
├── core/utils/
│   ├── either_test.dart
│   └── format_utils_test.dart
├── data/repositories/
│   └── reels_repository_impl_test.dart
├── domain/usecases/
│   └── usecases_test.dart
└── presentation/viewmodels/
    └── reels_viewmodel_test.dart
```

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────┐
│           PRESENTATION LAYER             │
│   ReelsScreen  ←→  ReelsViewModel        │
│        ↑               ↑                 │
│    Widgets        ChangeNotifier         │
└──────────────────────┬───────────────────┘
                       │ uses
┌──────────────────────▼───────────────────┐
│             DOMAIN LAYER                 │
│   FetchReelsUseCase                      │
│   ToggleLikeUseCase    (pure Dart)       │
│   CacheVideoUseCase                      │
│         ↑                                │
│   ReelsRepository (abstract)             │
└──────────────────────┬───────────────────┘
                       │ implements
┌──────────────────────▼───────────────────┐
│              DATA LAYER                  │
│   ReelsRepositoryImpl                    │
│        ├── ReelsRemoteDataSource (Firestore)
│        └── VideoCacheDataSource (disk)   │
└──────────────────────────────────────────┘
```

### Key Architectural Decisions

| Decision | Choice | Why |
|---|---|---|
| State management | `Provider` + `ChangeNotifier` | Simple, testable, no boilerplate |
| Error handling | `Either<Failure, T>` | Functional, no exception leakage across layers |
| DI | `GetIt` | Compile-safe, no context needed |
| Caching | MD5-keyed local files | Deterministic, fast cache-hits |
| Video preload | 3 ahead, 1 behind | Memory vs UX sweet spot |
| Optimistic updates | Reverted on failure | Perceived performance |

---

## ✨ Features

- **Vertical PageView** — full-screen swipeable reels
- **Auto-play / pause** — based on current page
- **App lifecycle awareness** — pauses on background, resumes on foreground
- **Video preloading** — 3 videos ahead + 1 behind always initialized
- **Video caching** — MD5-keyed files, LRU eviction (20 videos / 500 MB cap)
- **Optimistic like** — instant UI, reverts on network failure
- **Double-tap to like** — animated heart burst at tap position
- **Shimmer skeleton** — while initial data loads
- **Expandable caption** — tap to expand long captions
- **Scrolling audio label** — TikTok-style marquee
- **Spinning vinyl record** — rotating audio disc
- **Follow button** — local toggle state
- **Mute/unmute** — affects all active controllers

---

## 🚀 Setup

### 1. Firebase

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure for your project
flutterfire configure
```


### 2. Firestore Collection

Schema for the `reels` collection:

```
reels/{docId}
  videoUrl:      String   # Direct video URL (Firebase Storage or CDN)
  thumbnailUrl:  String   # Preview image URL
  username:      String
  avatarUrl:     String
  caption:       String
  audioName:     String
  likesCount:    Number
  commentsCount: Number
  sharesCount:   Number
  createdAt:     Timestamp
```

### 3. Seed data

```bash
cd scripts
npm install firebase-admin
# Place your serviceAccountKey.json in scripts/
node seed_firestore.js
```

### 4. Run the app

```bash
flutter pub get
flutter run
```

---

## 🧪 Running Tests

```bash
# Generate mocks first
flutter pub run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `firebase_core` + `cloud_firestore` | Firestore data source |
| `video_player` | Platform video playback |
| `provider` | MVVM state management |
| `get_it` | Service locator / DI |
| `http` + `path_provider` | Video download + local storage |
| `crypto` | MD5 cache key generation |
| `cached_network_image` | Efficient image caching |
| `shimmer` | Loading skeleton animation |
| `equatable` | Value equality on entities |
| `logger` | Structured debug logging |
| `mockito` + `build_runner` | Test mock generation |

---

## 🎯 Interview Talking Points

1. **Why Clean Architecture?** — Each layer has a single responsibility. The domain layer is pure Dart with zero framework dependencies, making it trivially testable. Swapping Firestore for a REST API only touches the data layer.

2. **Why `Either<L, R>` instead of try/catch?** — Failures become first-class return values. The compiler forces callers to handle both cases. No accidental unhandled exceptions.

3. **How does preloading work?** — `_initializeControllersAround(index)` keeps a sliding window of controllers. When you land on index 5, controllers for 4–8 are initialized and 3–9 is the safe zone. Controllers outside that window are disposed to free memory.

4. **How does caching prevent re-downloads?** — Videos are downloaded once, stored as `{md5(url)}.mp4` in the temp directory, and served as local file:// URIs on subsequent plays. An LRU eviction policy keeps the cache under 500 MB.

5. **Why optimistic updates?** — Liking feels instant. We update the UI immediately, fire the Firestore write in the background, and revert only if the network call fails. This is the same pattern Instagram uses.
