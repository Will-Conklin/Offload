//
//  OrganizeView.swift
//  Offload
//
//  Flat design for Plans, Lists, and Communications tabs
//

import SwiftUI
import SwiftData

struct OrganizeView: View {
    enum Scope {
        case plans, lists, communications

        var title: String {
            switch self {
            case .plans: return "Plans"
            case .lists: return "Lists"
            case .communications: return "Comms"
            }
        }
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    @Query(sort: \Plan.createdAt, order: .reverse) private var plans: [Plan]
    @Query(sort: \ListEntity.createdAt, order: .reverse) private var lists: [ListEntity]
    @Query(sort: \CommunicationItem.createdAt, order: .reverse) private var communications: [CommunicationItem]

    let scope: Scope
    @State private var showingCreate = false
    @State private var showingSettings = false
    @State private var selectedPlan: Plan?
    @State private var selectedList: ListEntity?
    @State private var selectedComm: CommunicationItem?

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background(colorScheme, style: style)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.sm) {
                        switch scope {
                        case .plans:
                            plansContent
                        case .lists:
                            listsContent
                        case .communications:
                            commsContent
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.sm)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle(scope.title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingCreate = true } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingSettings = true } label: {
                        Image(systemName: Icons.settings)
                            .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                    }
                }
            }
            .sheet(isPresented: $showingCreate) {
                createSheet
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .navigationDestination(item: $selectedPlan) { plan in
                PlanDetailView(planID: plan.id)
            }
            .navigationDestination(item: $selectedList) { list in
                ListDetailView(list: list)
            }
            .navigationDestination(item: $selectedComm) { comm in
                CommDetailView(comm: comm)
            }
        }
    }

    // MARK: - Plans

    @ViewBuilder
    private var plansContent: some View {
        if plans.isEmpty {
            emptyState(icon: Icons.plans, message: "No plans yet", action: "Create Plan")
        } else {
            ForEach(plans) { plan in
                PlanCard(plan: plan, colorScheme: colorScheme, style: style)
                    .onTapGesture { selectedPlan = plan }
            }
        }
    }

    // MARK: - Lists

    @ViewBuilder
    private var listsContent: some View {
        if lists.isEmpty {
            emptyState(icon: Icons.lists, message: "No lists yet", action: "Create List")
        } else {
            ForEach(lists) { list in
                ListCard(list: list, colorScheme: colorScheme, style: style)
                    .onTapGesture { selectedList = list }
            }
        }
    }

    // MARK: - Communications

    @ViewBuilder
    private var commsContent: some View {
        if communications.isEmpty {
            emptyState(icon: Icons.communications, message: "No communications yet", action: "Create Comm")
        } else {
            ForEach(communications) { comm in
                CommCard(comm: comm, colorScheme: colorScheme, style: style)
                    .onTapGesture { selectedComm = comm }
            }
        }
    }

    // MARK: - Empty State

    private func emptyState(icon: String, message: String, action: String) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
            Text(message)
                .font(.body)
                .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
            Button(action) { showingCreate = true }
                .font(.headline)
                .foregroundStyle(Theme.Colors.primary(colorScheme, style: style))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xxl)
    }

    // MARK: - Create Sheet

    @ViewBuilder
    private var createSheet: some View {
        switch scope {
        case .plans:
            PlanFormSheet { title, detail in
                let plan = Plan(title: title, detail: detail)
                modelContext.insert(plan)
            }
        case .lists:
            ListFormSheet { title, kind in
                let list = ListEntity(title: title, kind: kind)
                modelContext.insert(list)
            }
        case .communications:
            CommFormSheet { channel, recipient, content in
                let comm = CommunicationItem(channel: channel, recipient: recipient, content: content)
                modelContext.insert(comm)
            }
        }
    }
}

// MARK: - Plan Card

private struct PlanCard: View {
    let plan: Plan
    let colorScheme: ColorScheme
    let style: ThemeStyle

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(plan.title)
                .font(.headline)
                .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))

            if let detail = plan.detail, !detail.isEmpty {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                    .lineLimit(2)
            }

            HStack {
                Text(plan.createdAt, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))

                Spacer()

                if let count = plan.tasks?.count, count > 0 {
                    let done = plan.tasks?.filter { $0.isDone }.count ?? 0
                    Text("\(done)/\(count)")
                        .font(.caption)
                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                }
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.card(colorScheme, style: style))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
    }
}

// MARK: - List Card

private struct ListCard: View {
    let list: ListEntity
    let colorScheme: ColorScheme
    let style: ThemeStyle

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text(list.title)
                    .font(.headline)
                    .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))

                Spacer()

                Text(list.listKind.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(Theme.Colors.primary(colorScheme, style: style))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.primary(colorScheme, style: style).opacity(0.15))
                    .clipShape(Capsule())
            }

            if let count = list.items?.count, count > 0 {
                let checked = list.items?.filter { $0.isChecked }.count ?? 0
                Text("\(checked)/\(count) items")
                    .font(.caption)
                    .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.card(colorScheme, style: style))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
    }
}

// MARK: - Comm Card

private struct CommCard: View {
    let comm: CommunicationItem
    let colorScheme: ColorScheme
    let style: ThemeStyle

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: iconForChannel(comm.communicationChannel))
                    .foregroundStyle(Theme.Colors.primary(colorScheme, style: style))
                Text(comm.recipient)
                    .font(.headline)
                    .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))

                Spacer()

                if comm.communicationStatus == .sent {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.Colors.success(colorScheme, style: style))
                }
            }

            Text(comm.content)
                .font(.subheadline)
                .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                .lineLimit(2)

            Text(comm.createdAt, format: .dateTime.month(.abbreviated).day())
                .font(.caption)
                .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.card(colorScheme, style: style))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
    }

    private func iconForChannel(_ channel: CommunicationChannel) -> String {
        switch channel {
        case .call: return "phone.fill"
        case .email: return "envelope.fill"
        case .text: return "message.fill"
        case .other: return "ellipsis.message.fill"
        }
    }
}

// MARK: - Form Sheets

private struct PlanFormSheet: View {
    let onSave: (String, String?) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var detail = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Description (optional)", text: $detail, axis: .vertical)
            }
            .navigationTitle("New Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, detail.isEmpty ? nil : detail)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

private struct ListFormSheet: View {
    let onSave: (String, ListKind) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var kind: ListKind = .reference

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Picker("Type", selection: $kind) {
                    ForEach(ListKind.allCases, id: \.self) { k in
                        Text(k.rawValue.capitalized).tag(k)
                    }
                }
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, kind)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

private struct CommFormSheet: View {
    let onSave: (CommunicationChannel, String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var channel: CommunicationChannel = .text
    @State private var recipient = ""
    @State private var content = ""

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
            .navigationTitle("New Comm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(channel, recipient, content)
                        dismiss()
                    }
                    .disabled(recipient.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

#Preview {
    OrganizeView(scope: .plans)
        .modelContainer(PersistenceController.preview)
        .environmentObject(ThemeManager.shared)
}
