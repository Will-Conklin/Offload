# Plan: Integrate Brain Dump Event-Sourced Model

## Overview

Replace the current simple Task/Project/Tag/Category model with a more sophisticated
event-sourced "brain dump" model that explicitly tracks AI hand-off workflows, suggestions,
and user decisions. This model better aligns with the product vision of "capture first,
organize later with AI approval."

## Current State Analysis

### Existing Models (to be replaced/refactored)

- `Thought.swift` - Simple capture model
- `Task.swift` - Complex task with project/category/tags relationships
- `Project.swift` - Hierarchical project organization
- `Tag.swift` - Many-to-many tagging
- `Category.swift` - Single category per task
- `Item.swift` - Legacy placeholder

### Existing Infrastructure (to be preserved)

- `VoiceRecordingService` - Works with any text storage, no changes needed
- `PersistenceController` - Manages ModelContainer, needs schema update
- Repository pattern - Proven with TaskRepository/ProjectRepository (45+ tests)
- CaptureSheetView - Saves to modelContext, easy to update

## New Model Architecture

### Core Capture & Workflow Models

#### BrainDumpEntry (replaces Thought)

- Captures: rawText, inputType (text/voice), source (app/shortcut/shareSheet)
- Lifecycle: raw → handedOff → ready → placed → archived
- Tracks: acceptedSuggestionId (v1 constraint: one accepted suggestion)
- Relationships: handOffRequests (cascade delete)

#### HandOffRequest

- Tracks each time user requests AI organization
- Fields: requestedAt, requestedBy, mode (manual/auto)
- Relationships: brainDumpEntry (inverse), runs (cascade delete)

#### HandOffRun

- Captures each AI execution attempt
- Fields: startedAt, completedAt, modelId, promptVersion, inputSnapshot, runStatus,
  errorMessage
- Relationships: handOffRequest (inverse), suggestions (cascade delete)

#### Suggestion

- AI-generated organization suggestions
- Fields: kind (plan/task/list/communication/mixed), payloadJSON (versioned blob)
- Relationships: handOffRun (inverse), decisions (cascade delete)

#### SuggestionDecision

- User's response to each suggestion
- Fields: decision (accepted/notNow), decidedAt, decidedBy, undoOfDecisionId
- Relationships: suggestion (inverse)

#### Placement

- Tracks where accepted suggestions end up
- Fields: placedAt, targetType, targetId, sourceSuggestionId, notes
- No relationships (uses UUID references to targets)

### Simplified Destination Models

#### Plan (simplified from Project)

- Fields: title, detail, createdAt, isArchived
- Relationships: tasks (cascade delete)

#### Task (simplified but keeps organization features)

- Fields: title, detail, createdAt, isDone, importance (1-5), dueDate
- Relationships: plan (inverse), category (optional), tags (optional many-to-many)
- REMOVED: priority enum, status enum, blockedBy, sourceThought

#### Tag (kept for manual organization)

- Fields: name, color, createdAt
- Relationships: tasks (many-to-many inverse)

#### Category (kept for manual organization)

- Fields: name, icon, createdAt
- Relationships: tasks (one-to-many inverse)

#### ListEntity (new - replaces shopping/packing lists)

- Fields: title, kind (shopping/packing/reference), createdAt
- Relationships: items (cascade delete)

#### ListItem (new)

- Fields: text, isChecked
- Relationships: list (inverse)

#### CommunicationItem (new)

- Fields: channel (call/email/text), recipient, content, createdAt,
  status (draft/sent/deferred)
- No relationships

## Implementation Strategy

### Phase 1: Model Definition

1. Create new model files in `ios/Offload/Domain/Models/` using established patterns
2. Use rawValue enum storage pattern (proven in Thought.swift)
3. Apply @Relationship annotations with deleteRule (proven pattern)
4. All enums: String, Codable for SwiftData compatibility

### Phase 2: Persistence Configuration

1. Update `PersistenceController.shared` schema array with new models
2. Update `PersistenceController.preview` with sample brain dump data
3. Update `SwiftDataManager.createModelContainer()` schema
4. Remove old models from both schemas

### Phase 3: Repository Implementation

1. Create `BrainDumpRepository` (pattern: TaskRepository)
   - fetchInbox() - entries in 'raw' state
   - fetchHandedOff() - entries with hand-off requests
   - fetchByState() - generic state filter
   - create(), update(), archive()

2. Create `HandOffRepository`
   - createRequest() - initiate AI hand-off
   - createRun() - record AI execution
   - fetchByEntry() - get all requests for a brain dump

3. Create `SuggestionRepository`
   - createSuggestion() - save AI output
   - recordDecision() - user accepted/declined
   - fetchPendingForEntry() - undecided suggestions

4. Create `PlacementRepository`
   - create() - record where suggestion was placed
   - fetchBySource() - find placements from a suggestion

5. Create simplified repositories: `PlanRepository`, `TaskRepository` (new simplified version),
   `ListRepository`, `CommunicationRepository`, `TagRepository`, `CategoryRepository`

### Phase 4: Service Integration

1. Update `CaptureSheetView.saveThought()`:

   ```swift
   let entry = BrainDumpEntry(
       rawText: rawText,
       inputType: voiceService.transcribedText.isEmpty ? .text : .voice,
       source: .app,
       lifecycleState: .raw
   )
   ```

2. VoiceRecordingService: NO CHANGES (model-agnostic)

### Phase 5: Testing

1. Create `BrainDumpRepositoryTests` (pattern: TaskRepositoryTests)
   - Test lifecycle state transitions
   - Test relationships (entry → requests → runs → suggestions)
   - Test acceptedSuggestionId constraint

2. Create tests for all new repositories (45+ tests total)
3. Use in-memory ModelContainer pattern (proven in existing tests)

### Phase 6: Migration Path (UPDATED based on user decisions)

1. **Merge PR #2** - Week 2 work becomes part of main branch history
2. **Pull latest main** - Start from merged state
3. Create new branch: `feature/brain-dump-model` from main
4. Delete old test files: TaskRepositoryTests.swift, ProjectRepositoryTests.swift
5. Implement new models and repositories
6. Write new tests from scratch (50+ tests for new architecture)
7. Update documentation to reflect new architecture
8. Create PR #3 for brain dump model

## Critical Files to Modify

### Models (Create New)

- [BrainDumpEntry.swift](ios/Offload/Domain/Models/BrainDumpEntry.swift)
- [HandOffRequest.swift](ios/Offload/Domain/Models/HandOffRequest.swift)
- [HandOffRun.swift](ios/Offload/Domain/Models/HandOffRun.swift)
- [Suggestion.swift](ios/Offload/Domain/Models/Suggestion.swift)
- [SuggestionDecision.swift](ios/Offload/Domain/Models/SuggestionDecision.swift)
- [Placement.swift](ios/Offload/Domain/Models/Placement.swift)
- [Plan.swift](ios/Offload/Domain/Models/Plan.swift) (replace Project)
- [Task.swift](ios/Offload/Domain/Models/Task.swift) (replace existing)
- [ListEntity.swift](ios/Offload/Domain/Models/ListEntity.swift) (new)
- [ListItem.swift](ios/Offload/Domain/Models/ListItem.swift) (new)
- [CommunicationItem.swift](ios/Offload/Domain/Models/CommunicationItem.swift) (new)

### Models (Remove)

- [Thought.swift](ios/Offload/Domain/Models/Thought.swift) (replaced by BrainDumpEntry)
- [Project.swift](ios/Offload/Domain/Models/Project.swift) (replaced by Plan)
- [Item.swift](ios/Offload/Domain/Models/Item.swift) (legacy placeholder)

### Models (Keep, Simplify)

- [Tag.swift](ios/Offload/Domain/Models/Tag.swift) (remove Task relationship complexity)
- [Category.swift](ios/Offload/Domain/Models/Category.swift) (remove Task relationship
  complexity)

### Persistence

- [PersistenceController.swift](ios/Offload/Data/Persistence/PersistenceController.swift)
  (update schema)
- [SwiftDataManager.swift](ios/Offload/Data/Persistence/SwiftDataManager.swift)
  (update schema)

### Repositories (Create New)

- [BrainDumpRepository.swift](ios/Offload/Data/Repositories/BrainDumpRepository.swift)
- [HandOffRepository.swift](ios/Offload/Data/Repositories/HandOffRepository.swift)
- [SuggestionRepository.swift](ios/Offload/Data/Repositories/SuggestionRepository.swift)
- [PlacementRepository.swift](ios/Offload/Data/Repositories/PlacementRepository.swift)
- [PlanRepository.swift](ios/Offload/Data/Repositories/PlanRepository.swift)
- [TaskRepository.swift](ios/Offload/Data/Repositories/TaskRepository.swift)
  (replace with simplified version)
- [ListRepository.swift](ios/Offload/Data/Repositories/ListRepository.swift) (new)
- [CommunicationRepository.swift](ios/Offload/Data/Repositories/CommunicationRepository.swift)
  (new)
- [TagRepository.swift](ios/Offload/Data/Repositories/TagRepository.swift)
  (simplified from current)
- [CategoryRepository.swift](ios/Offload/Data/Repositories/CategoryRepository.swift)
  (simplified from current)

### Repositories (Remove)

- [ProjectRepository.swift](ios/Offload/Data/Repositories/ProjectRepository.swift)
  (replaced by PlanRepository)

### UI Integration

- [CaptureSheetView.swift](ios/Offload/Features/Capture/CaptureSheetView.swift)
  (update saveThought)
- [InboxView.swift](ios/Offload/Features/Inbox/InboxView.swift)
  (update to query BrainDumpEntry)

### Tests (Create)

- [BrainDumpRepositoryTests.swift](ios/OffloadTests/BrainDumpRepositoryTests.swift)
- [HandOffRepositoryTests.swift](ios/OffloadTests/HandOffRepositoryTests.swift)
- [SuggestionRepositoryTests.swift](ios/OffloadTests/SuggestionRepositoryTests.swift)
- [PlacementRepositoryTests.swift](ios/OffloadTests/PlacementRepositoryTests.swift)
- [PlanRepositoryTests.swift](ios/OffloadTests/PlanRepositoryTests.swift)
- [ListRepositoryTests.swift](ios/OffloadTests/ListRepositoryTests.swift)

### Tests (Remove - clean slate approach)

- [TaskRepositoryTests.swift](ios/OffloadTests/TaskRepositoryTests.swift)
  (will recreate from scratch)
- [ProjectRepositoryTests.swift](ios/OffloadTests/ProjectRepositoryTests.swift)
  (no longer needed, Plan is simpler)

## Risk Mitigation

1. **Data Loss**: Tag baseline before changes, keep PR #2 as reference
2. **Testing Confidence**: Reuse proven test patterns from Week 2 (45+ tests)
3. **Enum Issues**: Use proven rawValue pattern from Thought.swift
4. **Relationship Complexity**: Follow established @Relationship patterns with .nullify
5. **Voice Service Break**: No changes needed - service is model-agnostic

## Success Criteria

1. All 11 new models compile with proper @Model annotations
2. ModelContainer initializes with new schema
3. VoiceRecordingService still works (saves to BrainDumpEntry)
4. Repository tests pass (50+ tests total)
5. CaptureSheetView saves brain dumps successfully
6. InboxView displays brain dump entries

## User Decisions

1. **✅ Migration Timing**: Merge PR #2 first, then start fresh from main branch
2. **✅ Old Tests**: Delete old tests, write new ones (clean slate)
3. **✅ Tag/Category**: Keep tags and categories for manual organization
4. **✅ Placement Design**: Use UUID references (flexible, audit trail-friendly)
