---
id: design-readme
type: design
status: active
owners:
  - offload
applies_to:
  - offload
last_updated: 2026-01-17
related:
  - design-voice-capture-testing-guide
  - design-voice-capture-test-results
structure_notes:
  - "Section order: Purpose; Authority; What belongs here; What does not belong here; Canonical documents; Naming."
  - "Keep top-level sections: Purpose; Authority; What belongs here; What does not belong here; Canonical documents; Naming."
---


# Design

## Purpose

Document technical design and implementation guidance for approved requirements.

## Authority

Below prd. Design defines HOW approved requirements are implemented; it cannot set requirements or decisions and must align with reference and ADRs.

## What belongs here

- Implementation approach, data flow descriptions, and UI behavior specs.
- Testing guides and validation steps tied to features.
- Technical constraints derived from ADRs or PRDs.

## What does not belong here

- Product requirements or scope (use prd/).
- Architecture or product decisions (use adr/).
- Execution timelines or milestones (use plans/).
- Exploratory research (use research/).

## Canonical documents

- [Voice Capture Testing Guide](./testing/design-voice-capture-testing-guide.md)
- [Voice Capture Test Results](./testing/design-voice-capture-test-results.md)

## Naming

- Use kebab-case with a clear feature or system name.
- Group specialized areas under subfolders like `testing/`.
