// Purpose: Shared pending-capture bridge between app extensions and the main app.
// Authority: Code-level
// Governed by: CLAUDE.md
// Additional instructions: This file is compiled into the main app, Share Extension, and Widget targets.

import Foundation

/// A minimal capture record written by extensions and flushed to SwiftData by the main app.
struct PendingCapture: Codable, Identifiable {
    var id: UUID
    var content: String
    var type: String?
    var sourceURL: String?
    var createdAt: Date

    init(content: String, type: String? = nil, sourceURL: String? = nil) {
        self.id = UUID()
        self.content = content
        self.type = type
        self.sourceURL = sourceURL
        self.createdAt = Date()
    }
}

/// App Group-backed store that lets extensions enqueue captures for the main app to persist.
enum PendingCaptureStore {
    static let appGroupID = "group.wc.Offload"
    private static let key = "pending_captures"

    /// Appends a pending capture to the shared queue. Safe to call from any extension target.
    static func enqueue(_ capture: PendingCapture) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        var existing = load(from: defaults)
        existing.append(capture)
        defaults.set(try? JSONEncoder().encode(existing), forKey: key)
    }

    /// Returns all enqueued captures without removing them.
    static func load() -> [PendingCapture] {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return [] }
        return load(from: defaults)
    }

    /// Removes all enqueued captures. Call after flushing to SwiftData.
    static func clear() {
        UserDefaults(suiteName: appGroupID)?.removeObject(forKey: key)
    }

    private static func load(from defaults: UserDefaults) -> [PendingCapture] {
        guard let data = defaults.data(forKey: key),
              let captures = try? JSONDecoder().decode([PendingCapture].self, from: data)
        else { return [] }
        return captures
    }
}
