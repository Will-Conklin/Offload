---
id: prd-readme
type: product-requirements
status: active
owners:
  - Offload
applies_to:
  - product
last_updated: 2026-01-17
related:
  - prd-0001-product-requirements
structure_notes:
  - "Section order: Purpose; Authority; What belongs here; What does not belong here; Canonical documents; Naming."
  - "Keep top-level sections: Purpose; Authority; What belongs here; What does not belong here; Canonical documents; Naming."
---


# PRD

## Purpose

Define product requirements, scope, goals, and success metrics for Offload.

## Authority

Below reference and adrs. PRDs define WHAT the product must do; they cannot introduce architecture decisions or implementation details, and must align with reference and ADRs.

## What belongs here

- Product goals, non-goals, and scope constraints.
- User flows, success metrics, and acceptance criteria.
- Pricing, limits, and roll-out requirements.

## What does not belong here

- Architecture or product decisions (use adrs/).
- Implementation details or technical designs (use design/).
- Execution timelines or task breakdowns (use plans/).
- Exploratory research or experiments (use research/).

## Canonical documents

- [Offload V1 PRD](./prd-0001-product-requirements.md)

## Naming

- Use `prd-0001-feature-name.md` format with the next sequential number.
- Keep filenames stable once published; use revision history inside the document.
