//
//  OrganizeView.swift
//  Offload
//
//  Created by Claude Code on 12/30/25.
//
//  Intent: Manual organization hub for creating plans, categories, and tags.
//  Keeps quick-add flows lightweight to match capture-first philosophy.
//

import SwiftUI
import SwiftData

// AGENT NAV
// - Organize List
// - Sheets + Forms
// - CRUD Helpers

struct OrganizeView: View {
    enum Scope {
        case all
        case plans
        case lists
        case communications

        var title: String {
            switch self {
            case .all:
                return "Organize"
            case .plans:
                return "Plans"
            case .lists:
                return "Lists"
            case .communications:
                return "Communications"
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
    @State private var activeSheet: OrganizeSheet?
    @State private var errorMessage: String?
    @State private var showingSettings = false
    @State private var selectedPlanRoute: PlanRoute?
    @State private var selectedList: ListEntity?

    init(scope: Scope = .all) {
        self.scope = scope
    }

    private var showsPlans: Bool { scope == .all || scope == .plans }
    private var showsLists: Bool { scope == .all || scope == .lists }
    private var showsCommunications: Bool { scope == .all || scope == .communications }

    private var planSectionContent: some View {
        Group {
            if plans.isEmpty {
                CardView {
                    Text("No plans yet")
                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))
                }
                .frame(height: Theme.Cards.rowHeight)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: Theme.Cards.verticalInset,
                                          leading: Theme.Cards.horizontalInset,
                                          bottom: Theme.Cards.verticalInset,
                                          trailing: Theme.Cards.horizontalInset))
                .listRowSeparator(.hidden)
            } else {
                ForEach(plans) { plan in
                    Button {
                        selectedPlanRoute = PlanRoute(id: plan.id)
                    } label: {
                        CardView {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(plan.title)
                                    .font(.headline)
                                    .lineLimit(1)

                                if let detail = plan.detail, !detail.isEmpty {
                                    Text(detail)
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))
                                        .lineLimit(2)
                                }

                                HStack {
                                    Text(plan.createdAt, format: .dateTime.month().day().year())
                                        .font(.caption)
                                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))

                                    if let taskCount = plan.tasks?.count, taskCount > 0 {
                                        Spacer()
                                        Text("\(taskCount) tasks")
                                            .font(.caption)
                                            .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))
                                    }
                                }
                            }
                        }
                        .frame(height: Theme.Cards.rowHeight)
                    }
                    .cardButtonStyle()
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: Theme.Cards.verticalInset,
                                              leading: Theme.Cards.horizontalInset,
                                              bottom: Theme.Cards.verticalInset,
                                              trailing: Theme.Cards.horizontalInset))
                    .listRowSeparator(.hidden)
                }
                .onDelete(perform: deletePlans)
            }
        }
    }

    private var listSectionContent: some View {
        Group {
            if lists.isEmpty {
                CardView {
                    Text("No lists yet")
                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))
                }
                .frame(height: Theme.Cards.rowHeight)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: Theme.Cards.verticalInset,
                                          leading: Theme.Cards.horizontalInset,
                                          bottom: Theme.Cards.verticalInset,
                                          trailing: Theme.Cards.horizontalInset))
                .listRowSeparator(.hidden)
            } else {
                ForEach(lists) { list in
                    Button {
                        selectedList = list
                    } label: {
                        CardView {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(list.title)
                                        .font(Theme.Typography.cardTitle)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(list.listKind.rawValue.capitalized)
                                        .font(Theme.Typography.badge)
                                        .padding(.horizontal, Theme.Spacing.sm)
                                        .padding(.vertical, 2)
                                        .background(Theme.Colors.accentPrimary(colorScheme, style: themeManager.currentStyle).opacity(0.2))
                                        .cornerRadius(Theme.CornerRadius.sm)
                                }

                                if let itemCount = list.items?.count, itemCount > 0 {
                                    let checkedCount = list.items?.filter { $0.isChecked }.count ?? 0
                                    Text("\(checkedCount)/\(itemCount) items")
                                        .font(.caption)
                                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))
                                }
                            }
                        }
                        .frame(height: Theme.Cards.rowHeight)
                    }
                    .cardButtonStyle()
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: Theme.Cards.verticalInset,
                                              leading: Theme.Cards.horizontalInset,
                                              bottom: Theme.Cards.verticalInset,
                                              trailing: Theme.Cards.horizontalInset))
                    .listRowSeparator(.hidden)
                }
                .onDelete(perform: deleteLists)
            }
        }
    }

    private var communicationSectionContent: some View {
        Group {
            if communications.isEmpty {
                CardView {
                    Text("No communications yet")
                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))
                }
                .frame(height: Theme.Cards.rowHeight)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: Theme.Cards.verticalInset,
                                          leading: Theme.Cards.horizontalInset,
                                          bottom: Theme.Cards.verticalInset,
                                          trailing: Theme.Cards.horizontalInset))
                .listRowSeparator(.hidden)
            } else {
                ForEach(communications) { comm in
                    CardView {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: iconForChannel(comm.communicationChannel))
                                    .foregroundStyle(Theme.Colors.accentPrimary(colorScheme, style: themeManager.currentStyle))
                                Text(comm.recipient)
                                    .font(Theme.Typography.cardTitle)
                                    .lineLimit(1)
                                Spacer()
                                if comm.communicationStatus == .sent {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.Colors.success(colorScheme, style: themeManager.currentStyle))
                                }
                            }

                            Text(comm.content)
                                .font(Theme.Typography.cardBody)
                                .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))
                                .lineLimit(2)

                            Text(comm.createdAt, format: .dateTime.month().day().year())
                                .font(Theme.Typography.metadata)
                                .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: themeManager.currentStyle))
                        }
                    }
                    .frame(height: Theme.Cards.rowHeight)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: Theme.Cards.verticalInset,
                                              leading: Theme.Cards.horizontalInset,
                                              bottom: Theme.Cards.verticalInset,
                                              trailing: Theme.Cards.horizontalInset))
                    .listRowSeparator(.hidden)
                }
                .onDelete(perform: deleteCommunications)
            }
        }
    }

    @ViewBuilder
    private var addToolbarItem: some View {
        switch scope {
        case .all:
            Menu {
                Button("New Plan") {
                    activeSheet = .plan
                }
                Button("New List") {
                    activeSheet = .list
                }
                Button("New Communication") {
                    activeSheet = .communication
                }
            } label: {
                Label("Add", systemImage: Icons.add)
            }
        case .plans:
            Button {
                activeSheet = .plan
            } label: {
                Label("New Plan", systemImage: Icons.add)
            }
        case .lists:
            Button {
                activeSheet = .list
            } label: {
                Label("New List", systemImage: Icons.add)
            }
        case .communications:
            Button {
                activeSheet = .communication
            } label: {
                Label("New Communication", systemImage: Icons.add)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Gradients.appBackground(colorScheme, style: themeManager.currentStyle)
                    .ignoresSafeArea()

                List {
                    if showsPlans {
                        if scope == .all {
                            Section("Plans") {
                                planSectionContent
                            }
                        } else {
                            Section {
                                planSectionContent
                            }
                        }
                    }

                    if showsLists {
                        if scope == .all {
                            Section("Lists") {
                                listSectionContent
                            }
                        } else {
                            Section {
                                listSectionContent
                            }
                        }
                    }

                    if showsCommunications {
                        if scope == .all {
                            Section("Communications") {
                                communicationSectionContent
                            }
                        } else {
                            Section {
                                communicationSectionContent
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                .navigationTitle(scope.title)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        addToolbarItem
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
                .sheet(item: $activeSheet) { sheet in
                    switch sheet {
                    case .plan:
                        PlanFormSheet { title, detail in
                            try createPlan(title: title, detail: detail)
                        }
                    case .list:
                        ListFormSheet { title, kind in
                            try createList(title: title, kind: kind)
                        }
                    case .communication:
                        CommunicationFormSheet { channel, recipient, content in
                            try createCommunication(channel: channel, recipient: recipient, content: content)
                        }
                    }
                }
                .alert("Error", isPresented: .constant(errorMessage != nil), presenting: errorMessage) { _ in
                    Button("OK") {
                        errorMessage = nil
                    }
                } message: { message in
                    Text(message)
                }
                .navigationDestination(item: $selectedPlanRoute) { route in
                    PlanDetailView(planID: route.id)
                }
                .navigationDestination(item: $selectedList) { list in
                    ListDetailView(list: list)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
            }
        }
    }

    private func createPlan(title: String, detail: String?) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw ValidationError("Plan title is required.")
        }

        let normalizedDetail = detail?.trimmingCharacters(in: .whitespacesAndNewlines)
        let plan = Plan(
            title: trimmedTitle,
            detail: (normalizedDetail?.isEmpty ?? true) ? nil : normalizedDetail
        )

        modelContext.insert(plan)
        try modelContext.save()
    }

    private func deletePlans(offsets: IndexSet) {
        for index in offsets {
            let plan = plans[index]
            modelContext.delete(plan)
        }

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            errorMessage = "Failed to delete plans: \(error.localizedDescription)"
        }
    }

    private func createList(title: String, kind: ListKind) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw ValidationError("List title is required.")
        }

        let list = ListEntity(title: trimmedTitle, kind: kind)
        modelContext.insert(list)
        try modelContext.save()
    }

    private func deleteLists(offsets: IndexSet) {
        for index in offsets {
            let list = lists[index]
            modelContext.delete(list)
        }

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            errorMessage = "Failed to delete lists: \(error.localizedDescription)"
        }
    }

    private func createCommunication(channel: CommunicationChannel, recipient: String, content: String) throws {
        let trimmedRecipient = recipient.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedRecipient.isEmpty else {
            throw ValidationError("Recipient is required.")
        }
        guard !trimmedContent.isEmpty else {
            throw ValidationError("Content is required.")
        }

        let comm = CommunicationItem(
            channel: channel,
            recipient: trimmedRecipient,
            content: trimmedContent
        )
        modelContext.insert(comm)
        try modelContext.save()
    }

    private func deleteCommunications(offsets: IndexSet) {
        for index in offsets {
            let comm = communications[index]
            modelContext.delete(comm)
        }

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            errorMessage = "Failed to delete communications: \(error.localizedDescription)"
        }
    }

    private func iconForChannel(_ channel: CommunicationChannel) -> String {
        switch channel {
        case .call:
            return "phone.fill"
        case .email:
            return "envelope.fill"
        case .text:
            return "message.fill"
        case .other:
            return "ellipsis.message.fill"
        }
    }
}

private enum OrganizeSheet: Identifiable {
    case plan
    case list
    case communication

    var id: String {
        switch self {
        case .plan:
            return "plan"
        case .list:
            return "list"
        case .communication:
            return "communication"
        }
    }
}

private struct PlanRoute: Identifiable, Hashable {
    let id: UUID
}

private struct PlanFormSheet: View {
    let onSave: (String, String?) async throws -> Void

    @State private var title: String = ""
    @State private var detail: String = ""

    var body: some View {
        FormSheet(
            title: "New Plan",
            saveButtonTitle: "Save",
            isSaveDisabled: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onSave: {
                let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedDetail = detail.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !trimmedTitle.isEmpty else {
                    throw ValidationError("Plan title is required.")
                }

                try await onSave(
                    trimmedTitle,
                    trimmedDetail.isEmpty ? nil : trimmedDetail
                )
            }
        ) {
            Section("Details") {
                TextField("Plan title", text: $title)
                TextField("Description (optional)", text: $detail, axis: .vertical)
            }
        }
    }
}

private struct CategoryFormSheet: View {
    let onSave: (String, String?) async throws -> Void

    @State private var name: String = ""
    @State private var icon: String = ""

    var body: some View {
        FormSheet(
            title: "New Category",
            saveButtonTitle: "Save",
            isSaveDisabled: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onSave: {
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedIcon = icon.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !trimmedName.isEmpty else {
                    throw ValidationError("Category name is required.")
                }

                try await onSave(
                    trimmedName,
                    trimmedIcon.isEmpty ? nil : trimmedIcon
                )
            }
        ) {
            Section("Details") {
                TextField("Category name", text: $name)
                TextField("Emoji (optional)", text: $icon)
            }
        }
    }
}

private struct TagFormSheet: View {
    let onSave: (String, String?) async throws -> Void

    @State private var name: String = ""
    @State private var color: String = ""

    var body: some View {
        FormSheet(
            title: "New Tag",
            saveButtonTitle: "Save",
            isSaveDisabled: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onSave: {
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedColor = color.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !trimmedName.isEmpty else {
                    throw ValidationError("Tag name is required.")
                }

                try await onSave(
                    trimmedName,
                    trimmedColor.isEmpty ? nil : trimmedColor
                )
            }
        ) {
            Section("Details") {
                TextField("Tag name", text: $name)
                TextField("Color (optional)", text: $color)
            }
        }
    }
}

private struct ListFormSheet: View {
    let onSave: (String, ListKind) async throws -> Void

    @State private var title: String = ""
    @State private var kind: ListKind = .reference

    var body: some View {
        FormSheet(
            title: "New List",
            saveButtonTitle: "Save",
            isSaveDisabled: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onSave: {
                let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !trimmedTitle.isEmpty else {
                    throw ValidationError("List title is required.")
                }

                try await onSave(trimmedTitle, kind)
            }
        ) {
            Section("Details") {
                TextField("List title", text: $title)
                Picker("Type", selection: $kind) {
                    ForEach(ListKind.allCases, id: \.self) { kind in
                        Text(kind.rawValue.capitalized).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

private struct CommunicationFormSheet: View {
    let onSave: (CommunicationChannel, String, String) async throws -> Void

    @State private var channel: CommunicationChannel = .text
    @State private var recipient: String = ""
    @State private var content: String = ""

    var body: some View {
        FormSheet(
            title: "New Communication",
            saveButtonTitle: "Save",
            isSaveDisabled: recipient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onSave: {
                let trimmedRecipient = recipient.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !trimmedRecipient.isEmpty else {
                    throw ValidationError("Recipient is required.")
                }
                guard !trimmedContent.isEmpty else {
                    throw ValidationError("Content is required.")
                }

                try await onSave(channel, trimmedRecipient, trimmedContent)
            }
        ) {
            Section("Type") {
                Picker("Channel", selection: $channel) {
                    ForEach(CommunicationChannel.allCases, id: \.self) { channel in
                        Label(channel.rawValue.capitalized, systemImage: iconForChannel(channel))
                            .tag(channel)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Details") {
                TextField("Recipient", text: $recipient)
                TextField("Message", text: $content, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
    }

    private func iconForChannel(_ channel: CommunicationChannel) -> String {
        switch channel {
        case .call:
            return "phone.fill"
        case .email:
            return "envelope.fill"
        case .text:
            return "message.fill"
        case .other:
            return "ellipsis.message.fill"
        }
    }
}


#Preview {
    OrganizeView()
        .modelContainer(PersistenceController.preview)
        .environmentObject(ThemeManager.shared)
}
