// Intent: Provide a low-friction capture flow with immediate focus and reassuring copy aligned to ADHD-friendly guardrails.
//
//  CaptureView.swift
//  Offload
//
//  Created by Claude Code on 12/30/25.
//

import SwiftUI
import SwiftData

// AGENT NAV
// - Capture Form
// - Inline Guidance
// - Save Handling

/// Legacy placeholder capture view
/// Use CaptureSheetView for the actual app (supports voice + text)
struct CaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var title: String = ""
    @State private var notes: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Gradients.appBackground(colorScheme, style: themeManager.currentStyle)
                    .ignoresSafeArea()

                Form {
                    Section("Quick Capture") {
                        CardView {
                            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                Text("Thought")
                                    .font(Theme.Typography.inputLabel)
                                    .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))

                                TextField("What's on your mind?", text: $title, axis: .vertical)
                                    .focused($isFocused)
                                    .textInputAutocapitalization(.sentences)
                                    .disableAutocorrection(false)
                                    .font(Theme.Typography.body)
                                    .padding(Theme.Spacing.sm)
                                    .background(Theme.Colors.surface(colorScheme, style: themeManager.currentStyle))
                                    .cornerRadius(Theme.CornerRadius.md)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                            .stroke(Theme.Colors.borderMuted(colorScheme, style: themeManager.currentStyle).opacity(0.6), lineWidth: 0.8)
                                    )
                                    .shadow(color: Theme.Shadows.ambient(colorScheme), radius: Theme.Shadows.elevationXs, y: 1)

                                ThemedTextEditor(label: "Notes", text: $notes, placeholder: "Add more detail (optional)", minHeight: 120)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: Theme.Cards.verticalInset,
                                                  leading: Theme.Cards.horizontalInset,
                                                  bottom: Theme.Cards.verticalInset,
                                                  trailing: Theme.Cards.horizontalInset))
                        .listRowSeparator(.hidden)
                    }

                    Section {
                        CardView {
                            Label("Captured items can be organized later. Undo is available from the inbox.",
                                  systemImage: "checkmark.seal")
                                .font(.footnote)
                                .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))
                                .padding(.vertical, Theme.Spacing.xs)
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: Theme.Cards.verticalInset,
                                                  leading: Theme.Cards.horizontalInset,
                                                  bottom: Theme.Cards.verticalInset,
                                                  trailing: Theme.Cards.horizontalInset))
                        .listRowSeparator(.hidden)
                    }

                    // TODO: Add capture type selection (task, note, idea, etc.)
                    // TODO: Add quick tags/categories
                    // TODO: Add priority selection
                    // TODO: Add due date picker
                    // TODO: Add voice memo recording
                    // TODO: Add photo/file attachment
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                .tint(Theme.Colors.accentPrimary(colorScheme, style: themeManager.currentStyle))
            }
            .navigationTitle("Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveEntry()
                    } label: {
                        Text("Capture & close")
                            .fontWeight(.semibold)
                    }
                    .disabled(title.isEmpty)
                }
            }
            .toolbarTitleDisplayMode(.inline)
            .onAppear {
                isFocused = true
            }
        }
    }

    private func saveEntry() {
        withAnimation {
            let combinedText = notes.isEmpty ? title : "\(title)\n\n\(notes)"
            let entry = CaptureEntry(
                rawText: combinedText,
                inputType: .text,
                source: .app
            )
            modelContext.insert(entry)
            dismiss()
        }
    }
}

#Preview {
    CaptureView()
        .modelContainer(PersistenceController.preview)
        .environmentObject(ThemeManager.shared)
}
