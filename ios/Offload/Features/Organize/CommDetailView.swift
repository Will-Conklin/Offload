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
    @State private var commConversion: CommConversion?

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

                    Divider()

                    Button {
                        commConversion = .toTask(comm)
                    } label: {
                        Label("Convert to Task", systemImage: Icons.plans)
                    }

                    Button {
                        commConversion = .toListItem(comm)
                    } label: {
                        Label("Convert to List Item", systemImage: Icons.lists)
                    }

                    Divider()

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
        .sheet(item: $commConversion) { conversion in
            switch conversion {
            case .toTask(let comm):
                CommToTaskSheet(comm: comm, modelContext: modelContext) {
                    commConversion = nil
                }
            case .toListItem(let comm):
                CommToListSheet(comm: comm, modelContext: modelContext) {
                    commConversion = nil
                }
            }
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

// MARK: - Comm Conversion

enum CommConversion: Identifiable {
    case toTask(CommunicationItem)
    case toListItem(CommunicationItem)

    var id: String {
        switch self {
        case .toTask(let comm): return "task-\(comm.id)"
        case .toListItem(let comm): return "list-\(comm.id)"
        }
    }
}

// MARK: - Comm to Task Sheet

private struct CommToTaskSheet: View {
    let comm: CommunicationItem
    let modelContext: ModelContext
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    @Query(sort: \Plan.createdAt, order: .reverse) private var plans: [Plan]
    @State private var selectedPlan: Plan?
    @State private var createNew = false
    @State private var newPlanTitle = ""
    @State private var newPlanDetail = ""

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        NavigationStack {
            List {
                if !plans.isEmpty {
                    Section("Select Plan") {
                        ForEach(plans) { plan in
                            Button {
                                selectedPlan = plan
                                convertToSelectedPlan()
                            } label: {
                                HStack {
                                    Text(plan.title)
                                        .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))
                                    Spacer()
                                    if let count = plan.tasks?.count {
                                        Text("\(count) tasks")
                                            .font(.caption)
                                            .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                                    }
                                }
                            }
                        }
                    }
                }

                Section {
                    Button {
                        createNew = true
                    } label: {
                        Label("Create New Plan", systemImage: "plus.circle.fill")
                            .foregroundStyle(Theme.Colors.primary(colorScheme, style: style))
                    }
                }
            }
            .navigationTitle("Convert to Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $createNew) {
                NavigationStack {
                    Form {
                        TextField("Plan title", text: $newPlanTitle)
                        TextField("Description (optional)", text: $newPlanDetail, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    .navigationTitle("New Plan")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { createNew = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Create") {
                                createNewPlanAndConvert()
                            }
                            .disabled(newPlanTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
        }
    }

    private func convertToSelectedPlan() {
        guard let plan = selectedPlan else { return }
        let task = Task(
            title: comm.content,
            detail: "To: \(comm.recipient) via \(comm.communicationChannel.rawValue)",
            importance: 3,
            dueDate: nil,
            plan: plan
        )
        modelContext.insert(task)
        modelContext.delete(comm)
        dismiss()
        onComplete()
    }

    private func createNewPlanAndConvert() {
        let trimmed = newPlanTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let plan = Plan(
            title: trimmed,
            detail: newPlanDetail.isEmpty ? nil : newPlanDetail
        )
        modelContext.insert(plan)

        let task = Task(
            title: comm.content,
            detail: "To: \(comm.recipient) via \(comm.communicationChannel.rawValue)",
            importance: 3,
            dueDate: nil,
            plan: plan
        )
        modelContext.insert(task)
        modelContext.delete(comm)
        createNew = false
        dismiss()
        onComplete()
    }
}

// MARK: - Comm to List Sheet

private struct CommToListSheet: View {
    let comm: CommunicationItem
    let modelContext: ModelContext
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    @Query(sort: \ListEntity.createdAt, order: .reverse) private var lists: [ListEntity]
    @State private var selectedList: ListEntity?
    @State private var createNew = false
    @State private var newListTitle = ""
    @State private var newListKind: ListKind = .reference

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        NavigationStack {
            List {
                if !lists.isEmpty {
                    Section("Select List") {
                        ForEach(lists) { list in
                            Button {
                                selectedList = list
                                convertToSelectedList()
                            } label: {
                                HStack {
                                    Text(list.title)
                                        .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))
                                    Spacer()
                                    Text(list.listKind.rawValue.capitalized)
                                        .font(.caption)
                                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                                }
                            }
                        }
                    }
                }

                Section {
                    Button {
                        createNew = true
                    } label: {
                        Label("Create New List", systemImage: "plus.circle.fill")
                            .foregroundStyle(Theme.Colors.primary(colorScheme, style: style))
                    }
                }
            }
            .navigationTitle("Convert to List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $createNew) {
                NavigationStack {
                    Form {
                        TextField("List title", text: $newListTitle)
                        Picker("Type", selection: $newListKind) {
                            ForEach(ListKind.allCases, id: \.self) { kind in
                                Text(kind.rawValue.capitalized).tag(kind)
                            }
                        }
                    }
                    .navigationTitle("New List")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { createNew = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Create") {
                                createNewListAndConvert()
                            }
                            .disabled(newListTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
        }
    }

    private func convertToSelectedList() {
        guard let list = selectedList else { return }
        let item = ListItem(text: "\(comm.recipient): \(comm.content)", list: list)
        modelContext.insert(item)
        modelContext.delete(comm)
        dismiss()
        onComplete()
    }

    private func createNewListAndConvert() {
        let trimmed = newListTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let list = ListEntity(title: trimmed, kind: newListKind)
        modelContext.insert(list)

        let item = ListItem(text: "\(comm.recipient): \(comm.content)", list: list)
        modelContext.insert(item)
        modelContext.delete(comm)
        createNew = false
        dismiss()
        onComplete()
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
