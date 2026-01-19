// Purpose: App entry points and root navigation.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Keep navigation flow consistent with MainTabView -> NavigationStack -> sheets.

import SwiftUI
import SwiftData



struct AppRootView: View {

    var body: some View {
        MainTabView()
    }
}

#Preview {
    AppRootView()
        .environmentObject(ThemeManager.shared)
        .modelContainer(PersistenceController.preview)
}
