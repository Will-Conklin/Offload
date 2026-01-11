//
//  CommDetailView.swift
//  Offload
//
//  Detail view for a communication item
//

import SwiftUI
import SwiftData

// AGENT NAV
// - Header Card
// - Message Card
// - Actions + Status Badge
// - Edit Sheet

struct CommDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    @Bindable var comm: CommunicationItem

    @State private var showingEdit = false
    @State private var showingDelete = false

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                // Header card
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    HStack {
                        Image(systemName: iconForChannel(comm.communicationChannel))
                            .font(.title2)
                            .foregroundStyle(Theme.Colors.primary(colorScheme, style: style))

                        Text(comm.communicationChannel.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))

                        Spacer()

                        statusBadge
                    }

                    Text(comm.recipient)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))

                    Text(comm.createdAt, format: .dateTime.month().day().year())
                        .font(.caption)
                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.card(colorScheme, style: style))
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))

                // Message card
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Message")
                        .font(.caption)
                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))

                    Text(comm.content)
                        .font(.body)
                        .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))
                }
                .padding(Theme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Colors.surface(colorScheme, style: style))
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                        .stroke(Theme.Colors.border(colorScheme, style: style), lineWidth: 1)
                )

                // Actions
                HStack(spacing: Theme.Spacing.md) {
                    Button {
                        toggleStatus()
                    } label: {
                        Label(
                            comm.communicationStatus == .sent ? "Mark Pending" : "Mark Sent",
                            systemImage: comm.communicationStatus == .sent ? "arrow.uturn.backward" : "checkmark"
                        )
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.Colors.primary(colorScheme, style: style))
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(Theme.Colors.primary(colorScheme, style: style).opacity(0.15))
                        .clipShape(Capsule())
                    }

                    Spacer()
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.md)
        }
        .background(Theme.Colors.background(colorScheme, style: style))
        .navigationTitle("Communication")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button { showingEdit = true } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) { showingDelete = true } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditCommSheet(comm: comm)
        }
        .alert("Delete Communication?", isPresented: $showingDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(comm)
                dismiss()
            }
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        let isSent = comm.communicationStatus == .sent
        Text(isSent ? "Sent" : "Pending")
            .font(.caption.weight(.medium))
            .foregroundStyle(isSent ? Theme.Colors.success(colorScheme, style: style) : Theme.Colors.caution(colorScheme, style: style))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background((isSent ? Theme.Colors.success(colorScheme, style: style) : Theme.Colors.caution(colorScheme, style: style)).opacity(0.15))
            .clipShape(Capsule())
    }

    private func iconForChannel(_ channel: CommunicationChannel) -> String {
        switch channel {
        case .call: return "phone.fill"
        case .email: return "envelope.fill"
        case .text: return "message.fill"
        case .other: return "ellipsis.message.fill"
        }
    }

    private func toggleStatus() {
        comm.communicationStatus = comm.communicationStatus == .sent ? .draft : .sent
    }
}

// MARK: - Edit Sheet

private struct EditCommSheet: View {
    @Bindable var comm: CommunicationItem
    @Environment(\.dismiss) private var dismiss
    @State private var channel: CommunicationChannel
    @State private var recipient: String
    @State private var content: String

    init(comm: CommunicationItem) {
        self.comm = comm
        _channel = State(initialValue: comm.communicationChannel)
        _recipient = State(initialValue: comm.recipient)
        _content = State(initialValue: comm.content)
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $channel) {
                    ForEach(CommunicationChannel.allCases, id: \.self) { c in
                        Text(c.rawValue.capitalized).tag(c)
                    }
                }
                .pickerStyle(.segmented)

                TextField("Recipient", text: $recipient)
                TextField("Message", text: $content, axis: .vertical)
                    .lineLimit(3...6)
            }
            .navigationTitle("Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        comm.communicationChannel = channel
                        comm.recipient = recipient
                        comm.content = content
                        dismiss()
                    }
                    .disabled(recipient.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

#Preview {
    let comm = CommunicationItem(channel: .email, recipient: "John", content: "Follow up on project")

    NavigationStack {
        CommDetailView(comm: comm)
    }
    .modelContainer(PersistenceController.preview)
    .environmentObject(ThemeManager.shared)
}
