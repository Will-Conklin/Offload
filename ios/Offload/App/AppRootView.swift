// Purpose: App entry points and root navigation.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Keep navigation flow consistent with MainTabView -> NavigationStack -> sheets.

import os
import SwiftData
import SwiftUI
import UIKit

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var repositories: RepositoryBundle?
    private let launchCorrelationId = UUID().uuidString

    var body: some View {
        MainTabView()
            .environment(\.itemRepository, repositories?.itemRepository ?? ItemRepository(modelContext: modelContext))
            .environment(\.collectionRepository, repositories?.collectionRepository ?? CollectionRepository(modelContext: modelContext))
            .environment(\.collectionItemRepository, repositories?.collectionItemRepository ?? CollectionItemRepository(modelContext: modelContext))
            .environment(\.tagRepository, repositories?.tagRepository ?? TagRepository(modelContext: modelContext))
            .preferredColorScheme(themeManager.appearancePreference.colorScheme)
            .withToast()
            .task {
                let startupStart = Date()
                let memoryBeforeMigration = MemoryDiagnostics.residentMemoryBytes()
                AppLogger.general.info(
                    "Startup diagnostics begin - launchId: \(self.launchCorrelationId, privacy: .public), memory: \(MemoryDiagnostics.residentMemoryMBString(), privacy: .public)"
                )

                if repositories == nil {
                    repositories = RepositoryBundle.make(modelContext: modelContext)
                    AppLogger.general.info("Repository bundle initialized")
                }

                AppLogger.persistence.info(
                    "Tag migration start - launchId: \(self.launchCorrelationId, privacy: .public), memoryBefore: \(MemoryDiagnostics.residentMemoryMBString(), privacy: .public)"
                )
                let migrationStart = Date()
                do {
                    try TagMigration.runIfNeeded(modelContext: modelContext)
                    let memoryAfterMigration = MemoryDiagnostics.residentMemoryBytes()
                    let migrationDuration = Date().timeIntervalSince(migrationStart)
                    AppLogger.persistence.info(
                        "Tag migration end - launchId: \(self.launchCorrelationId, privacy: .public), durationMs: \(Int((migrationDuration * 1000).rounded()), privacy: .public), memoryAfter: \(MemoryDiagnostics.residentMemoryMBString(), privacy: .public), memoryDelta: \(MemoryDiagnostics.deltaMBString(before: memoryBeforeMigration, after: memoryAfterMigration), privacy: .public)"
                    )
                } catch {
                    AppLogger.general.error("Tag migration failed: \(error.localizedDescription)")
                }

                let startupDuration = Date().timeIntervalSince(startupStart)
                let memoryAfterStartup = MemoryDiagnostics.residentMemoryBytes()
                AppLogger.general.info(
                    "Startup diagnostics end - launchId: \(self.launchCorrelationId, privacy: .public), durationMs: \(Int((startupDuration * 1000).rounded()), privacy: .public), memoryAfter: \(MemoryDiagnostics.residentMemoryMBString(), privacy: .public), memoryDelta: \(MemoryDiagnostics.deltaMBString(before: memoryBeforeMigration, after: memoryAfterStartup), privacy: .public)"
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                let timestamp = Date().ISO8601Format()
                AppLogger.general.warning(
                    "Memory warning received - launchId: \(self.launchCorrelationId, privacy: .public), timestamp: \(timestamp, privacy: .public), residentMemory: \(MemoryDiagnostics.residentMemoryMBString(), privacy: .public)"
                )
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
