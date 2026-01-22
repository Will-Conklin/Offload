---
id: plan-search-items-tags
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

# Plan: Search Items by Text or Tag (Proposed)

## Overview

Proposed plan to add a magnifying glass icon near settings that opens a floating
search bar. Search should match item text and tags, and show matched tags as
selectable chips that scope results to tag-only searches. This plan outlines the
sequencing for UX, search logic, and UI integration.

## Goals

- Add a search icon next to settings with a floating search bar.
- Enable search across item text and tags.
- Allow tag matches to appear as selectable chips to scope search to tags.

## Phases

### Phase 1: UX Definition

**Status:** Not Started

- [ ] Define floating search bar layout (roughly 2/3 width, anchored near icon).
- [ ] Specify tag-chip behavior and selection states.
- [ ] Define empty, no-results, and partial match states.

### Phase 2: Search Logic

**Status:** Not Started

- [ ] Add query logic for item text search.
- [ ] Add tag match detection and tag-scoped search.
- [ ] Define ranking rules between text matches and tag matches.

### Phase 3: UI Integration

**Status:** Not Started

- [ ] Add search icon to the settings area.
- [ ] Implement floating search bar entry/exit transitions.
- [ ] Render tag chips and connect selection filtering.

### Phase 4: QA & Accessibility

**Status:** Not Started

- [ ] Validate search against items with multiple tags.
- [ ] Confirm keyboard focus and dismissal behavior.
- [ ] Ensure voiceover labels for search icon and chips.

## Dependencies

- Tag repository access for matching and filtering.
- UI components for chip rendering.

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Search UX clashes with existing header layout | M | Prototype spacing and test on small screens. |
| Tag matching leads to ambiguous results | M | Provide clear scoping UI and highlight matches. |
| Search performance degrades with large datasets | M | Use efficient queries and debounce input. |

## Progress

| Date | Update |
| --- | --- |
| 2026-01-22 | Drafted proposed plan for review. |
