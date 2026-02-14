// Purpose: Data migrations for evolving the SwiftData model.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Keep migrations idempotent and MainActor-safe.

import Foundation
import OSLog
import SwiftData

@MainActor
struct TagMigration {
    static func runIfNeeded(modelContext: ModelContext) throws {
        var didChange = false
        var stats = MigrationStats()
        var canonicalTagsByName = try buildCanonicalTagLookup(
            in: modelContext,
            didChange: &didChange,
            stats: &stats
        )

        let itemDescriptor = FetchDescriptor<Item>()
        let items = try modelContext.fetch(itemDescriptor)

        for item in items {
            stats.itemsScanned += 1
            guard !item.legacyTags.isEmpty else { continue }
            stats.itemsWithLegacyTags += 1
            for legacyName in item.legacyTags {
                let trimmed = legacyName.trimmingCharacters(in: .whitespacesAndNewlines)
                let normalized = Tag.normalizedName(trimmed)
                guard !normalized.isEmpty else { continue }

                let tag: Tag
                if let existing = canonicalTagsByName[normalized] {
                    tag = existing
                } else {
                    let created = Tag(name: trimmed)
                    modelContext.insert(created)
                    canonicalTagsByName[normalized] = created
                    didChange = true
                    stats.tagsCreatedFromLegacy += 1
                    tag = created
                }

                if !item.tags.contains(where: { $0.id == tag.id }) {
                    item.tags.append(tag)
                    didChange = true
                    stats.itemTagLinksAdded += 1
                }
            }

            if !item.legacyTags.isEmpty {
                item.legacyTags = []
                didChange = true
                stats.legacyTagArraysCleared += 1
            }
        }

        if didChange {
            try modelContext.save()
            stats.didSave = true
        }

        AppLogger.persistence.info(
            "TagMigration summary - tagsScanned: \(stats.tagsScanned, privacy: .public), duplicateTagsMerged: \(stats.duplicateTagsMerged, privacy: .public), duplicateTagsDeleted: \(stats.duplicateTagsDeleted, privacy: .public), itemsScanned: \(stats.itemsScanned, privacy: .public), itemsWithLegacyTags: \(stats.itemsWithLegacyTags, privacy: .public), tagsCreatedFromLegacy: \(stats.tagsCreatedFromLegacy, privacy: .public), itemTagLinksAdded: \(stats.itemTagLinksAdded, privacy: .public), legacyTagArraysCleared: \(stats.legacyTagArraysCleared, privacy: .public), didSave: \(stats.didSave, privacy: .public)"
        )
    }

    private static func buildCanonicalTagLookup(
        in modelContext: ModelContext,
        didChange: inout Bool,
        stats: inout MigrationStats
    ) throws -> [String: Tag] {
        let descriptor = FetchDescriptor<Tag>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        let tags = try modelContext.fetch(descriptor)

        var canonicalByName: [String: Tag] = [:]
        var duplicates: [Tag] = []

        for tag in tags {
            stats.tagsScanned += 1
            let trimmed = tag.name.trimmingCharacters(in: .whitespacesAndNewlines)
            if tag.name != trimmed {
                tag.name = trimmed
                didChange = true
            }

            let normalized = Tag.normalizedName(trimmed)
            guard !normalized.isEmpty else { continue }

            if let canonical = canonicalByName[normalized] {
                mergeRelationships(from: tag, into: canonical)
                duplicates.append(tag)
                didChange = true
                stats.duplicateTagsMerged += 1
            } else {
                canonicalByName[normalized] = tag
            }
        }

        for duplicate in duplicates {
            modelContext.delete(duplicate)
            stats.duplicateTagsDeleted += 1
        }

        return canonicalByName
    }

    private static func mergeRelationships(from duplicate: Tag, into canonical: Tag) {
        for item in duplicate.items where !item.tags.contains(where: { $0.id == canonical.id }) {
            item.tags.append(canonical)
        }
        for collection in duplicate.collections where !collection.tags.contains(where: { $0.id == canonical.id }) {
            collection.tags.append(canonical)
        }
    }
}

private struct MigrationStats {
    var tagsScanned = 0
    var duplicateTagsMerged = 0
    var duplicateTagsDeleted = 0
    var itemsScanned = 0
    var itemsWithLegacyTags = 0
    var tagsCreatedFromLegacy = 0
    var itemTagLinksAdded = 0
    var legacyTagArraysCleared = 0
    var didSave = false
}
