// Intent: Define Offload design tokens aligned with ADHD-friendly guardrails (calm palette, spacing, focus states).
//
//  Theme.swift
//  Offload
//
//  Created by Claude Code on 12/30/25.
//

import SwiftUI
import UIKit

// AGENT NAV
// - ThemeStyle
// - Colors
// - Typography
// - Materials
// - Gradients
// - Spacing
// - Cards
// - Corner Radius
// - Shadows
// - Animations
// - Hit Targets

/// Available color themes for the app
enum ThemeStyle: String, CaseIterable, Identifiable {
    case blueCool = "Blue Cool"
    case sageStone = "Sage & Stone"
    case lavenderCalm = "Lavender Calm"
    case oceanMinimal = "Ocean Minimal"
    case graphiteCobalt = "Graphite & Cobalt"
    case warmCharcoalEmber = "Warm Charcoal & Ember"
    case deepSlateSeafoam = "Deep Slate & Seafoam"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .blueCool:
            return "Classic blue-gray palette (default)"
        case .sageStone:
            return "Warm, grounded earth tones"
        case .lavenderCalm:
            return "Gentle, stress-reducing purple"
        case .oceanMinimal:
            return "Refined warm ocean blues"
        case .graphiteCobalt:
            return "Cool graphite with cobalt energy"
        case .warmCharcoalEmber:
            return "Warm charcoal with ember accents"
        case .deepSlateSeafoam:
            return "Deep slate with seafoam calm"
        }
    }
}

/// App-wide theme configuration
struct Theme {
    // MARK: - Colors

    struct Colors {
        private static func blend(_ base: Color, _ tint: Color, mix: CGFloat) -> Color {
            let baseColor = UIColor(base)
            let tintColor = UIColor(tint)
            var br: CGFloat = 0
            var bg: CGFloat = 0
            var bb: CGFloat = 0
            var ba: CGFloat = 0
            var tr: CGFloat = 0
            var tg: CGFloat = 0
            var tb: CGFloat = 0
            var ta: CGFloat = 0
            baseColor.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
            tintColor.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)
            let clampedMix = max(0, min(1, mix))
            return Color(
                red: br * (1 - clampedMix) + tr * clampedMix,
                green: bg * (1 - clampedMix) + tg * clampedMix,
                blue: bb * (1 - clampedMix) + tb * clampedMix,
                opacity: ba * (1 - clampedMix) + ta * clampedMix
            )
        }

        static func background(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> Color {
            switch style {
            case .blueCool:
                return colorScheme == .dark
                    ? Color(red: 0.07, green: 0.08, blue: 0.10) // #121517
                    : Color(red: 0.96, green: 0.98, blue: 0.99) // #F5FAFC
            case .sageStone:
                return colorScheme == .dark
                    ? Color(red: 0.11, green: 0.12, blue: 0.11) // #1C1E1B
                    : Color(red: 0.97, green: 0.96, blue: 0.95) // #F7F5F1
            case .lavenderCalm:
                return colorScheme == .dark
                    ? Color(red: 0.10, green: 0.09, blue: 0.15) // #1A1625
                    : Color(red: 0.97, green: 0.97, blue: 0.99) // #F7F7FC
            case .oceanMinimal:
                return colorScheme == .dark
                    ? Color(red: 0.06, green: 0.08, blue: 0.10) // #0F1419
                    : Color(red: 0.96, green: 0.98, blue: 0.99) // #F5FAFC
            case .graphiteCobalt:
                return colorScheme == .dark
                    ? Color(red: 0.05, green: 0.06, blue: 0.07) // #0D0F12
                    : Color(red: 0.97, green: 0.98, blue: 0.99) // #F7F9FC
            case .warmCharcoalEmber:
                return colorScheme == .dark
                    ? Color(red: 0.07, green: 0.06, blue: 0.05) // #12100E
                    : Color(red: 0.98, green: 0.97, blue: 0.96) // #F8F6F3
            case .deepSlateSeafoam:
                return colorScheme == .dark
                    ? Color(red: 0.04, green: 0.06, blue: 0.08) // #0B1014
                    : Color(red: 0.96, green: 0.98, blue: 0.99) // #F5FAFC
            }
        }

        static func surface(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> Color {
            switch style {
            case .blueCool:
                return colorScheme == .dark
                    ? Color(red: 0.12, green: 0.13, blue: 0.15) // #1F2127
                    : Color.white
            case .sageStone:
                return colorScheme == .dark
                    ? Color(red: 0.15, green: 0.16, blue: 0.15) // #272A26
                    : Color.white
            case .lavenderCalm:
                return colorScheme == .dark
                    ? Color(red: 0.15, green: 0.13, blue: 0.20) // #252034
                    : Color.white
            case .oceanMinimal:
                return colorScheme == .dark
                    ? Color(red: 0.10, green: 0.13, blue: 0.16) // #1A2028
                    : Color.white
            case .graphiteCobalt:
                return colorScheme == .dark
                    ? Color(red: 0.09, green: 0.10, blue: 0.13) // #171A20
                    : Color.white
            case .warmCharcoalEmber:
                return colorScheme == .dark
                    ? Color(red: 0.11, green: 0.10, blue: 0.09) // #1C1A18
                    : Color.white
            case .deepSlateSeafoam:
                return colorScheme == .dark
                    ? Color(red: 0.08, green: 0.11, blue: 0.13) // #141B22
                    : Color.white
            }
        }

        static func accentPrimary(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> Color {
            switch style {
            case .blueCool:
                return colorScheme == .dark
                    ? Color(red: 0.40, green: 0.70, blue: 0.98) // #66B3F7
                    : Color(red: 0.20, green: 0.45, blue: 0.85) // #3372D9
            case .sageStone:
                return colorScheme == .dark
                    ? Color(red: 0.56, green: 0.73, blue: 0.62) // #8FBA9D
                    : Color(red: 0.37, green: 0.52, blue: 0.46) // #5F8575
            case .lavenderCalm:
                return colorScheme == .dark
                    ? Color(red: 0.65, green: 0.59, blue: 0.84) // #A797DB
                    : Color(red: 0.48, green: 0.41, blue: 0.72) // #7B68B8
            case .oceanMinimal:
                return colorScheme == .dark
                    ? Color(red: 0.36, green: 0.68, blue: 0.90) // #5DADE6
                    : Color(red: 0.17, green: 0.50, blue: 0.72) // #2B7FB8
            case .graphiteCobalt:
                return colorScheme == .dark
                    ? Color(red: 0.31, green: 0.64, blue: 1.00) // #4FA3FF
                    : Color(red: 0.16, green: 0.43, blue: 0.80) // #2A6DCC
            case .warmCharcoalEmber:
                return colorScheme == .dark
                    ? Color(red: 0.88, green: 0.47, blue: 0.29) // #E1784A
                    : Color(red: 0.75, green: 0.35, blue: 0.18) // #C05A2E
            case .deepSlateSeafoam:
                return colorScheme == .dark
                    ? Color(red: 0.28, green: 0.76, blue: 0.72) // #48C2B8
                    : Color(red: 0.17, green: 0.61, blue: 0.58) // #2B9C93
            }
        }

        static func accentSecondary(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> Color {
            switch style {
            case .blueCool:
                return colorScheme == .dark
                    ? Color(red: 0.60, green: 0.75, blue: 0.85) // #99BFDA
                    : Color(red: 0.38, green: 0.64, blue: 0.80) // #61A3CC
            case .sageStone:
                return colorScheme == .dark
                    ? Color(red: 0.64, green: 0.71, blue: 0.68) // #A3B5AD
                    : Color(red: 0.62, green: 0.70, blue: 0.66) // #9EB3A8
            case .lavenderCalm:
                return colorScheme == .dark
                    ? Color(red: 0.71, green: 0.67, blue: 0.82) // #B5AAD1
                    : Color(red: 0.70, green: 0.66, blue: 0.82) // #B2A8D1
            case .oceanMinimal:
                return colorScheme == .dark
                    ? Color(red: 0.55, green: 0.72, blue: 0.80) // #8BB8CC
                    : Color(red: 0.43, green: 0.67, blue: 0.78) // #6EABC7
            case .graphiteCobalt:
                return colorScheme == .dark
                    ? Color(red: 0.44, green: 0.71, blue: 1.00) // #6FB6FF
                    : Color(red: 0.38, green: 0.60, blue: 0.88) // #6199E0
            case .warmCharcoalEmber:
                return colorScheme == .dark
                    ? Color(red: 0.95, green: 0.63, blue: 0.42) // #F2A06B
                    : Color(red: 0.87, green: 0.57, blue: 0.35) // #DE9159
            case .deepSlateSeafoam:
                return colorScheme == .dark
                    ? Color(red: 0.45, green: 0.84, blue: 0.81) // #74D6CE
                    : Color(red: 0.36, green: 0.76, blue: 0.73) // #5BC2BA
            }
        }

        static func success(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> Color {
            switch style {
            case .blueCool:
                return colorScheme == .dark
                    ? Color(red: 0.40, green: 0.80, blue: 0.55) // #66CD8C
                    : Color(red: 0.30, green: 0.65, blue: 0.56) // #4DA68F
            case .sageStone:
                return colorScheme == .dark
                    ? Color(red: 0.40, green: 0.79, blue: 0.61) // #66C89B
                    : Color(red: 0.29, green: 0.61, blue: 0.50) // #4A9B7F
            case .lavenderCalm:
                return colorScheme == .dark
                    ? Color(red: 0.42, green: 0.79, blue: 0.62) // #6BC99D
                    : Color(red: 0.37, green: 0.66, blue: 0.56) // #5FA88F
            case .oceanMinimal:
                return colorScheme == .dark
                    ? Color(red: 0.37, green: 0.80, blue: 0.60) // #5FCC9A
                    : Color(red: 0.24, green: 0.61, blue: 0.50) // #3D9B7F
            case .graphiteCobalt:
                return colorScheme == .dark
                    ? Color(red: 0.40, green: 0.82, blue: 0.60) // #66D199
                    : Color(red: 0.26, green: 0.62, blue: 0.50) // #429E7F
            case .warmCharcoalEmber:
                return colorScheme == .dark
                    ? Color(red: 0.45, green: 0.81, blue: 0.62) // #73CF9E
                    : Color(red: 0.30, green: 0.62, blue: 0.52) // #4C9E85
            case .deepSlateSeafoam:
                return colorScheme == .dark
                    ? Color(red: 0.38, green: 0.82, blue: 0.64) // #61D1A3
                    : Color(red: 0.24, green: 0.61, blue: 0.50) // #3D9B7F
            }
        }

        static func caution(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> Color {
            switch style {
            case .blueCool:
                return colorScheme == .dark
                    ? Color(red: 0.95, green: 0.75, blue: 0.30) // #F2C04D
                    : Color(red: 0.90, green: 0.66, blue: 0.20) // #E6A834
            case .sageStone:
                return colorScheme == .dark
                    ? Color(red: 0.90, green: 0.72, blue: 0.41) // #E5B869
                    : Color(red: 0.79, green: 0.59, blue: 0.31) // #C99750
            case .lavenderCalm:
                return colorScheme == .dark
                    ? Color(red: 0.90, green: 0.74, blue: 0.44) // #E5BD6F
                    : Color(red: 0.78, green: 0.63, blue: 0.33) // #C7A053
            case .oceanMinimal:
                return colorScheme == .dark
                    ? Color(red: 0.95, green: 0.78, blue: 0.39) // #F2C764
                    : Color(red: 0.84, green: 0.63, blue: 0.27) // #D6A045
            case .graphiteCobalt:
                return colorScheme == .dark
                    ? Color(red: 0.95, green: 0.77, blue: 0.38) // #F2C460
                    : Color(red: 0.83, green: 0.62, blue: 0.26) // #D49E42
            case .warmCharcoalEmber:
                return colorScheme == .dark
                    ? Color(red: 0.94, green: 0.72, blue: 0.36) // #F0B85C
                    : Color(red: 0.82, green: 0.58, blue: 0.25) // #D19440
            case .deepSlateSeafoam:
                return colorScheme == .dark
                    ? Color(red: 0.95, green: 0.78, blue: 0.39) // #F2C764
                    : Color(red: 0.84, green: 0.63, blue: 0.27) // #D6A045
            }
        }

        static func destructive(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> Color {
            switch style {
            case .blueCool:
                return colorScheme == .dark
                    ? Color(red: 0.95, green: 0.45, blue: 0.45) // #F27272
                    : Color(red: 0.85, green: 0.25, blue: 0.25) // #DA4040
            case .sageStone:
                return colorScheme == .dark
                    ? Color(red: 0.88, green: 0.50, blue: 0.50) // #E08080
                    : Color(red: 0.77, green: 0.33, blue: 0.33) // #C55555
            case .lavenderCalm:
                return colorScheme == .dark
                    ? Color(red: 0.90, green: 0.54, blue: 0.62) // #E5899D
                    : Color(red: 0.78, green: 0.36, blue: 0.44) // #C65B6F
            case .oceanMinimal:
                return colorScheme == .dark
                    ? Color(red: 0.95, green: 0.50, blue: 0.50) // #F28080
                    : Color(red: 0.80, green: 0.33, blue: 0.33) // #CC5555
            case .graphiteCobalt:
                return colorScheme == .dark
                    ? Color(red: 0.95, green: 0.50, blue: 0.50) // #F28080
                    : Color(red: 0.81, green: 0.33, blue: 0.33) // #CF5454
            case .warmCharcoalEmber:
                return colorScheme == .dark
                    ? Color(red: 0.93, green: 0.50, blue: 0.46) // #ED8076
                    : Color(red: 0.79, green: 0.33, blue: 0.30) // #C9554C
            case .deepSlateSeafoam:
                return colorScheme == .dark
                    ? Color(red: 0.95, green: 0.50, blue: 0.50) // #F28080
                    : Color(red: 0.80, green: 0.33, blue: 0.33) // #CC5555
            }
        }

        static func textPrimary(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> Color {
            switch style {
            case .blueCool:
                return colorScheme == .dark
                    ? Color(red: 0.90, green: 0.92, blue: 0.94) // #E6EAEF
                    : Color(red: 0.10, green: 0.12, blue: 0.16) // #1A1F28
            case .sageStone:
                return colorScheme == .dark
                    ? Color(red: 0.92, green: 0.94, blue: 0.93) // #EAF0ED
                    : Color(red: 0.17, green: 0.21, blue: 0.19) // #2C3531
            case .lavenderCalm:
                return colorScheme == .dark
                    ? Color(red: 0.93, green: 0.91, blue: 0.96) // #EDE9F4
                    : Color(red: 0.18, green: 0.15, blue: 0.22) // #2E2639
            case .oceanMinimal:
                return colorScheme == .dark
                    ? Color(red: 0.91, green: 0.93, blue: 0.95) // #E8EDF2
                    : Color(red: 0.12, green: 0.16, blue: 0.21) // #1F2835
            case .graphiteCobalt:
                return colorScheme == .dark
                    ? Color(red: 0.92, green: 0.94, blue: 0.96) // #EBEFF5
                    : Color(red: 0.11, green: 0.13, blue: 0.17) // #1B222B
            case .warmCharcoalEmber:
                return colorScheme == .dark
                    ? Color(red: 0.94, green: 0.92, blue: 0.90) // #F0EAE6
                    : Color(red: 0.16, green: 0.14, blue: 0.12) // #292420
            case .deepSlateSeafoam:
                return colorScheme == .dark
                    ? Color(red: 0.91, green: 0.94, blue: 0.96) // #E8F0F5
                    : Color(red: 0.12, green: 0.16, blue: 0.20) // #1F2833
            }
        }

        static func textSecondary(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> Color {
            switch style {
            case .blueCool:
                return colorScheme == .dark
                    ? Color(red: 0.65, green: 0.68, blue: 0.72) // #A5ADB8
                    : Color(red: 0.30, green: 0.34, blue: 0.40) // #4C5666
            case .sageStone:
                return colorScheme == .dark
                    ? Color(red: 0.72, green: 0.77, blue: 0.75) // #B8C5BF
                    : Color(red: 0.36, green: 0.41, blue: 0.39) // #5C6963
            case .lavenderCalm:
                return colorScheme == .dark
                    ? Color(red: 0.71, green: 0.68, blue: 0.78) // #B5AEC7
                    : Color(red: 0.34, green: 0.32, blue: 0.44) // #57516F
            case .oceanMinimal:
                return colorScheme == .dark
                    ? Color(red: 0.66, green: 0.72, blue: 0.78) // #A8B8C7
                    : Color(red: 0.30, green: 0.36, blue: 0.44) // #4D5B70
            case .graphiteCobalt:
                return colorScheme == .dark
                    ? Color(red: 0.67, green: 0.72, blue: 0.78) // #ABB8C7
                    : Color(red: 0.31, green: 0.36, blue: 0.44) // #4F5C70
            case .warmCharcoalEmber:
                return colorScheme == .dark
                    ? Color(red: 0.76, green: 0.71, blue: 0.66) // #C1B5A8
                    : Color(red: 0.36, green: 0.32, blue: 0.28) // #5C5147
            case .deepSlateSeafoam:
                return colorScheme == .dark
                    ? Color(red: 0.66, green: 0.73, blue: 0.78) // #A8BAC7
                    : Color(red: 0.30, green: 0.36, blue: 0.43) // #4D5C6E
            }
        }

        static func borderMuted(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> Color {
            switch style {
            case .blueCool:
                return colorScheme == .dark
                    ? Color(red: 0.26, green: 0.29, blue: 0.34) // #414B56
                    : Color(red: 0.90, green: 0.92, blue: 0.95) // #E6EBF2
            case .sageStone:
                return colorScheme == .dark
                    ? Color(red: 0.25, green: 0.27, blue: 0.25) // #3F4540
                    : Color(red: 0.91, green: 0.90, blue: 0.88) // #E8E5E0
            case .lavenderCalm:
                return colorScheme == .dark
                    ? Color(red: 0.23, green: 0.20, blue: 0.29) // #3A344A
                    : Color(red: 0.92, green: 0.91, blue: 0.95) // #EAE7F2
            case .oceanMinimal:
                return colorScheme == .dark
                    ? Color(red: 0.23, green: 0.27, blue: 0.32) // #3A4652
                    : Color(red: 0.90, green: 0.93, blue: 0.96) // #E6EEF5
            case .graphiteCobalt:
                return colorScheme == .dark
                    ? Color(red: 0.22, green: 0.26, blue: 0.32) // #384252
                    : Color(red: 0.90, green: 0.93, blue: 0.96) // #E6EEF5
            case .warmCharcoalEmber:
                return colorScheme == .dark
                    ? Color(red: 0.24, green: 0.21, blue: 0.19) // #3D3631
                    : Color(red: 0.92, green: 0.89, blue: 0.86) // #EAE3DB
            case .deepSlateSeafoam:
                return colorScheme == .dark
                    ? Color(red: 0.21, green: 0.26, blue: 0.30) // #36424C
                    : Color(red: 0.90, green: 0.93, blue: 0.96) // #E6EEF5
            }
        }

        static func cardBackground(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> Color {
            let base = surface(colorScheme, style: style)
            let tint = accentSecondary(colorScheme, style: style)
            return blend(base, tint, mix: colorScheme == .dark ? 0.42 : 0.32)
        }

        static func focusRing(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> Color {
            colorScheme == .dark
                ? accentSecondary(colorScheme, style: style).opacity(0.9)
                : accentSecondary(colorScheme, style: style).opacity(0.8)
        }
    }

    // MARK: - Typography

    struct Typography {
        // MARK: - Standard Text Styles (with Dynamic Type support)

        static let largeTitle = Font.largeTitle
        static let title = Font.title
        static let title2 = Font.title2
        static let title3 = Font.title3
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2
        static let monospacedBody = Font.body.monospacedDigit()

        // MARK: - Semantic Styles (application-specific)

        /// Title for cards, sections, and main content areas
        static let cardTitle = Font.title3.weight(.semibold)
        static let cardTitleEmphasis = Font.title3.weight(.bold)

        /// Body text for cards and descriptions
        static let cardBody = Font.callout
        static let cardBodyEmphasis = Font.callout.weight(.semibold)

        /// Button labels across the app
        static let buttonLabel = Font.headline
        static let buttonLabelEmphasis = Font.headline.weight(.semibold)

        /// Input field labels
        static let inputLabel = Font.subheadline
        static let inputLabelEmphasis = Font.subheadline.weight(.semibold)

        /// Error and validation messages
        static let errorText = Font.caption

        /// Metadata and timestamps
        static let metadata = Font.caption
        static let metadataMonospaced = Font.caption.monospacedDigit()

        /// Badge text (lifecycle states, categories, etc.)
        static let badge = Font.caption2
        static let badgeEmphasis = Font.caption2.weight(.semibold)

        // MARK: - Line Spacing

        /// Tight line spacing for compact layouts
        static let lineSpacingTight: CGFloat = 2

        /// Normal line spacing (default)
        static let lineSpacingNormal: CGFloat = 6

        /// Relaxed line spacing for readability
        static let lineSpacingRelaxed: CGFloat = 10
    }

    // MARK: - Materials

    struct Materials {
        static let glass = Material.ultraThin
        static let glassStrong = Material.thin
        static let glassOverlayOpacity: Double = 0.6

        static func glassOverlay(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark
                ? Color.black
                : Color.white
        }
    }

    // MARK: - Gradients

    struct Gradients {
        static func accentPrimary(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> LinearGradient {
            LinearGradient(
                colors: [
                    Colors.accentPrimary(colorScheme, style: style),
                    Colors.accentSecondary(colorScheme, style: style).opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static func appBackground(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> LinearGradient {
            LinearGradient(
                colors: [
                    Colors.background(colorScheme, style: style),
                    Colors.accentSecondary(colorScheme, style: style)
                        .opacity(colorScheme == .dark ? 0.08 : 0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static func surfaceGlow(_ colorScheme: ColorScheme, style: ThemeStyle = .blueCool) -> RadialGradient {
            RadialGradient(
                colors: [
                    Colors.accentSecondary(colorScheme, style: style).opacity(0.35),
                    Colors.surface(colorScheme, style: style).opacity(0.1)
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 180
            )
        }
    }

    // MARK: - Spacing

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 18
        static let lg: CGFloat = 28
        static let xl: CGFloat = 36
        static let xxl: CGFloat = 48

        // TODO: Add more spacing scales as needed
    }

    // MARK: - Cards

    struct Cards {
        static let rowHeight: CGFloat = 96
        static let pressScale: CGFloat = 0.985
        static let horizontalInset: CGFloat = Spacing.lg
        static let verticalInset: CGFloat = Spacing.sm
    }

    // MARK: - Corner Radius

    struct CornerRadius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28

        // TODO: Add component-specific radii
    }

    // MARK: - Shadows

    struct Shadows {
        static let elevationXs: CGFloat = 1
        static let elevationSm: CGFloat = 4
        static let elevationMd: CGFloat = 8

        static func ambient(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color.black.opacity(0.35) : Color.black.opacity(0.08)
        }
    }

    // MARK: - Animations

    struct Animations {
        static let springDefault = Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.1)
        static let springSnappy = Animation.spring(response: 0.25, dampingFraction: 0.75, blendDuration: 0.1)
        static let easeInOutShort = Animation.easeInOut(duration: 0.2)
    }

    // MARK: - Hit Targets

    struct HitTarget {
        static let minimum = CGSize(width: 44, height: 44)
    }
}
