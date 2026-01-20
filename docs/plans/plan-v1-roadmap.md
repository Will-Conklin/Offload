---
id: plan-v1-roadmap
type: plan
status: active
owners:
  - Offload
applies_to:
  - v1-release
last_updated: 2026-01-19
related: []
priority: critical
structure_notes:
  - "Single source of truth for v1 release planning"
  - "Supersedes plan-archived-master-plan.md"
---

# Offload v1 Roadmap

## Executive Summary

This document is the **single source of truth** for v1 release planning. It
supersedes the original master plan (now archived) which became out of date
after the January 13, 2026 UI overhaul.

**Last verified:** January 19, 2026

## Current Implementation Status

### ✅ COMPLETED

#### UI/UX Foundation

- Flat design system implemented (Elijah theme - lavender/cream palette)
- Bold borders instead of shadows
- Simplified spacing tokens (4, 8, 16, 24, 32, 48)
- Floating tab bar with center capture button
- Swipe actions for captures
- Inline tagging

#### Data Model Consolidation

- 4 core models: Item, Collection, CollectionItem, Tag
- Items with `type=nil` serve as captures
- Collections with `isStructured` distinguish plans vs lists
- Star system replaces priority system
- `completedAt` timestamp for lifecycle tracking

#### Repository Pattern (Jan 19, 2026)

- ✅ RepositoryEnvironment.swift with environment keys for all 4 repositories
- ✅ RepositoryBundle factory pattern for dependency injection
- ✅ AppRootView injects repositories into environment
- ✅ All views use `@Environment(\.itemRepository)` instead of modelContext
- ✅ Preview helpers for SwiftUI previews
- ✅ Comprehensive ItemRepositoryTests (45 tests)

### ⏳ IN PROGRESS

#### Error Handling (4 instances remaining)

Only 4 `try?` instances remain (down from 21):

- CollectionItem.swift:49 - children fetch fallback
- Item.swift:72,80 - JSON serialization for metadata
- TagRepository.swift:108 - items fetch fallback

**Assessment:** These are intentional fallbacks, not suppressions. The error
handling work is effectively complete.

### ⏸️ DEFERRED TO v1.1+

- Pagination (would require ViewModels)
- Tag relationship refactor (migration risk)
- View decomposition (CollectionDetailView at 778 lines)
- Visual timeline (ADHD feature)
- Celebration animations
- Advanced accessibility features

## Architecture Patterns (Current State)

- ✅ Repository environment injection: IMPLEMENTED
- ✅ ErrorPresenter: Available (minimal remaining try?)
- ❌ ViewModels: Not implemented (using @Query directly)
- ✅ SwiftData @Query: Used throughout for reactive data
- ✅ Repository mutations: All data changes go through repositories

## Remaining Work for v1

### Week 1: Testing & Polish

- Manual testing of all features
- Performance benchmarks
- Bug fixes from testing
- Accessibility review

### Week 2: Release Prep

- Documentation updates
- Release notes
- App Store metadata
- TestFlight distribution

**Total:** ~2 weeks to v1 (repository and error handling work complete)

## File Sizes Reference

- CollectionDetailView.swift: 778 lines (candidate for future decomposition)
- CaptureView.swift: ~450 lines
- CaptureComposeView.swift: 393 lines
- OrganizeView.swift: 328 lines
- SettingsView.swift: 208 lines

## Historical Context

### January 13, 2026 - UI Overhaul (PR #84)

- Implemented flat design with Elijah theme
- Removed CaptureEntry, consolidated data model
- Added floating tab bar with center capture button
- ~3000+ lines changed across 50+ files

### January 19, 2026 - Repository Pattern Complete

- Implemented RepositoryEnvironment.swift
- Updated all views to use repository injection
- Removed direct modelContext usage from views
- Fixed Swift concurrency errors

## Decision Log

| Decision     | Choice                                 | Date   |
| ------------ | -------------------------------------- | ------ |
| UI Direction | Flat design (not glassmorphism)        | Jan 13 |
| Theme        | Single "Elijah" theme                  | Jan 13 |
| v1 Scope     | Manual app only (no AI)                | Jan 19 |
| Pagination   | Defer to v1.1+                         | Jan 19 |
| ViewModels   | Not needed for v1 (@Query sufficient)  | Jan 19 |
