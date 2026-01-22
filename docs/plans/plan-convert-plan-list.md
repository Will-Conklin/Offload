---
id: plan-convert-plan-list
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

# Plan: Convert Plans ↔ Lists (Proposed)

## Overview

Proposed plan to add a long-press action on plans and lists that converts the
collection type between structured plan and list, with a warning when converting
from plan to list because structure will be lost. The plan focuses on UX flow,
repository updates, and validation.

## Goals

- Provide a long-press action to convert a plan to a list and a list to a plan.
- Surface a clear warning when converting a plan to a list.
- Preserve existing items while updating collection metadata.

## Phases

### Phase 1: UX & Interaction Design

**Status:** Not Started

- [ ] Define long-press menu content for plans and lists.
- [ ] Specify warning copy and confirmation flow for plan → list.
- [ ] Identify entry points (Organize list rows, detail views).

### Phase 2: Data & Repository Updates

**Status:** Not Started

- [ ] Add repository method to toggle `Collection.isStructured`.
- [ ] Define behavior for plan → list conversion (flatten structure).
- [ ] Confirm list → plan conversion retains ordering and metadata.

### Phase 3: View Integration

**Status:** Not Started

- [ ] Add long-press menu action in list rows.
- [ ] Wire confirmation alert for destructive conversion.
- [ ] Refresh views after conversion completes.

### Phase 4: QA & Edge Cases

**Status:** Not Started

- [ ] Verify conversion handles empty collections.
- [ ] Confirm warning appears for plan → list only.
- [ ] Ensure undo/redo or cancellation states are respected.

## Dependencies

- Existing collection repository and persistence layer.
- Copy for warning message.

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Users lose nested structure without noticing | H | Require explicit confirmation with warning copy. |
| Conversion affects ordering | M | Preserve `CollectionItem.position` values and validate output. |
| UI state desync after conversion | M | Trigger refreshes and add QA coverage. |

## Progress

| Date | Update |
| --- | --- |
| 2026-01-22 | Drafted proposed plan for review. |
