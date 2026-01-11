//
//  CapturesView.swift
//  Offload
//
//  Created by Claude Code on 12/30/25.
//
//  Intent: Primary view for raw thought captures awaiting organization.
//  Displays lifecycle state and input type with minimal UI friction.
//

import SwiftUI
import SwiftData

// AGENT NAV
// - Captures List
// - Capture Row
// - Fetch + Delete

struct CapturesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var showingCapture = false
    @State private var showingSettings = false
    @State private var workflowService: CaptureWorkflowService?
    @State private var entries: [CaptureEntry] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Gradients.appBackground(colorScheme, style: themeManager.currentStyle)
                    .ignoresSafeArea()

                List {
                    ForEach(entries) { entry in
                        CardView {
                            CaptureRow(entry: entry)
                        }
                        .frame(height: Theme.Cards.rowHeight)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: Theme.Cards.verticalInset,
                                                  leading: Theme.Cards.horizontalInset,
                                                  bottom: Theme.Cards.verticalInset,
                                                  trailing: Theme.Cards.horizontalInset))
                }
                .onDelete(perform: deleteEntries)
            }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                .navigationTitle("Captures")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingCapture = true
                        } label: {
                            Label("Capture", systemImage: "plus")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: Icons.settings)
                        }
                        .accessibilityLabel("Settings")
                    }
                }
                .sheet(isPresented: $showingCapture, onDismiss: {
                    _Concurrency.Task {
                        await loadInbox()
                    }
                }) {
                    CaptureSheetView()
                }
                .task {
                    if workflowService == nil {
                        workflowService = CaptureWorkflowService(modelContext: modelContext)
                    }
                    await loadInbox()
                }
                .refreshable {
                    await loadInbox()
                }
                .alert("Error", isPresented: .constant(errorMessage != nil), presenting: errorMessage) { _ in
                    Button("OK") {
                        errorMessage = nil
                    }
                } message: { message in
                    Text(message)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
            }
        }
    }

    private func loadInbox() async {
        guard let workflowService = workflowService else { return }
        do {
            entries = try workflowService.fetchInbox()
        } catch {
            // Error is already set in workflowService.errorMessage
        }
    }

    private func deleteEntries(offsets: IndexSet) {
        guard let workflowService = workflowService else { return }

        // Capture entries to delete BEFORE async operation
        let entriesToDelete = offsets.map { entries[$0] }

        _Concurrency.Task {
            do {
                // Serialize deletions
                for entry in entriesToDelete {
                    try await workflowService.deleteEntry(entry)
                }

                // Single reload after all deletions complete
                await loadInbox()
            } catch {
                // Show error to user
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct CaptureRow: View {
    let entry: CaptureEntry

    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.rawText)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: themeManager.currentStyle))
                .lineLimit(2)

            HStack {
                Text(entry.createdAt, format: .dateTime)
                    .font(Theme.Typography.metadata)
                    .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))

                if entry.entryInputType == .voice {
                    Image(systemName: "waveform")
                        .font(Theme.Typography.metadata)
                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))
                }

                if entry.currentLifecycleState != .raw {
                    Text(entry.currentLifecycleState.rawValue)
                        .font(Theme.Typography.badge)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.Colors.accentPrimary(colorScheme, style: themeManager.currentStyle).opacity(0.2))
                        .cornerRadius(Theme.CornerRadius.sm)
                }
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}

#Preview {
    CapturesView()
    .modelContainer(PersistenceController.preview)
    .environmentObject(ThemeManager.shared)
}
