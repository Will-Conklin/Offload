---
id: plans-readme
type: plan
status: active
owners:
  - offload
applies_to:
  - offload
last_updated: 2026-01-17
related:
  - plan-master-plan
  - plan-view-decomposition
  - plan-pagination-implementation
  - plan-repository-pattern-consistency
  - plan-tag-relationship-refactor
  - plan-error-handling-improvements
structure_notes:
  - "Section order: Purpose; Authority; What belongs here; What does not belong here; Canonical documents; Naming."
  - "Keep top-level sections: Purpose; Authority; What belongs here; What does not belong here; Canonical documents; Naming."
---


# Plans

## Purpose

Define sequencing, milestones, and execution strategy for approved scope.

## Authority

Below design. Plans describe WHEN and HOW work is executed; they cannot introduce requirements, decisions, or architecture changes.

## What belongs here

- Milestones, work breakdowns, and sequencing.
- Dependencies, risks, and execution notes tied to approved scope.
- Progress tracking and rollout checklists.

## What does not belong here

- New requirements or scope (use prd/).
- Architecture or product decisions (use adr/).
- Technical designs or implementation details (use design/).
- Research notes or experiments (use research/).

## Canonical documents

- [Offload Master Implementation Plan](./plan-master-plan.md)
- [View Decomposition Plan](./plan-view-decomposition.md)
- [Pagination Implementation Plan](./plan-pagination-implementation.md)
- [Repository Pattern Consistency Plan](./plan-repository-pattern-consistency.md)
- [Tag Relationship Refactor Plan](./plan-tag-relationship-refactor.md)
- [Error Handling Improvements Plan](./plan-error-handling-improvements.md)

## Naming

- Use kebab-case with a concise feature or outcome, for example `plan-error-handling-improvements.md`.
- Move completed or superseded plans to `plans/_archived/` without renaming.
