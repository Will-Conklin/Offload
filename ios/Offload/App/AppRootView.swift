// Purpose: App entry points and root navigation.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Keep navigation flow consistent with MainTabView -> NavigationStack -> sheets.

import os
import SwiftData
import SwiftUI

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var repositories: RepositoryBundle?

    var body: some View {
        MainTabView()
            .environment(\.itemRepository, repositories?.itemRepository ?? ItemRepository(modelContext: modelContext))
            .environment(\.collectionRepository, repositories?.collectionRepository ?? CollectionRepository(modelContext: modelContext))
            .environment(\.collectionItemRepository, repositories?.collectionItemRepository ?? CollectionItemRepository(modelContext: modelContext))
            .environment(\.tagRepository, repositories?.tagRepository ?? TagRepository(modelContext: modelContext))
            .preferredColorScheme(themeManager.appearancePreference.colorScheme)
            .withToast()
            .task {
                if repositories == nil {
                    repositories = RepositoryBundle.make(modelContext: modelContext)
                    AppLogger.general.info("Repository bundle initialized")
                }
                do {
                    try TagMigration.runIfNeeded(modelContext: modelContext)
                } catch {
                    AppLogger.general.error("Tag migration failed: \(error.localizedDescription)")
                }
            }
    }
}

#Preview {
    let container = PersistenceController.preview
    let repos = RepositoryBundle.preview(from: container)

    return AppRootView()
        .environmentObject(ThemeManager.shared)
        .modelContainer(container)
        .environment(\.itemRepository, repos.itemRepository)
        .environment(\.collectionRepository, repos.collectionRepository)
        .environment(\.collectionItemRepository, repos.collectionItemRepository)
        .environment(\.tagRepository, repos.tagRepository)
}
