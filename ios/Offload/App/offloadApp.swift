// Purpose: App entry points and root navigation.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Keep navigation flow consistent with MainTabView -> NavigationStack -> sheets.

import SwiftUI
import SwiftData



@main
struct OffloadApp: App {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(themeManager)
        }
        .modelContainer(PersistenceController.shared)
    }
}
