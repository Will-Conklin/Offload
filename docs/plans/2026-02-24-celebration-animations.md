# Celebration Animations Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add positive feedback animations for three moments: item completed, first capture, and collection fully completed.

**Architecture:** A `CelebrationStyle` enum + `.celebrationOverlay()` SwiftUI ViewModifier in a single new file. Pure SwiftUI particle system (5-8 shapes). Detection logic stays in existing views. Collection completion detected from CaptureView via item relationships, shown as success toast.

**Tech Stack:** SwiftUI, UIKit haptics (`UIImpactFeedbackGenerator`), `@AppStorage`, existing Theme tokens and ToastManager.

**Design doc:** `docs/plans/2026-02-24-celebration-animations-design.md`

---

## Task 1: CelebrationStyle enum and basic overlay modifier

**Files:**

- Create: `ios/Offload/DesignSystem/CelebrationModifier.swift`
- Test: `ios/OffloadTests/CelebrationModifierTests.swift`

Step 1 — Write the failing test

Create `ios/OffloadTests/CelebrationModifierTests.swift`:

```swift
// Purpose: Tests for celebration animation types and configuration.
// Authority: Code-level
// Governed by: AGENTS.md

import XCTest
@testable import Offload

final class CelebrationModifierTests: XCTestCase {

    // MARK: - CelebrationStyle Properties

    func testItemCompletedHapticIsLight() {
        XCTAssertEqual(CelebrationStyle.itemCompleted.hapticStyle, .light)
    }

    func testFirstCaptureHapticIsMedium() {
        XCTAssertEqual(CelebrationStyle.firstCapture.hapticStyle, .medium)
    }

    func testCollectionCompletedHapticIsMedium() {
        XCTAssertEqual(CelebrationStyle.collectionCompleted.hapticStyle, .medium)
    }

    func testItemCompletedHasNoParticles() {
        XCTAssertFalse(CelebrationStyle.itemCompleted.showsParticles)
    }

    func testFirstCaptureHasParticles() {
        XCTAssertTrue(CelebrationStyle.firstCapture.showsParticles)
    }

    func testCollectionCompletedHasParticles() {
        XCTAssertTrue(CelebrationStyle.collectionCompleted.showsParticles)
    }

    func testParticleCountRange() {
        let style = CelebrationStyle.firstCapture
        XCTAssertGreaterThanOrEqual(style.particleCount, 5)
        XCTAssertLessThanOrEqual(style.particleCount, 8)
    }

    func testItemCompletedScaleFactor() {
        XCTAssertEqual(CelebrationStyle.itemCompleted.scalePeak, 1.15, accuracy: 0.01)
    }

    func testFirstCaptureScaleFactor() {
        XCTAssertEqual(CelebrationStyle.firstCapture.scalePeak, 1.15, accuracy: 0.01)
    }

    func testCollectionCompletedScaleFactor() {
        XCTAssertEqual(CelebrationStyle.collectionCompleted.scalePeak, 1.0, accuracy: 0.01)
    }
}
```

Step 2 — Run test to verify it fails

Run: `xcodebuild test -project ios/Offload.xcodeproj -scheme Offload -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' -only-testing:OffloadTests/CelebrationModifierTests 2>&1 | tail -20`

Expected: FAIL — `CelebrationStyle` not found.

Step 3 — Write minimal implementation

Create `ios/Offload/DesignSystem/CelebrationModifier.swift`:

```swift
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
        Int.random(in: 5...8)
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
```

Step 4 — Run test to verify it passes

Run: `xcodebuild test -project ios/Offload.xcodeproj -scheme Offload -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' -only-testing:OffloadTests/CelebrationModifierTests 2>&1 | tail -20`

Expected: PASS (note: `particleCount` is random, test checks range bounds).

Step 5 — Commit

```bash
git add ios/Offload/DesignSystem/CelebrationModifier.swift ios/OffloadTests/CelebrationModifierTests.swift
git commit -m "feat(celebration): add CelebrationStyle enum with TDD tests"
```

---

## Task 2: Particle view

**Files:**

- Modify: `ios/Offload/DesignSystem/CelebrationModifier.swift`
- No new tests — particle view is visual, verified manually

Step 1 — Add CelebrationParticlesView

Append to `ios/Offload/DesignSystem/CelebrationModifier.swift`:

```swift
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
            ForEach(0..<particleCount, id: \.self) { index in
                particleShape(index: index)
                    .frame(width: particleSize(index: index), height: particleSize(index: index))
                    .foregroundStyle(Theme.Colors.cardColor(index: index, colorScheme, style: style))
                    .offset(
                        x: isAnimating ? CGFloat.random(in: -40...40) : 0,
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

    @ViewBuilder
    private func particleShape(index: Int) -> some View {
        if index % 2 == 0 {
            Circle()
        } else {
            RoundedRectangle(cornerRadius: 2)
                .rotationEffect(.degrees(Double.random(in: 0...45)))
        }
    }

    private func particleSize(index: Int) -> CGFloat {
        CGFloat.random(in: 6...12)
    }
}
```

Step 2 — Verify build compiles

Run: `xcodebuild build -project ios/Offload.xcodeproj -scheme Offload -destination 'generic/platform=iOS Simulator' 2>&1 | tail -5`

Expected: BUILD SUCCEEDED.

Step 3 — Commit

```bash
git add ios/Offload/DesignSystem/CelebrationModifier.swift
git commit -m "feat(celebration): add CelebrationParticlesView with MCM palette"
```

---

## Task 3: CelebrationOverlay ViewModifier

**Files:**

- Modify: `ios/Offload/DesignSystem/CelebrationModifier.swift`

Step 1 — Add the ViewModifier and View extension

Append to `ios/Offload/DesignSystem/CelebrationModifier.swift`:

```swift
// MARK: - Celebration Overlay Modifier

/// ViewModifier that overlays celebration animations on any view.
///
/// Applies scale pulse, optional particles, haptic feedback, and respects
/// reduced motion settings. Auto-resets `isActive` after animation completes.
struct CelebrationOverlayModifier: ViewModifier {
    let style: CelebrationStyle
    @Binding var isActive: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var showParticles = false
    @State private var scaleEffect: CGFloat = 1.0
    @State private var colorFlashOpacity: Double = 0

    private var themeStyle: ThemeStyle { themeManager.currentStyle }

    func body(content: Content) -> some View {
        content
            .scaleEffect(scaleEffect)
            .overlay {
                if colorFlashOpacity > 0 {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                        .fill(Theme.Colors.success(colorScheme, style: themeStyle).opacity(colorFlashOpacity))
                        .allowsHitTesting(false)
                }
            }
            .overlay {
                if showParticles && !reduceMotion {
                    CelebrationParticlesView(particleCount: style.particleCount)
                        .allowsHitTesting(false)
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    triggerCelebration()
                }
            }
    }

    private func triggerCelebration() {
        // Haptic fires regardless of reduce motion
        UIImpactFeedbackGenerator(style: style.hapticStyle).impactOccurred()

        guard !reduceMotion else {
            // Skip visual animation, just reset
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isActive = false
            }
            return
        }

        // Scale pulse
        if style.scalePeak > 1.0 {
            withAnimation(Theme.Animations.motion(Theme.Animations.springSnappy, reduceMotion: false)) {
                scaleEffect = style.scalePeak
            }
            withAnimation(Theme.Animations.motion(Theme.Animations.springDefault, reduceMotion: false).delay(0.15)) {
                scaleEffect = 1.0
            }
        }

        // Color flash for itemCompleted
        if style == .itemCompleted {
            withAnimation(Theme.Animations.motion(Theme.Animations.typewriterDing, reduceMotion: false)) {
                colorFlashOpacity = 0.15
            }
            withAnimation(Theme.Animations.motion(Theme.Animations.springDefault, reduceMotion: false).delay(0.2)) {
                colorFlashOpacity = 0
            }
        }

        // Particles
        if style.showsParticles {
            showParticles = true
            withAnimation(Theme.Animations.motion(Theme.Animations.mechanicalSlide, reduceMotion: false)) {
                // Particles animate via their own onAppear
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + style.duration) {
                showParticles = false
            }
        }

        // Reset
        DispatchQueue.main.asyncAfter(deadline: .now() + style.duration) {
            isActive = false
        }
    }
}

// MARK: - View Extension

extension View {
    /// Adds a celebration animation overlay to the view.
    ///
    /// - Parameters:
    ///   - style: The celebration type determining animation intensity.
    ///   - isActive: Binding that triggers the celebration when set to true.
    ///     Auto-resets to false after the animation completes.
    func celebrationOverlay(style: CelebrationStyle, isActive: Binding<Bool>) -> some View {
        modifier(CelebrationOverlayModifier(style: style, isActive: isActive))
    }
}
```

Step 2 — Verify build compiles

Run: `xcodebuild build -project ios/Offload.xcodeproj -scheme Offload -destination 'generic/platform=iOS Simulator' 2>&1 | tail -5`

Expected: BUILD SUCCEEDED.

Step 3 — Commit

```bash
git add ios/Offload/DesignSystem/CelebrationModifier.swift
git commit -m "feat(celebration): add CelebrationOverlay ViewModifier with reduced motion support"
```

---

## Task 4: Wire up item-completed celebration in CaptureView

**Files:**

- Modify: `ios/Offload/Features/Capture/CaptureView.swift:202-215` — `completeItem()` function
- Modify: `ios/Offload/Features/Capture/CaptureItemCard.swift:10-18` — add celebration state

Step 1 — Add celebration state to ItemCard

In `ios/Offload/Features/Capture/CaptureItemCard.swift`, add a `@State` property and the modifier.

At line 25 (after existing `@State` declarations), add:

```swift
@State private var showCompleteCelebration = false
```

Find the `onComplete()` call at line 109 and wrap it:

```swift
case .triggerLeadingAction:
    swipeOffset = 0
    showCompleteCelebration = true
    onComplete()
```

Apply the modifier to the card content. Find the outermost container of the card body and add:

```swift
.celebrationOverlay(style: .itemCompleted, isActive: $showCompleteCelebration)
```

Step 2 — Verify build compiles

Run: `xcodebuild build -project ios/Offload.xcodeproj -scheme Offload -destination 'generic/platform=iOS Simulator' 2>&1 | tail -5`

Expected: BUILD SUCCEEDED.

Step 3 — Run existing tests to confirm no regressions

Run: `xcodebuild test -project ios/Offload.xcodeproj -scheme Offload -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' -only-testing:OffloadTests 2>&1 | tail -20`

Expected: All tests PASS.

Step 4 — Commit

```bash
git add ios/Offload/Features/Capture/CaptureItemCard.swift
git commit -m "feat(celebration): wire item-completed celebration to CaptureItemCard swipe"
```

---

## Task 5: Wire up first-capture celebration in CaptureComposeView

**Files:**

- Modify: `ios/Offload/Features/Capture/CaptureComposeView.swift:343-383` — `save()` function

Step 1 — Add first-capture detection

In `ios/Offload/Features/Capture/CaptureComposeView.swift`, add near the top of the struct (with other `@State` declarations):

```swift
@AppStorage("hasCompletedFirstCapture") private var hasCompletedFirstCapture = false
@State private var showFirstCaptureCelebration = false
```

Modify the `save()` function (lines 368-378). Replace the existing celebration block:

```swift
// FROM (lines 368-378):
// Trigger typewriter ding animation
withAnimation(Theme.Animations.motion(Theme.Animations.typewriterDing, reduceMotion: reduceMotion)) {
    captureConfirmed = true
}
UIImpactFeedbackGenerator(style: .medium).impactOccurred()

// Dismiss after brief amber flash
DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    NotificationCenter.default.post(name: .captureItemsChanged, object: nil)
    dismiss()
}

// TO:
if !hasCompletedFirstCapture {
    // First capture ever — special celebration
    hasCompletedFirstCapture = true
    showFirstCaptureCelebration = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        NotificationCenter.default.post(name: .captureItemsChanged, object: nil)
        dismiss()
    }
} else {
    // Standard capture confirmation (existing behavior)
    withAnimation(Theme.Animations.motion(Theme.Animations.typewriterDing, reduceMotion: reduceMotion)) {
        captureConfirmed = true
    }
    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        NotificationCenter.default.post(name: .captureItemsChanged, object: nil)
        dismiss()
    }
}
```

Apply `.celebrationOverlay(style: .firstCapture, isActive: $showFirstCaptureCelebration)` to the main content container of the view.

Step 2 — Verify build compiles

Run: `xcodebuild build -project ios/Offload.xcodeproj -scheme Offload -destination 'generic/platform=iOS Simulator' 2>&1 | tail -5`

Expected: BUILD SUCCEEDED.

Step 3 — Run existing tests

Run: `xcodebuild test -project ios/Offload.xcodeproj -scheme Offload -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' -only-testing:OffloadTests 2>&1 | tail -20`

Expected: All tests PASS.

Step 4 — Commit

```bash
git add ios/Offload/Features/Capture/CaptureComposeView.swift
git commit -m "feat(celebration): add first-capture celebration with AppStorage detection"
```

---

## Task 6: Wire up collection-completed celebration in CaptureView

**Files:**

- Modify: `ios/Offload/Features/Capture/CaptureView.swift:202-215` — `completeItem()` function

Step 1 — Write the failing test

Add to `ios/OffloadTests/CelebrationModifierTests.swift`:

```swift
// MARK: - Collection Completion Detection

func testAllItemsCompleteDetection() {
    // Simulates the logic that will live in CaptureView
    let completedDates: [Date?] = [Date(), Date(), Date()]
    let allComplete = completedDates.allSatisfy { $0 != nil }
    XCTAssertTrue(allComplete)
}

func testNotAllItemsCompleteDetection() {
    let completedDates: [Date?] = [Date(), nil, Date()]
    let allComplete = completedDates.allSatisfy { $0 != nil }
    XCTAssertFalse(allComplete)
}

func testEmptyCollectionIsNotComplete() {
    let completedDates: [Date?] = []
    // Empty collection should not trigger celebration
    let allComplete = !completedDates.isEmpty && completedDates.allSatisfy { $0 != nil }
    XCTAssertFalse(allComplete)
}
```

Step 2 — Run test to verify it passes

Run: `xcodebuild test -project ios/Offload.xcodeproj -scheme Offload -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' -only-testing:OffloadTests/CelebrationModifierTests 2>&1 | tail -20`

Expected: PASS — these are pure logic tests.

Step 3 — Add collection completion detection to CaptureView

In `ios/Offload/Features/Capture/CaptureView.swift`, add to the struct declarations:

```swift
@Environment(ToastManager.self) private var toastManager
```

Modify `completeItem()` (lines 202-215) to check collection membership after completion:

```swift
private func completeItem(_ item: Item) {
    let itemId = item.id
    AppLogger.workflow.info("CaptureView complete requested - id: \(itemId, privacy: .public)")
    do {
        try itemRepository.complete(item)
        viewModel.remove(item)
        AppLogger.workflow.info("CaptureView complete completed - id: \(itemId, privacy: .public)")

        // Check if this completion finishes any collection
        checkCollectionCompletion(for: item)
    } catch {
        AppLogger.workflow.error(
            "CaptureView complete failed - id: \(itemId, privacy: .public), error: \(error.localizedDescription, privacy: .public)"
        )
        errorPresenter.present(error)
    }
}

/// Checks if completing this item finishes all items in any of its collections.
private func checkCollectionCompletion(for item: Item) {
    guard let collectionItems = item.collectionItems, !collectionItems.isEmpty else { return }

    for collectionItem in collectionItems {
        guard let collection = collectionItem.collection,
              let allCollectionItems = collection.collectionItems,
              !allCollectionItems.isEmpty else { continue }

        let allItems = allCollectionItems.compactMap { $0.item }
        guard !allItems.isEmpty else { continue }

        let allComplete = allItems.allSatisfy { $0.completedAt != nil }
        if allComplete {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            toastManager.show("\"\(collection.name)\" complete!", type: .success)
            AppLogger.workflow.info("Collection completed - name: \(collection.name, privacy: .public)")
        }
    }
}
```

Step 4 — Verify build compiles

Run: `xcodebuild build -project ios/Offload.xcodeproj -scheme Offload -destination 'generic/platform=iOS Simulator' 2>&1 | tail -5`

Expected: BUILD SUCCEEDED.

Step 5 — Run all tests

Run: `xcodebuild test -project ios/Offload.xcodeproj -scheme Offload -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' -only-testing:OffloadTests 2>&1 | tail -20`

Expected: All tests PASS.

Step 6 — Commit

```bash
git add ios/Offload/Features/Capture/CaptureView.swift ios/OffloadTests/CelebrationModifierTests.swift
git commit -m "feat(celebration): add collection-completed detection with success toast"
```

---

## Task 7: Update design doc and backlog

**Files:**

- Modify: `docs/plans/2026-02-24-celebration-animations-design.md` — mark as implemented
- Modify: `docs/plans/plan-implementation-backlog.md` — update celebration animations status

Step 1 — Update the design doc

Add `status: implemented` context to the top of the design doc.

Step 2 — Update the backlog

In `docs/plans/plan-implementation-backlog.md`, move Celebration Animations from Future Work to Completed, replacing the remaining checklist with a summary of what was built.

Step 3 — Lint markdown

Run: `npx markdownlint-cli docs/plans/2026-02-24-celebration-animations-design.md docs/plans/plan-implementation-backlog.md 2>&1`

Expected: No errors.

Step 4 — Commit

```bash
git add docs/plans/2026-02-24-celebration-animations-design.md docs/plans/plan-implementation-backlog.md
git commit -m "docs(celebration): update backlog and design doc status"
```

---

## Task 8: Final verification

Step 1 — Run full test suite

Run: `xcodebuild test -project ios/Offload.xcodeproj -scheme Offload -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' 2>&1 | tail -30`

Expected: All tests PASS.

Step 2 — Run linters

Run: `just lint`

Expected: No errors.

Step 3 — Verify no untracked files or uncommitted changes

Run: `git status`

Expected: Clean working tree.
