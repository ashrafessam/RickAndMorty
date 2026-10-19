# Rick & Morty Characters

iOS app to browse Rick & Morty characters and view their details and episodes.

## Setup

- Xcode 16.0+
- iOS 18.0+
- Swift 6
- No external dependencies, no API key needed
- Open `RickAndMorty.xcodeproj`, select a simulator, then Run (⌘R)

## Architecture

**Pattern:** MVVM with the Repository pattern, built with SwiftUI and Swift Concurrency (async/await).

- **View**: SwiftUI views that render state only.
- **ViewModel**: `@MainActor` classes that own the screen state and logic (pagination, de-duplication, loading/error/empty states).
- **Repository**: protocols live in the Domain layer. ViewModels depend on the protocol, never on the network or storage directly.
- **Networking**: a dedicated networking layer that maps failures to a typed error.

### Folder structure

```
RickAndMorty/
├── App/              # App entry point
├── Core/
│   ├── Networking/   # HTTP client, endpoints, errors
│   └── Persistence/  # Local cache for offline viewing
├── Domain/
│   ├── Models/       # Character, Episode
│   └── Repositories/ # Repository protocols
└── Features/
    ├── CharacterList/    # List screen (View + ViewModel)
    └── CharacterDetail/  # Details screen (View + ViewModel)
```

### Dependency management

Constructor injection throughout. Every dependency is behind a protocol so it can be replaced with a mock in tests.

### Models

Domain models conform to `Decodable` directly with a custom `init(from:)`, instead of having a separate DTO layer. This keeps the codebase small for the scope of this project.