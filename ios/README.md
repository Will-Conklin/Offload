# Offload iOS App

SwiftUI iOS application for Offload - a friction-free thought capture and organization tool.

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-green.svg)](https://developer.apple.com/xcode/swiftui/)

## Table of Contents

- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Development Status](#development-status)
- [Building & Running](#building--running)
- [Testing](#testing)

## Project Structure

```text
Offload/
├── App/                    # Application entry point & root navigation
├── Features/               # Feature modules organized by screen/flow
│   ├── Inbox/             # Inbox view & related components
│   ├── Capture/           # Quick capture flow (text + voice)
│   └── Organize/          # Organization views (projects, tags, categories)
├── Domain/                 # Business logic & models (SwiftData)
│   └── Models/            # Task, Project, Tag, Category, Thought
├── Data/                   # Data layer
│   ├── Persistence/       # SwiftData configuration & PersistenceController
│   ├── Repositories/      # Data access patterns (TaskRepository, ProjectRepository)
│   └── Services/          # VoiceRecordingService, AI services
├── DesignSystem/          # UI components, theme, design tokens
├── Resources/             # Assets, fonts, etc.
└── SupportingFiles/       # Info.plist, entitlements
```

## Architecture

### Feature-Based Organization

The app is organized by feature rather than technical layer:

- Each feature has its own directory under `Features/`
- Features contain views, view models, and feature-specific components
- Shared UI components live in `DesignSystem/`
- Business logic and models live in `Domain/`

### Data Flow

```mermaid
graph LR
    subgraph "Presentation Layer"
        VIEW[SwiftUI Views]
    end

    subgraph "Data Layer"
        REPO[Repositories]
        VOICE[VoiceRecordingService]
    end

    subgraph "Persistence Layer"
        DB[(SwiftData)]
    end

    VIEW -->|@Query| DB
    VIEW --> REPO
    VIEW --> VOICE
    REPO --> DB
    VOICE --> DB
```

1. **Domain Layer**: Models defined with SwiftData `@Model` macro
2. **Data Layer**: Repositories provide CRUD operations and queries
3. **Feature Layer**: Views use `@Query` for reactive data or repositories for complex operations

### SwiftData Models

All models use the `@Model` macro with comprehensive relationships:

- **Task**: Core task model with project, category, tags, blockedBy, and sourceThought relationships
- **Project**: Hierarchical project organization with tasks
- **Tag**: Many-to-many tagging system
- **Category**: Single-category assignment per task
- **Thought**: Captured thoughts with derivedTasks tracking

See [../docs/decisions/ADR-0001-stack.md](../docs/decisions/ADR-0001-stack.md) for detailed architecture decisions.

## Development Status

🚧 **Active Development** - See main [README](../README.md) for detailed implementation status.

### Architecture Implementation

- ✅ SwiftData models with complete relationships
- ✅ Repository pattern for data access
- ✅ Voice recording with real-time transcription
- ✅ Comprehensive unit tests (45+ tests)
- 🔄 UI implementation in progress

### Key Features

- **Offline-First**: All data stored locally with SwiftData
- **Voice Capture**: On-device speech recognition (iOS 17+)
- **Type-Safe Queries**: Repository pattern with SwiftData predicates
- **Comprehensive Testing**: Unit tests for all data layer operations

## Building & Running

1. Open `Offload.xcodeproj` in Xcode
2. Select a simulator or device
3. Press Cmd+R to build and run

## Testing

### Running Tests

Run tests with ⌘U in Xcode.

### Test Coverage

- **TaskRepositoryTests**: 25 unit tests covering CRUD operations, queries, relationships
- **ProjectRepositoryTests**: 20 unit tests covering CRUD, queries, delete rules
- **In-memory ModelContainer**: All tests use isolated test database
- **Performance Tests**: Benchmarks for query operations with 100+ items

### Test Framework

Tests use XCTest with the `@MainActor` annotation for SwiftData compatibility:

- Define tests with `func test...()` methods
- Use `XCTAssertEqual`, `XCTAssertTrue`, etc. for assertions
- `setUp` and `tearDown` methods for test isolation

### Adding Tests to Xcode

Test files need manual integration with Xcode:

1. Right-click `OffloadTests` folder → "Add Files to 'Offload'..."
2. Select test files from `ios/OffloadTests/`
3. Ensure "OffloadTests" target is checked
4. Run tests with ⌘U

See main [README](../README.md#running-tests) for detailed testing instructions.
