// Purpose: Account view with auth states and full settings sections.
// Authority: Code-level
// Governed by: CLAUDE.md
// Additional instructions: Avoid introducing feature logic that belongs in repositories.

import AuthenticationServices
import SwiftData
import SwiftUI

struct AccountView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var authManager: AuthManager

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        NavigationStack {
            Group {
                switch authManager.state {
                case .signedOut, .signingIn:
                    SignedOutView()
                case .signedIn:
                    SignedInView()
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Signed Out View

private struct SignedOutView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var authManager: AuthManager

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            // Account icon in bordered circle
            ZStack {
                Circle()
                    .stroke(Theme.Colors.borderMuted(colorScheme, style: style), lineWidth: 2)
                    .frame(width: 80, height: 80)
                AppIcon(name: Icons.account, size: 40)
                    .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
            }

            // Heading
            Text("YOUR ACCOUNT")
                .font(Theme.Typography.title2)
                .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))

            // Value proposition
            Text("Sign in to track your AI usage, sync preferences, and manage your data.")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            // Sign In With Apple button
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleSignInResult(result)
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
            .padding(.horizontal, Theme.Spacing.xl)
            .accessibilityLabel("Sign in with Apple")

            Spacer()

            // Version number
            Text("Version \(appVersion)")
                .font(Theme.Typography.metadata)
                .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                .padding(.bottom, Theme.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Surface.background(colorScheme, style: style))
    }

    /// Handles the Sign in with Apple completion result.
    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                return
            }
            authManager.handleSignInResult(credential: credential)
        case .failure:
            break
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

// MARK: - Signed In View

private struct SignedInView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.md) {
                ProfileCard()
                UsageCard()
                CloudAICard()
                AppearanceCard()
                TagsCard()
                AboutCard()
                SignOutButton()
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
        }
        .background(Theme.Surface.background(colorScheme, style: style))
    }
}

// MARK: - Profile Card

private struct ProfileCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var authManager: AuthManager

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        CardSurface(showsBorder: true) {
            HStack(spacing: Theme.Spacing.md) {
                // Initial-based avatar circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.Colors.accentPrimary(colorScheme, style: style),
                                    Theme.Colors.accentSecondary(colorScheme, style: style),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    Text(initials)
                        .font(Theme.Typography.title2)
                        .foregroundStyle(Theme.Colors.accentButtonText(colorScheme, style: style))
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    if let name = authManager.currentUser?.fullName, !name.isEmpty {
                        Text(name)
                            .font(Theme.Typography.cardTitle)
                            .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))
                    }
                    if let email = authManager.currentUser?.email {
                        Text(email)
                            .font(Theme.Typography.callout)
                            .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                    }
                }

                Spacer()
            }
            .padding(Theme.Spacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Profile")
    }

    private var initials: String {
        guard let name = authManager.currentUser?.fullName, !name.isEmpty else {
            return "?"
        }
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return "\(first)\(last)".uppercased()
    }
}

// MARK: - Usage Card

private struct UsageCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    private var style: ThemeStyle { themeManager.currentStyle }
    private let usageStore: UsageCounterStore = UserDefaultsUsageCounterStore()
    private let quota = 100

    private var features: [(label: String, key: String)] {
        [
            ("Breakdowns", "breakdowns"),
            ("Brain Dumps", "brain_dumps"),
            ("Decisions", "decisions"),
        ]
    }

    var body: some View {
        CardSurface(showsBorder: true) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("AI USAGE")
                    .font(Theme.Typography.cardTitle)
                    .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))

                ForEach(features, id: \.key) { feature in
                    usageRow(label: feature.label, count: usageStore.mergedCount(for: feature.key))
                }
            }
            .padding(Theme.Spacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("AI Usage")
    }

    /// Renders a single usage row with label, count, and progress bar.
    @ViewBuilder
    private func usageRow(label: String, count: Int) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack {
                Text(label)
                    .font(Theme.Typography.callout)
                    .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))
                Spacer()
                Text("\(count) / \(quota)")
                    .font(Theme.Typography.metadata)
                    .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                        .fill(Theme.Surface.card(colorScheme, style: style))
                        .frame(height: 8)

                    // Fill
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                        .fill(Theme.Colors.accentPrimary(colorScheme, style: style))
                        .frame(
                            width: max(0, min(geometry.size.width, geometry.size.width * CGFloat(count) / CGFloat(quota))),
                            height: 8
                        )
                }
            }
            .frame(height: 8)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(count) of \(quota) used")
    }
}

// MARK: - Cloud AI Card

private struct CloudAICard: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var isCloudAIEnabled: Bool

    private var style: ThemeStyle { themeManager.currentStyle }
    private let consentStore: CloudAIConsentStore = UserDefaultsCloudAIConsentStore()

    init() {
        let store = UserDefaultsCloudAIConsentStore()
        _isCloudAIEnabled = State(initialValue: store.isCloudAIEnabled)
    }

    var body: some View {
        CardSurface(showsBorder: true) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("CLOUD AI")
                        .font(Theme.Typography.cardTitle)
                        .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))
                    Text("Enable cloud-powered AI features")
                        .font(Theme.Typography.callout)
                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                }
                Spacer()
                Toggle("", isOn: $isCloudAIEnabled)
                    .labelsHidden()
                    .tint(Theme.Colors.accentPrimary(colorScheme, style: style))
                    .onChange(of: isCloudAIEnabled) { _, newValue in
                        consentStore.isCloudAIEnabled = newValue
                    }
            }
            .padding(Theme.Spacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Cloud AI")
        .accessibilityValue(isCloudAIEnabled ? "Enabled" : "Disabled")
    }
}

// MARK: - Appearance Card

private struct AppearanceCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        CardSurface(showsBorder: true) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("APPEARANCE")
                    .font(Theme.Typography.cardTitle)
                    .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))

                Picker("Appearance", selection: $themeManager.appearancePreference) {
                    ForEach(AppearancePreference.allCases) { preference in
                        Text(preference.displayName).tag(preference)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(Theme.Spacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Appearance")
    }
}

// MARK: - Tags Card

private struct TagsCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager
    @Query(sort: \Tag.name) private var tags: [Tag]

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        NavigationLink {
            TagManagementView()
        } label: {
            CardSurface(showsBorder: true) {
                HStack(spacing: Theme.Spacing.md) {
                    IconTile(
                        iconName: Icons.tag,
                        iconSize: 16,
                        tileSize: 44,
                        style: .secondaryOutlined(Theme.Colors.accentPrimary(colorScheme, style: style))
                    )

                    Text("MANAGE TAGS")
                        .font(Theme.Typography.cardTitle)
                        .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))

                    Spacer()

                    Text("\(tags.count)")
                        .font(Theme.Typography.callout)
                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))

                    AppIcon(name: Icons.chevronRight, size: 14)
                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                }
                .padding(Theme.Spacing.md)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Manage Tags")
        .accessibilityValue("\(tags.count) tags")
        .accessibilityHint("Opens tag management")
    }
}

// MARK: - About Card

private struct AboutCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        CardSurface(showsBorder: true) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("ABOUT")
                    .font(Theme.Typography.cardTitle)
                    .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))

                // Version
                HStack {
                    Text("Version")
                        .font(Theme.Typography.callout)
                        .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))
                    Spacer()
                    Text(appVersion)
                        .font(Theme.Typography.callout)
                        .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                }

                Divider()
                    .background(Theme.Colors.borderMuted(colorScheme, style: style))

                // Privacy Policy
                Link(destination: URL(string: "https://github.com/Will-Conklin/offload")!) {
                    HStack {
                        Text("Privacy Policy")
                            .font(Theme.Typography.callout)
                            .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))
                        Spacer()
                        AppIcon(name: Icons.externalLink, size: 12)
                            .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                    }
                }
                .accessibilityLabel("Privacy Policy")
                .accessibilityHint("Opens in browser")

                Divider()
                    .background(Theme.Colors.borderMuted(colorScheme, style: style))

                // Send Feedback
                Link(destination: URL(string: "https://github.com/Will-Conklin/offload/issues")!) {
                    HStack {
                        Text("Send Feedback")
                            .font(Theme.Typography.callout)
                            .foregroundStyle(Theme.Colors.textPrimary(colorScheme, style: style))
                        Spacer()
                        AppIcon(name: Icons.externalLink, size: 12)
                            .foregroundStyle(Theme.Colors.textSecondary(colorScheme, style: style))
                    }
                }
                .accessibilityLabel("Send Feedback")
                .accessibilityHint("Opens in browser")
            }
            .padding(Theme.Spacing.md)
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

// MARK: - Sign Out Button

private struct SignOutButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var authManager: AuthManager
    @State private var showingConfirmation = false

    private var style: ThemeStyle { themeManager.currentStyle }

    var body: some View {
        Button {
            showingConfirmation = true
        } label: {
            Text("Sign Out")
                .font(Theme.Typography.buttonLabel)
                .foregroundStyle(Theme.Colors.destructive(colorScheme, style: style))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.sm)
        }
        .accessibilityLabel("Sign Out")
        .accessibilityHint("Signs out of your account")
        .alert("Sign Out", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .padding(.top, Theme.Spacing.sm)
        .padding(.bottom, Theme.Spacing.lg)
    }
}

#Preview("Signed Out") {
    AccountView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(AuthManager())
}
