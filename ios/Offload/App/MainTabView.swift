// Purpose: App entry points and root navigation.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Keep navigation flow consistent with MainTabView -> NavigationStack -> sheets.

//  Flat design with floating pill tab bar

import SwiftUI
import SwiftData


struct MainTabView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedTab: Tab = .review
    @State private var quickCaptureMode: CaptureComposeMode?

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        TabContent(selectedTab: selectedTab)
            .safeAreaInset(edge: .bottom) {
                FloatingTabBar(
                    selectedTab: $selectedTab,
                    colorScheme: colorScheme,
                    style: style,
                    onQuickWrite: { quickCaptureMode = .write },
                    onQuickVoice: { quickCaptureMode = .voice }
                )
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.top, Theme.Spacing.sm)
                .padding(.bottom, Theme.Spacing.sm)
            }
            .sheet(item: $quickCaptureMode) { mode in
                CaptureComposeView(mode: mode)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
    }

    enum Tab: CaseIterable {
        case home
        case review
        case organize
        case account

        var icon: String {
            switch self {
            case .home: return Icons.home
            case .review: return Icons.review
            case .organize: return Icons.organize
            case .account: return Icons.account
            }
        }

        var selectedIcon: String {
            switch self {
            case .home: return Icons.homeSelected
            case .review: return Icons.reviewSelected
            case .organize: return Icons.organizeSelected
            case .account: return Icons.accountSelected
            }
        }

        var label: String {
            switch self {
            case .home: return "Home"
            case .review: return "Review"
            case .organize: return "Organize"
            case .account: return "Account"
            }
        }
    }
}

// MARK: - Tab Content

private struct TabContent: View {
    let selectedTab: MainTabView.Tab

    var body: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .review:
            CaptureView(navigationTitle: "Review")
        case .organize:
            OrganizeView()
        case .account:
            AccountView()
        }
    }
}

// MARK: - Floating Tab Bar

private struct FloatingTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    let colorScheme: ColorScheme
    let style: ThemeStyle
    let onQuickWrite: () -> Void
    let onQuickVoice: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            // Left tab
            TabButton(
                tab: .home,
                isSelected: selectedTab == .home,
                colorScheme: colorScheme,
                style: style
            ) { selectedTab = .home }

            TabButton(
                tab: .review,
                isSelected: selectedTab == .review,
                colorScheme: colorScheme,
                style: style
            ) { selectedTab = .review }

            Spacer(minLength: Theme.Spacing.sm)

            OffloadCTA(
                colorScheme: colorScheme,
                style: style,
                onQuickWrite: onQuickWrite,
                onQuickVoice: onQuickVoice
            )

            Spacer(minLength: Theme.Spacing.sm)

            // Right tab
            TabButton(
                tab: .organize,
                isSelected: selectedTab == .organize,
                colorScheme: colorScheme,
                style: style
            ) { selectedTab = .organize }

            TabButton(
                tab: .account,
                isSelected: selectedTab == .account,
                colorScheme: colorScheme,
                style: style
            ) { selectedTab = .account }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.md)
        .background(
            Capsule()
                .fill(Theme.Colors.surface(colorScheme, style: style))
                .overlay(
                    Capsule()
                        .stroke(Theme.Colors.primary(colorScheme, style: style).opacity(0.35), lineWidth: 1)
                )
                .shadow(color: Theme.Shadows.ultraLight(colorScheme), radius: Theme.Shadows.elevationUltraLight, y: Theme.Shadows.offsetYUltraLight)
        )
    }
}

// MARK: - Quick Capture Button

private struct QuickCaptureButton: View {
    let title: String
    let iconName: String
    let colorScheme: ColorScheme
    let style: ThemeStyle
    let action: () -> Void
    var size: CGFloat = 62

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                AppIcon(name: iconName, size: 18)
                Text(title)
                    .font(Theme.Typography.caption)
            }
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md, style: .continuous)
                    .fill(Theme.Colors.buttonDark(colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md, style: .continuous)
                            .stroke(Theme.Colors.primary(colorScheme, style: style).opacity(0.35), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

// MARK: - Offload CTA

private struct OffloadCTA: View {
    let colorScheme: ColorScheme
    let style: ThemeStyle
    let onQuickWrite: () -> Void
    let onQuickVoice: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            HStack(spacing: Theme.Spacing.xs) {
                QuickCaptureButton(
                    title: "Write",
                    iconName: Icons.add,
                    colorScheme: colorScheme,
                    style: style,
                    action: onQuickWrite,
                    size: 56
                )

                QuickCaptureButton(
                    title: "Voice",
                    iconName: Icons.microphone,
                    colorScheme: colorScheme,
                    style: style,
                    action: onQuickVoice,
                    size: 56
                )
            }

            Text("Offload")
                .font(Theme.Typography.caption2)
                .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
        }
        .padding(.horizontal, Theme.Spacing.xs)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Offload quick actions")
    }
}

// MARK: - Tab Button

private struct TabButton: View {
    let tab: MainTabView.Tab
    let isSelected: Bool
    let colorScheme: ColorScheme
    let style: ThemeStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                AppIcon(name: isSelected ? tab.selectedIcon : tab.icon, size: 24)
                Text(tab.label)
                    .font(Theme.Typography.caption)
            }
            .foregroundStyle(
                isSelected
                    ? Theme.Colors.primary(colorScheme, style: style)
                    : Theme.Colors.textSecondary(colorScheme, style: style)
            )
            .frame(minWidth: 64, minHeight: 64)
            .background(
                Group {
                    if isSelected {
                        Theme.Colors.secondary(colorScheme, style: style)
                            .opacity(Theme.Opacity.tabButtonSelection(colorScheme))
                            .clipShape(Capsule())
                    } else {
                        Color.clear
                    }
                }
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.label)
    }
}

#Preview {
    MainTabView()
        .modelContainer(PersistenceController.preview)
        .environmentObject(ThemeManager.shared)
}
