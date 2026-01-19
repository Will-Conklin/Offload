// Purpose: App entry points and root navigation.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Keep navigation flow consistent with MainTabView -> NavigationStack -> sheets.

import SwiftUI
import SwiftData



struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext

    // Create repositories from modelContext
    private var itemRepository: ItemRepository {
        ItemRepository(modelContext: modelContext)
    }

    private var collectionRepository: CollectionRepository {
        CollectionRepository(modelContext: modelContext)
    }

    private var collectionItemRepository: CollectionItemRepository {
        CollectionItemRepository(modelContext: modelContext)
    }

    private var tagRepository: TagRepository {
        TagRepository(modelContext: modelContext)
    }

    var body: some View {
        MainTabView()
            .environment(\.itemRepository, itemRepository)
            .environment(\.collectionRepository, collectionRepository)
            .environment(\.collectionItemRepository, collectionItemRepository)
            .environment(\.tagRepository, tagRepository)
    }
}

#Preview {
    let container = PersistenceController.preview
    let repos = EnvironmentValues.previewRepositories(from: container)

    return AppRootView()
        .environmentObject(ThemeManager.shared)
        .modelContainer(container)
        .environment(\.itemRepository, repos.itemRepository)
        .environment(\.collectionRepository, repos.collectionRepository)
        .environment(\.collectionItemRepository, repos.collectionItemRepository)
        .environment(\.tagRepository, repos.tagRepository)
}
