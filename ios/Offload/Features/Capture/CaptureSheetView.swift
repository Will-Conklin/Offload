//
//  CaptureSheetView.swift
//  Offload
//
//  Created by Claude Code on 12/30/25.
//

import SwiftUI
import SwiftData

struct CaptureSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var rawText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Quick Capture") {
                    TextField("What's on your mind?", text: $rawText, axis: .vertical)
                        .lineLimit(3...10)
                }
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
                    Button("Save") {
                        saveThought()
                    }
                    .disabled(rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveThought() {
        let thought = Thought(
            source: .text,
            rawText: rawText.trimmingCharacters(in: .whitespacesAndNewlines),
            status: .inbox
        )
        modelContext.insert(thought)
        dismiss()
    }
}

#Preview {
    CaptureSheetView()
        .modelContainer(PersistenceController.preview)
}
