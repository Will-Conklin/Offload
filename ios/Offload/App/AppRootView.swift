//
//  AppRootView.swift
//  Offload
//
//  Created by Claude Code on 12/30/25.
//

import SwiftData
import SwiftUI

struct AppRootView: View {
    var body: some View {
        NavigationStack {
            InboxView()
        }
    }
}

#Preview {
    AppRootView()
        .modelContainer(PersistenceController.preview)
}
