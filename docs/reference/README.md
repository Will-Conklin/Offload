---
id: reference-readme
type: reference
status: active
owners:
  - offload
applies_to:
  - offload
last_updated: 2026-01-17
related:
  - reference-test-runtime-baselines
structure_notes:
  - "Section order: Purpose; Authority; What belongs here; What does not belong here; Canonical documents; Naming."
  - "Keep top-level sections: Purpose; Authority; What belongs here; What does not belong here; Canonical documents; Naming."
---


# Reference

## Purpose

Provide authoritative contracts, schemas, terminology, and invariants.

## Authority

Highest authority. Reference docs define source-of-truth facts and must avoid rationale, narrative, or implementation details.

## What belongs here

- Glossaries, schemas, data definitions, and invariants.
- Authoritative baselines or thresholds.

## What does not belong here

- Decision rationale (use adr/).
- Product requirements or scope (use prd/).
- Technical design or implementation guidance (use design/).
- Plans or schedules (use plans/).

## Canonical documents

- [Test Runtime Baselines](./testing/reference-test-runtime-baselines.md)

## Naming

- Use stable, descriptive nouns for filenames.
- Avoid dates unless the document is inherently time-bound.
