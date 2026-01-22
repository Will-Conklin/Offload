---
id: plan-bottom-tab-bar-offload-cta
type: plan
status: draft
owners:
  - Offload
applies_to:
  - Offload
last_updated: 2026-01-22
related:
  - prd-0001-product-requirements
structure_notes:
  - "Section order: Overview; Goals; Phases; Dependencies; Risks; Progress."
---

# Plan: Persistent Bottom Tab Bar & Offload CTA (Proposed)

## Overview

Proposed plan to replace the current bottom navigation with a persistent
edge-anchored tab bar featuring five icons (Home, Review, Offload, Organize,
Account) and a center-weighted Offload primary action that expands to write and
voice options. The plan focuses on sequencing updates to navigation, visuals,
and action handling without altering approved scope.

## Goals

- Introduce a five-icon persistent tab bar anchored to the screen edge.
- Add a central Offload CTA that visually breaks the bar and exposes write/voice
  actions.
- Route Home to a placeholder view while preserving existing Review, Organize,
  and Account functionality.

## Phases

### Phase 1: Navigation Mapping

**Status:** Not Started

- [ ] Audit current tab navigation and destinations.
- [ ] Define mapping for Home placeholder, Review (Capture), Offload action,
  Organize, Account.
- [ ] Confirm Account replaces the current icon next to settings.

### Phase 2: Visual Design & Layout

**Status:** Not Started

- [ ] Add a persistent tab bar component anchored to screen edge.
- [ ] Implement five icons with selected/unselected states.
- [ ] Design Offload CTA to break the bar visually and remain centered.

### Phase 3: Offload CTA Expansion

**Status:** Not Started

- [ ] Implement Offload tap to reveal floating write and microphone actions.
- [ ] Connect actions to existing write and voice flows.
- [ ] Add dismiss behavior and accessibility labels.

### Phase 4: Home Placeholder & Account Placement

**Status:** Not Started

- [ ] Add placeholder Home view entry point.
- [ ] Move Account access to the new tab.
- [ ] Validate settings still reachable from Account.

### Phase 5: QA & UX Validation

**Status:** Not Started

- [ ] Verify tab persistence across navigation stacks.
- [ ] Validate Offload CTA transitions and accessibility focus.
- [ ] Update manual QA checklist for new navigation.

## Dependencies

- Updated icon assets for Home, Review, Offload, Organize, Account.
- Alignment on Home placeholder content.
- Existing write/voice action handlers.

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Tab bar layout conflicts with safe areas | M | Test on iPhone/iPad sizes and adjust padding. |
| Offload CTA obscures content | M | Use animation and z-index control; verify scroll behaviors. |
| Navigation regression | H | Add regression QA around tab switching and deep links. |

## Progress

| Date | Update |
| --- | --- |
| 2026-01-22 | Drafted proposed plan for review. |
