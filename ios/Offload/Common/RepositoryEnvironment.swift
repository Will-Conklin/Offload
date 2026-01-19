// Purpose: Environment keys for repository dependency injection.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: All views should access repositories through environment, not create them directly.

import SwiftUI
import SwiftData


// MARK: - Environment Keys

private struct ItemRepositoryKey: EnvironmentKey {
    static let defaultValue: ItemRepository? = nil
}

private struct CollectionRepositoryKey: EnvironmentKey {
    static let defaultValue: CollectionRepository? = nil
}

private struct CollectionItemRepositoryKey: EnvironmentKey {
    static let defaultValue: CollectionItemRepository? = nil
}

private struct TagRepositoryKey: EnvironmentKey {
    static let defaultValue: TagRepository? = nil
}


// MARK: - Environment Values Extension

extension EnvironmentValues {
    var itemRepository: ItemRepository {
        get { self[ItemRepositoryKey.self] ?? fatalError("ItemRepository not injected") }
        set { self[ItemRepositoryKey.self] = newValue }
    }

    var collectionRepository: CollectionRepository {
        get { self[CollectionRepositoryKey.self] ?? fatalError("CollectionRepository not injected") }
        set { self[CollectionRepositoryKey.self] = newValue }
    }

    var collectionItemRepository: CollectionItemRepository {
        get { self[CollectionItemRepositoryKey.self] ?? fatalError("CollectionItemRepository not injected") }
        set { self[CollectionItemRepositoryKey.self] = newValue }
    }

    var tagRepository: TagRepository {
        get { self[TagRepositoryKey.self] ?? fatalError("TagRepository not injected") }
        set { self[TagRepositoryKey.self] = newValue }
    }
}


// MARK: - Preview Helpers

#if DEBUG
extension EnvironmentValues {
    /// Create repositories from a preview ModelContainer
    static func previewRepositories(from container: ModelContainer) -> (
        itemRepository: ItemRepository,
        collectionRepository: CollectionRepository,
        collectionItemRepository: CollectionItemRepository,
        tagRepository: TagRepository
    ) {
        let context = container.mainContext
        return (
            itemRepository: ItemRepository(modelContext: context),
            collectionRepository: CollectionRepository(modelContext: context),
            collectionItemRepository: CollectionItemRepository(modelContext: context),
            tagRepository: TagRepository(modelContext: context)
        )
    }
}
#endif
