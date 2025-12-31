//
//  Plan.swift
//  Offload
//
//  Created by Claude Code on 12/31/25.
//
//  Intent: Simplified container for grouped tasks (replaces complex Project hierarchy).
//  Aligns with "capture first, organize later" philosophy.
//

import Foundation
import SwiftData

@Model
final class Plan {
    var id: UUID
    var title: String
    var detail: String?
    var createdAt: Date
    var isArchived: Bool

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Task.plan)
    var tasks: [Task]?

    init(
        id: UUID = UUID(),
        title: String,
        detail: String? = nil,
        createdAt: Date = Date(),
        isArchived: Bool = false,
        tasks: [Task]? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.createdAt = createdAt
        self.isArchived = isArchived
        self.tasks = tasks
    }
}
