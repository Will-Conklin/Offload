// Intent: Provide shallow navigation with a persistent capture entry point aligned to ADHD-friendly guardrails.
//
//  MainTabView.swift
//  Offload
//
//  Created by Claude Code on 12/30/25.
//

import SwiftUI
import SwiftData

// AGENT NAV
// - TabView Shell
// - Floating Capture Button
// - Capture Sheet Presentation

struct MainTabView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedTab: Tab = .captures
    @State private var showingCapture = false

    var body: some View {
        TabView(selection: $selectedTab) {
            CapturesView()
                .tabItem {
                    Label("Captures", systemImage: Icons.inbox)
                }
                .tag(Tab.captures)

            OrganizeView(scope: .plans)
                .tabItem {
                    Label("Plans", systemImage: Icons.plans)
                }
                .tag(Tab.plans)

            OrganizeView(scope: .lists)
                .tabItem {
                    Label("Lists", systemImage: Icons.lists)
                }
                .tag(Tab.lists)

            OrganizeView(scope: .communications)
                .tabItem {
                    Label("Comms", systemImage: Icons.communications)
                }
                .tag(Tab.communications)
        }
        .tint(Theme.Colors.accentPrimary(colorScheme, style: themeManager.currentStyle))
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                // Floating Action Button for quick capture
                Button {
                    showingCapture = true
                } label: {
                    Label {
                        Text("Capture")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.white)
                            .padding(.top, 2)
                    } icon: {
                        Image(systemName: Icons.capture)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color.white)
                    }
                    .padding(.vertical, Theme.Spacing.sm)
                    .padding(.horizontal, Theme.Spacing.md)
                    .frame(minWidth: Theme.HitTarget.minimum.width,
                           minHeight: Theme.HitTarget.minimum.height)
                    .background(
                        Capsule()
                            .fill(Theme.Colors.accentPrimary(colorScheme, style: themeManager.currentStyle))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(Theme.Colors.focusRing(colorScheme, style: themeManager.currentStyle), lineWidth: 2)
                    )
                    .shadow(color: Theme.Colors.focusRing(colorScheme, style: themeManager.currentStyle).opacity(0.35),
                            radius: Theme.Shadows.elevationMd,
                            y: 4)
                }
                .accessibilityLabel("Capture new entry")
                .accessibilityHint("Opens quick capture sheet; you can organize later")
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.top, Theme.Spacing.sm)
            .padding(.bottom, Theme.Spacing.sm)
            .offset(y: -Theme.Spacing.lg)
            .background(Color.clear)
        }
        .sheet(isPresented: $showingCapture) {
            CaptureView()
        }
    }

    enum Tab {
        case captures
        case plans
        case lists
        case communications
    }
}

#Preview {
    MainTabView()
        .modelContainer(PersistenceController.preview)
        .environmentObject(ThemeManager.shared)
}
