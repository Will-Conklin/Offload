//
//  CommunicationItem.swift
//  Offload
//
//  Created by Claude Code on 12/31/25.
//
//  Intent: Structured reminders for messages, calls, emails to send.
//  Helps capture "remember to tell X about Y" thoughts.
//

import Foundation
import SwiftData

@Model
final class CommunicationItem {
    var id: UUID
    var channel: String  // Stored as String for SwiftData compatibility
    var recipient: String
    var content: String
    var createdAt: Date
    var status: String  // Stored as String for SwiftData compatibility

    // No relationships - standalone entity

    init(
        id: UUID = UUID(),
        channel: CommunicationChannel,
        recipient: String,
        content: String,
        createdAt: Date = Date(),
        status: CommunicationStatus = .draft
    ) {
        self.id = id
        self.channel = channel.rawValue
        self.recipient = recipient
        self.content = content
        self.createdAt = createdAt
        self.status = status.rawValue
    }

    // Computed properties for type-safe access to enums
    var communicationChannel: CommunicationChannel {
        get { CommunicationChannel(rawValue: channel) ?? .text }
        set { channel = newValue.rawValue }
    }

    var communicationStatus: CommunicationStatus {
        get { CommunicationStatus(rawValue: status) ?? .draft }
        set { status = newValue.rawValue }
    }
}

// MARK: - CommunicationChannel Enum

enum CommunicationChannel: String, Codable, CaseIterable {
    case call = "call"
    case email = "email"
    case text = "text"
    case other = "other"
}

// MARK: - CommunicationStatus Enum

enum CommunicationStatus: String, Codable, CaseIterable {
    case draft = "draft"
    case sent = "sent"
    case deferred = "deferred"
}
