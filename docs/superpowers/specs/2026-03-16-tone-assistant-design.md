# Tone Assistant — Design Spec

**Date:** 2026-03-16
**Status:** Approved
**Feature:** AI Organization Flow — Feature 4

---

## Overview

Tone Assistant transforms a capture into a differently-worded version using one of six tones. The user picks a tone, sees the result, then either copies it to the clipboard or saves it as a new capture alongside the original. No presets in v1.

---

## Scope

### In scope

- 6 tones: formal, friendly, concise, empathetic, direct, neutral
- Pick one tone → generate → view result
- Result actions: copy to clipboard, or save as a new capture (original untouched)
- Cloud path via `POST /v1/ai/tone/transform` (opt-in, consistent with other AI features)
- On-device fallback (basic heuristics, clearly labeled)
- Entry point: `CaptureItemCard` context menu + accessibility action
- Unit tests for service layer, ViewModel, and backend endpoint

### Out of scope (deferred)

- Named presets
- Multiple simultaneous tone previews
- Applying tone in-place (overwriting the original)

---

## Architecture

### New files

| File | Purpose |
| --- | --- |
| `ios/Offload/Data/Services/ToneAssistantService.swift` | `ToneAssistantService` protocol, `DefaultToneAssistantService`, `SimpleOnDeviceToneTransformer`, `ToneStyle` enum |
| `ios/Offload/Features/Capture/ToneAssistantSheet.swift` | `ToneAssistantSheetViewModel` + `ToneAssistantSheet` view |
| `backend/api/src/offload_backend/routers/tone.py` | `POST /v1/ai/tone/transform` FastAPI router |
| `ios/OffloadTests/ToneAssistantServiceTests.swift` | Unit tests for service layer |
| `ios/OffloadTests/ToneAssistantSheetViewModelTests.swift` | Unit tests for ViewModel phase transitions |
| `backend/api/tests/test_tone.py` | Backend endpoint tests |

### Modified files

| File | Change |
| --- | --- |
| `ios/Offload/Data/Networking/AIBackendContracts.swift` | Add `ToneTransformRequest`, `ToneTransformResponse`, `transformTone()` protocol method |
| `ios/Offload/Data/Networking/AIBackendClient.swift` | Implement `transformTone()` |
| `ios/Offload/Features/Capture/CaptureItemCard.swift` | Add "Rewrite Tone" context menu action + accessibility action |
| `ios/Offload/Features/Capture/CaptureView.swift` | Add `@State var toneItem: Item?` + `.sheet(item: $toneItem)` |
| `backend/api/src/offload_backend/schemas.py` | Add `ToneTransformRequest`, `ToneTransformResponse` Pydantic models |
| `backend/api/src/offload_backend/main.py` | Register tone router at `/v1/ai/tone` |

---

## Data Model

### `ToneStyle` (Swift enum)

```swift
enum ToneStyle: String, CaseIterable, Identifiable {
    case formal, friendly, concise, empathetic, direct, neutral

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
    var icon: String { /* SF Symbol per tone */ }
    var description: String { /* one-line description */ }
}
```

### `ToneTransformResult`

```swift
struct ToneTransformResult {
    let text: String
    let source: ToneExecutionSource  // .onDevice | .cloud
    let usage: ToneUsage?
}
```

### API contract

```
POST /v1/ai/tone/transform
Request:  { input_text: str, tone: str, context_hints: [str] }
Response: { transformed_text: str, usage: { input_tokens: int, output_tokens: int } }
```

`tone` is a plain string (not an enum) for forward compatibility.

---

## Service Layer

### Protocol

```swift
protocol ToneAssistantService {
    func transformTone(inputText: String, tone: ToneStyle) async throws -> ToneTransformResult
    func reconcileUsage(feature: String) async throws -> UsageReconcileResponse?
}
```

### Cloud path

`DefaultToneAssistantService.transformTone()`:
1. Increments `usageStore` counter for `"tone"`
2. If `consentStore.isCloudAIEnabled`: calls backend, returns `.cloud` result
3. On `AIBackendClientError.shouldFallbackToOnDevice`: falls back to on-device
4. Other errors propagate to the ViewModel

### On-device fallback (`SimpleOnDeviceToneTransformer`)

| Tone | Heuristic |
| --- | --- |
| `formal` | Capitalize first letter, add period, expand contractions (can't→cannot, won't→will not) |
| `concise` | Return first sentence only (split on `.`, `!`, `?`) |
| `friendly` | Append " Hope that helps!" |
| `empathetic` | Prepend "I understand — " |
| `direct` | Strip filler words (just, maybe, perhaps, a bit) |
| `neutral` | Return text unchanged |

Quality is intentionally limited and the source label (`.onDevice`) is surfaced in the UI to nudge cloud opt-in.

---

## Sheet UI

### `ToneAssistantSheetViewModel`

```swift
@Observable @MainActor
final class ToneAssistantSheetViewModel {
    enum Phase { case selectTone, generating, result }

    var phase: Phase = .selectTone
    var selectedTone: ToneStyle?
    var result: ToneTransformResult?
    var isGenerating: Bool = false

    func generate(inputText: String, tone: ToneStyle, using service: ToneAssistantService) async throws
    func reset()  // back to selectTone, clears result
}
```

### `ToneAssistantSheet` phases

**Phase 1 — Select Tone:**
- Header: "Tone Assistant" + subtitle
- Original capture shown in a muted card
- 2-column grid of 6 tone tiles (icon + name + one-line description)
- Tapping a tile transitions to `.generating`

**Phase 2 — Generating:**
- Same header + original card
- Selected tone tile highlighted
- `ProgressView` with "Rewriting…" label

**Phase 3 — Result:**
- Original capture in a muted card
- Result in an accent-bordered card with tone label + source badge (cloud/on-device)
- Two action buttons: **Copy** (primary, accent fill) and **Save** (secondary, outlined)
- "Try another tone" link → calls `viewModel.reset()`

### Actions

- **Copy**: writes `result.text` to `UIPasteboard.general.string`, triggers light haptic, dismisses sheet
- **Save**: calls `itemRepository.create(type: nil, content: result.text, ...)`, triggers light haptic, posts `.captureItemsChanged`, dismisses sheet

---

## Entry Point

`CaptureItemCard` context menu — "Rewrite Tone" action (icon: `wand.and.stars`), same placement as "Break Down", "Brain Dump", "Reduce Decision Fatigue". Accessibility action added with the same label.

`CaptureView` adds:
```swift
@State private var toneItem: Item?
```
and a `.sheet(item: $toneItem)` presenting `ToneAssistantSheet`.

---

## Backend Router (`tone.py`)

```python
POST /v1/ai/tone/transform
- Validates tone string against allowed set
- Constructs system prompt: "Rewrite the following text in a {tone} tone. Return only the rewritten text."
- Calls provider (OpenAI or Anthropic) via existing adapter pattern
- Returns { transformed_text, usage }
```

Follows `decide.py` structure: session token auth, provider selection from `request.app.state`, error handling via existing `errors.py`.

---

## Testing

### iOS unit tests

**`ToneAssistantServiceTests`:**
- Each of 6 tones produces non-empty output via `SimpleOnDeviceToneTransformer`
- `formal` tone expands "can't" → "cannot"
- `concise` tone returns only first sentence
- Cloud path calls backend client with correct tone string
- Network error triggers on-device fallback
- Usage counter incremented on each call

**`ToneAssistantSheetViewModelTests`:**
- Phase transitions: `.selectTone` → `.generating` → `.result` on success
- Error in generate sets error state, stays on `.selectTone`
- `reset()` clears result and returns to `.selectTone`

### Backend tests (`test_tone.py`)

- Valid tone returns 200 with `transformed_text`
- Invalid tone string returns 422
- Provider error returns 502
- Prompt includes tone name and input text

---

## Invariants (from backlog)

- Cloud requires explicit opt-in via `consentStore.isCloudAIEnabled`; fails closed if absent
- Zero content retention (no durable storage of prompts/responses on backend)
- AI suggests, never auto-acts; result is always reviewed before copy/save
- Feature is optional and dismissible
