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

// MARK: - Celebration Particles

/// Lightweight pure-SwiftUI particle effect using MCM palette colors.
struct CelebrationParticlesView: View {
    let particleCount: Int

    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var isAnimating = false

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        ZStack {
            ForEach(0 ..< particleCount, id: \.self) { index in
                particleShape(index: index)
                    .frame(width: particleSize(index: index), height: particleSize(index: index))
                    .foregroundStyle(Theme.Colors.cardColor(index: index, colorScheme, style: style))
                    .offset(
                        x: isAnimating ? CGFloat.random(in: -40 ... 40) : 0,
                        y: isAnimating ? CGFloat.random(in: -80 ... -20) : 0
                    )
                    .opacity(isAnimating ? 0 : 1)
                    .scaleEffect(isAnimating ? 0.3 : 1.0)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }

    /// Returns a circle or rotated rounded rectangle based on particle index.
    @ViewBuilder
    private func particleShape(index: Int) -> some View {
        if index % 2 == 0 {
            Circle()
        } else {
            RoundedRectangle(cornerRadius: 2)
                .rotationEffect(.degrees(Double.random(in: 0 ... 45)))
        }
    }

    /// Returns a random size for the particle at the given index.
    private func particleSize(index _: Int) -> CGFloat {
        CGFloat.random(in: 6 ... 12)
    }
}
