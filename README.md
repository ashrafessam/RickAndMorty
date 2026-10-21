
# Rick & Morty Characters

A SwiftUI app that browses characters from the [Rick and Morty API](https://rickandmortyapi.com):
search, status filter, sorting, pagination, offline caching, and a character detail screen with episodes.

## Screenshots & Demo

Watch the demo video and screenshots in the Screenshots folder


## Setup Instructions

### Requirements
- Xcode 16.0 or later
- iOS 18.0 or later
- Swift 6.0 or later

### Build steps
1. Clone the repository: `git clone https://github.com/ashrafessam/RickAndMorty`
2. Open `RickAndMorty.xcodeproj`.
3. Select the `RickAndMorty` scheme and an iOS 18+ simulator or device.
4. Run with `Cmd + R`. Run unit tests with `Cmd + U`.

### Dependency installation
Dependencies are managed with Swift Package Manager and resolve automatically when the project is opened
(if not: File > Packages > Resolve Package Versions).

| Package | Version | Purpose 
| [Kingfisher](https://github.com/onevcat/Kingfisher) | 8.14.0 | Image loading and caching (memory + disk) |

No API key or other setup is required.

## Architecture Overview

### Pattern: MVVM + Repository
- View (SwiftUI): renders state and forwards user actions.
- ViewModel (`@MainActor @Observable`): owns screen state (loading, errors, pagination, search, filter, sort)
  and depends only on repository protocols.
- Repository: single source of data for the ViewModel. Fetches from the network and caches
  results locally (SwiftData) for offline fallback.
- Core: `APIClient` (URLSession + async/await) and `CharactersLocalStore` (SwiftData).

Data flow: `View -> ViewModel -> Repository -> APIClient / LocalStore`

### Folder structure
```
.
├── README.md
├── RickAndMorty.xcodeproj
├── RickAndMorty/            # App source
│   ├── App/                 # App entry point and dependency wiring
│   ├── Core/
│   │   ├── Networking/      # APIClient, APIConstants, APIError
│   │   └── Persistence/     # CachedCharacter, CharactersLocalStore (SwiftData)
│   ├── Domain/
│   │   ├── Models/          # Character, CharactersPage, CharacterStatus, Episode
│   │   └── Repositories/    # Repository protocols and implementations
│   ├── Features/
│   │   ├── CharacterList/   # CharactersView, CharactersViewModel, CharacterCell
│   │   └── CharacterDetail/ # CharacterDetailView, CharacterDetailViewModel
│   └── Resources/           # Assets
├── RickAndMortyTests/       # Unit tests
├── RickAndMortyUITests/     # UI tests
└── Screenshots/             # Screenshots used in this README
```

### Dependency management
- Constructor injection throughout. ViewModels and repositories depend on protocols
  (`CharactersRepository`, `EpisodesRepository`, `APIClientProtocol`), never on concrete types.
- Protocols let ViewModels be unit tested with mock repositories, with no network or database.
- Third-party dependencies are managed with Swift Package Manager.
- Navigation uses `NavigationStack`.

## Assumptions
- The API is public and needs no authentication. Pagination follows the `info.next` URL returned by the API.
- If a network request fails, the app falls back to locally cached characters.
- The same `Character` model is used across layers (no separate DTO/domain mapping). This is a deliberate
  choice to avoid boilerplate at this scope.
- Minimum supported version is iOS 18.0.

## Accessibility & Appearance
- Text uses system text styles and scales with Dynamic Type.
- Status is conveyed with text, not color alone.
- Semantic colors are used, so Light and Dark Mode are both supported.

## Testing
Unit tests use mock implementations of the repository protocols to cover ViewModel behavior.

## Known Limitations
- Sorting and filtering apply only to the characters loaded so far.