// Purpose: Repository layer for data access and queries.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Keep CRUD logic centralized and consistent with SwiftData models.

//  Supports Tag entities linked to Item relationships.

import Foundation
import SwiftData

/// Repository for Tag CRUD operations and queries
final class TagRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Create

    func create(tag: Tag) throws {
        modelContext.insert(tag)
        try modelContext.save()
    }

    // MARK: - Read

    func fetchAll() throws -> [Tag] {
        let descriptor = FetchDescriptor<Tag>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchById(_ id: UUID) throws -> Tag? {
        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func fetchByName(_ name: String) throws -> Tag? {
        let normalizedQuery = Self.normalizedName(name)
        guard !normalizedQuery.isEmpty else { return nil }

        let descriptor = FetchDescriptor<Tag>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        let allTags = try modelContext.fetch(descriptor)
        return allTags.first { Self.normalizedName($0.name) == normalizedQuery }
    }

    func search(query: String) throws -> [Tag] {
        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { tag in
                tag.name.contains(query)
            },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Search tags by name (alias for search)
    func searchByName(_ query: String) throws -> [Tag] {
        try search(query: query)
    }

    /// Find or create a tag by name
    func findOrCreate(name: String, color: String? = nil) throws -> Tag {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let existing = try fetchByName(trimmedName) {
            return existing
        }

        let newTag = Tag(name: trimmedName, color: color)
        try create(tag: newTag)
        return newTag
    }

    /// Fetch or create a tag by name (alias for findOrCreate).
    func fetchOrCreate(_ name: String, color: String? = nil) throws -> Tag {
        try findOrCreate(name: name, color: color)
    }

    // MARK: - Update

    func update(tag _: Tag) throws {
        try modelContext.save()
    }

    /// Returns the number of items currently using this tag.
    func updateUsageCount(_ tag: Tag) throws -> Int {
        getTaskCount(tag: tag)
    }

    // MARK: - Delete

    func delete(tag: Tag) throws {
        if !tag.items.isEmpty {
            for item in tag.items {
                item.tags.removeAll { $0.id == tag.id }
            }
        }
        modelContext.delete(tag)
        try modelContext.save()
    }

    func fetchUnused() throws -> [Tag] {
        let tags = try fetchAll()
        return tags.filter { getTaskCount(tag: $0) == 0 }
    }

    // MARK: - Task Relationships

    /// Get count of items using this tag
    func getTaskCount(tag: Tag) -> Int {
        tag.items.count
    }

    /// Check if tag is used by any items
    func isTagInUse(tag: Tag) -> Bool {
        getTaskCount(tag: tag) > 0
    }

    private static func normalizedName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
