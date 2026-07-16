│   ├── repositories/       # Interfaces for repositories
│   └── usecases/           # Specific feature usecases
├── presentation/           # Presentation layer
│   ├── app.dart            # Main app widget
│   ├── routing/            # GoRouter configuration
│   ├── state/              # Global Riverpod providers
│   └── features/           # UI grouped by feature
└── main.dart               # Entry point
```

## 🛠 Dependencies

Key dependencies include:
- `flutter_riverpod`, `go_router`, `get_it`, `drift`, `sqlite3_flutter_libs`
- `flutter_secure_storage`, `local_auth`, `encrypt`
- `google_fonts`, `lucide_icons`

See `pubspec.yaml` for the complete list.

## 🚀 Build Instructions

1. Ensure you have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
2. Clone this repository and navigate to the project directory.
3. If the Android/iOS boilerplate is missing (since this was scaffolded without the Flutter CLI), run:
   ```bash
   flutter create .
   ```
4. Get dependencies:
   ```bash
   flutter pub get
   ```
5. Run build_runner (for Freezed, Injectable, and Drift code generation - *when applicable*):
   ```bash
   dart run build_runner build -d
   ```
6. Run the app:
   ```bash
   flutter run
   ```

## 🗺 Roadmap

### Phase 1 (MVP) - *Currently Building*
Core note-taking, file management, voice recording, image/OCR capture, universal search, on-device/cloud hybrid AI, security, and onboarding. 

### Phase 2 (Knowledge & Recall)
Knowledge graph, smart auto-tagging/categorization, relationship and duplicate detection, meeting mode (one-tap record → transcribe → summarize → extract tasks), memory recall ("what was I working on in November?"), voice assistant, home-screen widgets, share-sheet quick capture, calendar/reminder OS integration, flashcard export to Anki, PDF annotations.

### Phase 3 (Cloud & Collaboration)
Cloud sync (FastAPI + PostgreSQL + object storage) with conflict resolution, cross-device continuity, collaborative/shared vaults with per-user permissions, a documented plugin/API layer, browser extension, desktop app, smartwatch companion, advanced knowledge graph visualization, team workspace tier.
