//
//  InboxView.swift
//  Offload
//
//  Created by Claude Code on 12/30/25.
//

import SwiftUI
import SwiftData

struct InboxView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Thought.createdAt, order: .reverse) private var thoughts: [Thought]

    @State private var showingCapture = false

    var body: some View {
        List {
            ForEach(thoughts) { thought in
                ThoughtRow(thought: thought)
            }
            .onDelete(perform: deleteThoughts)
        }
        .navigationTitle("Inbox")
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
        }
        .sheet(isPresented: $showingCapture) {
            CaptureSheetView()
        }
    }

    private func deleteThoughts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(thoughts[index])
            }
        }
    }
}

struct ThoughtRow: View {
    let thought: Thought

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(thought.rawText)
                .font(.body)
                .lineLimit(2)

            Text(thought.createdAt, format: .dateTime)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        InboxView()
    }
    .modelContainer(PersistenceController.preview)
}
