---
id: plan-drag-drop-collection-items
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

# Plan: Drag & Drop Ordering and Hierarchy (Proposed)

## Overview

Proposed plan to enable drag-and-drop ordering for items in lists and plans.
Plans should also support dragging an item onto another to make it a child, with
indented display and collapsible parent behavior. The plan sequences UX work,
model updates, and interaction handling.

## Goals

- Allow drag-and-drop reordering of items in lists and plans.
- Support plan-only nesting by dragging an item onto another item.
- Provide visual indentation and collapsible child groups.

## Phases

### Phase 1: Interaction & UX Definition

**Status:** Not Started

- [ ] Define drag affordances for list rows and plan rows.
- [ ] Specify drop targets for reordering and parent assignment.
- [ ] Define collapse/expand UI for parent items.

### Phase 2: Data Updates & Ordering Logic

**Status:** Not Started

- [ ] Update ordering logic to persist drag results via `CollectionItem.position`.
- [ ] Define behavior for setting `CollectionItem.parentId` on drop-to-parent.
- [ ] Ensure flattening logic for list collections remains unchanged.

### Phase 3: UI Implementation

**Status:** Not Started

- [ ] Implement drag-and-drop in list views.
- [ ] Implement drag-to-parent for plan views with indentation.
- [ ] Add collapse/expand state handling.

### Phase 4: QA & Edge Cases

**Status:** Not Started

- [ ] Validate reordering across pagination boundaries (if applicable).
- [ ] Confirm drag-to-parent does not allow circular nesting.
- [ ] Verify collapsed state persistence rules.

## Dependencies

- Collection item ordering and hierarchy support in repositories.
- UI components for nested list rendering.

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Drag interactions conflict with scroll | M | Tune drag handles and gesture priority. |
| Accidental nesting causes confusion | M | Provide visual feedback and allow easy undo. |
| Hierarchy complexity affects performance | M | Optimize updates and minimize re-renders. |

## Progress

| Date | Update |
| --- | --- |
| 2026-01-22 | Drafted proposed plan for review. |
