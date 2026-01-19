---
id: adr-readme
type: architecture-decision
status: active
owners:
  - offload
applies_to:
  - architecture
last_updated: 2026-01-17
related:
  - adr-0001-technology-stack-and-architecture
  - adr-0002-terminology-alignment-for-capture-and-organization
  - adr-0003-adhd-focused-ux-ui-guardrails
structure_notes:
  - "Section order: Purpose; Authority; What belongs here; What does not belong here; Canonical documents; Naming."
  - "Keep top-level sections: Purpose; Authority; What belongs here; What does not belong here; Canonical documents; Naming."
---


# ADR

## Purpose

Record architecture and product decisions, including rationale and consequences.

## Authority

Second only to reference. ADRs define decisions and constraints; they must align with reference and cannot define requirements, scope, or implementation plans.

## What belongs here

- Decisions with context, decision statement, and consequences.
- Alternatives considered and trade-offs.
- Status updates (Accepted, Superseded, Deprecated) with links.

## What does not belong here

- Product requirements or scope (use prd/).
- Implementation details or technical design (use design/).
- Execution plans, milestones, or schedules (use plans/).
- Exploratory research or raw notes (use research/).

## Canonical documents

- [adr-0001: Technology Stack and Architecture](./adr-0001-technology-stack-and-architecture.md)
- [adr-0002: Terminology Alignment for Capture and Organization](./adr-0002-terminology-alignment-for-capture-and-organization.md)
- [adr-0003: ADHD-Focused UX/UI Guardrails](./adr-0003-adhd-focused-ux-ui-guardrails.md)

## Naming

- Use `adr-0007-feature-store-backfill.md` format with the next sequential number.
- Keep titles in the file aligned with the ADR table of contents.
