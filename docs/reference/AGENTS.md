---
id: reference-agents
type: reference
status: active
owners:
  - Offload
applies_to:
  - agents
  - reference
last_updated: 2026-01-25
related:
  - docs-agents
structure_notes:
  - "Section order: Scope; Purpose; Contains; When to create; Lifecycle; Format expectations; Boundaries."
---
# Reference Agent Guide

This file provides agent-only instructions for documentation in `docs/reference/`.
README files are informational for users.

## Scope

- Applies to `docs/reference/**`
- Defers to `docs/AGENTS.md` for global documentation rules

## Purpose

Define contracts, schemas, APIs, terminology, and invariants that code must follow.

## Contains

- API contracts and endpoint definitions
- Data schemas and model specifications
- Type definitions and interfaces
- Terminology glossaries
- System invariants and constraints
- Configuration contracts

## When to create

- During implementation when contracts are finalized
- After API endpoints are stabilized
- When schemas/models are established
- As terminology becomes standardized

## Lifecycle

- Created during or after implementation at appropriate points
- Status: draft -> active -> deprecated
- Updated when contracts change (with versioning)
- Never deleted (deprecate and version instead)
- Must remain synchronized with actual implementation

## Format expectations

- No rationale or narrative (factual only)
- Machine-readable where possible (JSON Schema, OpenAPI, etc.)
- Clear versioning for breaking changes
- Examples of valid usage

## Boundaries

- Does not include "why" decisions were made (see ADRs)
- Does not include implementation details (see design docs)
- Does not include feature requirements (see PRDs)
