//
//  FormSheet.swift
//  Offload
//
//  Created by Claude Code on 1/6/26.
//
//  Intent: Shared form sheet layout with consistent save/cancel behavior,
//  loading state, and inline error presentation across the app.
//

import SwiftUI

// AGENT NAV
// - Form Container
// - Toolbar Actions
// - Save Handling

struct FormSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    let title: String
    let saveButtonTitle: String
    let isSaveDisabled: Bool
    let onSave: () async throws -> Void
    @ViewBuilder let content: () -> Content

    @State private var errorMessage: String?
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Gradients.appBackground(colorScheme, style: themeManager.currentStyle)
                    .ignoresSafeArea()

                Form {
                    content()

                    if let errorMessage {
                        Section {
                            Text(errorMessage)
                                .font(Theme.Typography.errorText)
                                .foregroundStyle(Theme.Colors.destructive(colorScheme, style: themeManager.currentStyle))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
                .tint(Theme.Colors.accentPrimary(colorScheme, style: themeManager.currentStyle))
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(saveButtonTitle) {
                        handleSave()
                    }
                    .disabled(isSaveDisabled || isSaving)
                }
            }
        }
    }

    private func handleSave() {
        isSaving = true
        errorMessage = nil

        _Concurrency.Task { @MainActor in
            do {
                try await onSave()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}
