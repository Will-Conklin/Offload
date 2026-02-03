// Purpose: Mid-Century Modern custom icon shapes
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Keep icons geometric and MCM-styled with atomic age character.

import SwiftUI

// MARK: - Atomic House Icon

struct AtomicHouseIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Flat/shed roof (horizontal MCM style)
        let roofRect = CGRect(
            x: rect.minX + rect.width * 0.1,
            y: rect.minY + rect.height * 0.2,
            width: rect.width * 0.8,
            height: rect.height * 0.08
        )
        path.addRoundedRect(in: roofRect, cornerSize: CGSize(width: 2, height: 2))

        // Main house body (rectangular MCM structure)
        let bodyRect = CGRect(
            x: rect.minX + rect.width * 0.15,
            y: roofRect.maxY,
            width: rect.width * 0.7,
            height: rect.height * 0.55
        )
        path.addRect(bodyRect)

        // Large window (floor-to-ceiling MCM feature)
        let windowRect = CGRect(
            x: rect.midX - rect.width * 0.15,
            y: bodyRect.minY + rect.height * 0.1,
            width: rect.width * 0.3,
            height: rect.height * 0.35
        )
        path.addRect(windowRect)

        // Base/foundation line
        let baseRect = CGRect(
            x: rect.minX + rect.width * 0.1,
            y: bodyRect.maxY,
            width: rect.width * 0.8,
            height: rect.height * 0.05
        )
        path.addRect(baseRect)

        return path
    }
}

// MARK: - Atomic Clipboard Icon

struct AtomicClipboardIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Clipboard body (rounded rectangle)
        let clipboardRect = CGRect(
            x: rect.minX + rect.width * 0.2,
            y: rect.minY + rect.height * 0.1,
            width: rect.width * 0.6,
            height: rect.height * 0.8
        )
        path.addRoundedRect(in: clipboardRect, cornerSize: CGSize(width: 3, height: 3))

        // Clip at top
        let clipRect = CGRect(
            x: rect.midX - rect.width * 0.15,
            y: rect.minY,
            width: rect.width * 0.3,
            height: rect.height * 0.12
        )
        path.addRoundedRect(in: clipRect, cornerSize: CGSize(width: 2, height: 2))

        // Three horizontal lines (list items)
        let lineY1 = clipboardRect.minY + clipboardRect.height * 0.35
        let lineY2 = clipboardRect.minY + clipboardRect.height * 0.5
        let lineY3 = clipboardRect.minY + clipboardRect.height * 0.65
        let lineLeft = clipboardRect.minX + 6
        let lineRight = clipboardRect.maxX - 6

        path.move(to: CGPoint(x: lineLeft, y: lineY1))
        path.addLine(to: CGPoint(x: lineRight, y: lineY1))

        path.move(to: CGPoint(x: lineLeft, y: lineY2))
        path.addLine(to: CGPoint(x: lineRight, y: lineY2))

        path.move(to: CGPoint(x: lineLeft, y: lineY3))
        path.addLine(to: CGPoint(x: lineRight, y: lineY3))

        return path
    }
}

// MARK: - Atomic Drawer Icon

struct AtomicDrawerIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Drawer body
        let drawerRect = CGRect(
            x: rect.minX + rect.width * 0.1,
            y: rect.minY + rect.height * 0.15,
            width: rect.width * 0.8,
            height: rect.height * 0.7
        )
        path.addRoundedRect(in: drawerRect, cornerSize: CGSize(width: 4, height: 4))

        // Boomerang pull handle (kidney shape - iconic MCM)
        let handleCenter = CGPoint(x: rect.midX, y: rect.midY)
        let handleWidth: CGFloat = 16
        let handleHeight: CGFloat = 6

        var handlePath = Path()
        handlePath.move(to: CGPoint(x: handleCenter.x - handleWidth / 2, y: handleCenter.y - handleHeight / 2))
        handlePath.addQuadCurve(
            to: CGPoint(x: handleCenter.x + handleWidth / 2, y: handleCenter.y - handleHeight / 2),
            control: CGPoint(x: handleCenter.x, y: handleCenter.y - handleHeight)
        )
        handlePath.addQuadCurve(
            to: CGPoint(x: handleCenter.x - handleWidth / 2, y: handleCenter.y - handleHeight / 2),
            control: CGPoint(x: handleCenter.x, y: handleCenter.y + handleHeight / 2)
        )

        path.addPath(handlePath)

        // Small circle accent (label hole)
        path.addEllipse(in: CGRect(
            x: handleCenter.x - 1.5,
            y: drawerRect.maxY - 8,
            width: 3,
            height: 3
        ))

        return path
    }
}

// MARK: - Atomic Person Icon

struct AtomicPersonIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Circle head
        let headRadius = rect.width * 0.22
        let headCenter = CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.28)
        path.addEllipse(in: CGRect(
            x: headCenter.x - headRadius,
            y: headCenter.y - headRadius,
            width: headRadius * 2,
            height: headRadius * 2
        ))

        // Shoulders/bust (curved trapezoid)
        let shoulderTop = headCenter.y + headRadius + 2
        let shoulderBottom = rect.minY + rect.height * 0.75
        let shoulderWidth = rect.width * 0.6

        path.move(to: CGPoint(x: rect.midX - shoulderWidth * 0.3, y: shoulderTop))

        // Left shoulder curve
        path.addQuadCurve(
            to: CGPoint(x: rect.midX - shoulderWidth * 0.5, y: shoulderBottom),
            control: CGPoint(x: rect.midX - shoulderWidth * 0.45, y: shoulderTop + (shoulderBottom - shoulderTop) * 0.3)
        )

        // Bottom line
        path.addLine(to: CGPoint(x: rect.midX + shoulderWidth * 0.5, y: shoulderBottom))

        // Right shoulder curve
        path.addQuadCurve(
            to: CGPoint(x: rect.midX + shoulderWidth * 0.3, y: shoulderTop),
            control: CGPoint(x: rect.midX + shoulderWidth * 0.45, y: shoulderTop + (shoulderBottom - shoulderTop) * 0.3)
        )

        path.closeSubpath()

        return path
    }
}

// MARK: - MCM Icon View

struct MCMIcon: View {
    enum IconType {
        case home
        case review
        case organize
        case account
    }

    let type: IconType
    let isSelected: Bool
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        Group {
            switch type {
            case .home:
                AtomicHouseIcon()
                    .stroke(color, lineWidth: lineWidth)
            case .review:
                AtomicClipboardIcon()
                    .stroke(color, lineWidth: lineWidth)
            case .organize:
                AtomicDrawerIcon()
                    .stroke(color, lineWidth: lineWidth)
            case .account:
                AtomicPersonIcon()
                    .stroke(color, lineWidth: lineWidth)
            }
        }
    }
}
