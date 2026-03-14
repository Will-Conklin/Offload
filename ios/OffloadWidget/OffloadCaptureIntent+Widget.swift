// Purpose: Capture intent definition for the widget target.
// Authority: Code-level
// Governed by: CLAUDE.md
// Additional instructions: Duplicated in the widget target because App Intents must be
// compiled into every target that references them. Keep in sync with OffloadCaptureIntent.swift.

import AppIntents
import Foundation

/// Widget-local copy of the Offload capture intent.
/// Enqueues a capture to PendingCaptureStore; the main app flushes it on foreground.
@available(iOS 16.0, *)
struct WidgetOffloadCaptureIntent: AppIntent {
    static var title: LocalizedStringResource = "Capture a Thought"
    static var description = IntentDescription("Quickly capture a thought into Offload.")

    @Parameter(title: "Thought", description: "What's on your mind?")
    var content: String

    static var parameterSummary: some ParameterSummary {
        Summary("Offload \(\.$content)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw WidgetIntentError.emptyContent
        }
        PendingCaptureStore.enqueue(PendingCapture(content: trimmed))
        return .result(dialog: "Captured.")
    }
}

@available(iOS 16.0, *)
enum WidgetIntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case emptyContent
    var localizedStringResource: LocalizedStringResource { "Please enter something to capture." }
}
