// Purpose: Celebration animation modifier for positive feedback moments.
// Authority: Code-level
// Governed by: AGENTS.md

import SwiftUI
import UIKit

// MARK: - Celebration Style

/// Defines the three celebration moments with their animation parameters.
enum CelebrationStyle {
    case itemCompleted
    case firstCapture
    case collectionCompleted

    /// Haptic feedback intensity for this celebration.
    var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .itemCompleted: .light
        case .firstCapture, .collectionCompleted: .medium
        }
    }

    /// Whether this celebration includes particle effects.
    var showsParticles: Bool {
        switch self {
        case .itemCompleted: false
        case .firstCapture, .collectionCompleted: true
        }
    }

    /// Number of particles to generate (5-8 range).
    var particleCount: Int {
        Int.random(in: 5 ... 8)
    }

    /// Peak scale factor during the pulse animation.
    var scalePeak: CGFloat {
        switch self {
        case .itemCompleted, .firstCapture: 1.15
        case .collectionCompleted: 1.0
        }
    }

    /// Duration of the full celebration sequence.
    var duration: TimeInterval {
        switch self {
        case .itemCompleted: 0.4
        case .firstCapture: 1.5
        case .collectionCompleted: 2.0
        }
    }
}
