# Tasks: Calendar Timer

**Input**: Design documents from `/specs/001-calendar-timer/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md
**Tests**: TDD 필수 (Constitution III: NON-NEGOTIABLE)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- Source: `TogglMac/` at repository root
- Tests: `TogglMacTests/`, `TogglMacUITests/`

---

## Phase 1: Setup

**Purpose**: Xcode 프로젝트 초기화 및 기본 구조 생성

- [x] T001 Create Xcode project "TogglMac" with macOS App template (SwiftUI, Swift, macOS 14+)
- [x] T002 Create directory structure per plan.md: App/, Models/, ViewModels/, Views/, Services/, Utilities/ under TogglMac/
- [x] T003 [P] Create Views subdirectories: MainWindow/, Calendar/, Entry/, Project/ under TogglMac/Views/
- [x] T004 [P] Configure SwiftData ModelContainer in TogglMac/App/TogglMacApp.swift with TimeEntry, Project, TimerState models
- [x] T005 [P] Create TogglMac/Utilities/Constants.swift with app-wide constants (hotkey codes, default values)
- [x] T006 [P] Create TogglMac/Utilities/DateHelpers.swift with date calculation utilities (dayStart, dayEnd, weekStart, weekEnd using Monday start)

**Checkpoint**: Project builds and runs with empty SwiftUI window

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 모든 User Story에서 사용하는 핵심 모델과 서비스

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Tests (TDD - Write First, Must Fail)

- [x] T007 [P] Write unit tests for TimeEntry model in TogglMacTests/Models/TimeEntryTests.swift — test creation, validation (startTime < endTime), duration computation, default taskDescription
- [x] T008 [P] Write unit tests for Project model in TogglMacTests/Models/ProjectTests.swift — test creation, name/colorHex validation, relationship to TimeEntry
- [x] T009 [P] Write unit tests for TimerState model in TogglMacTests/Models/TimerStateTests.swift — test creation, singleton constraint, conversion to TimeEntry
- [x] T010 [P] Write unit tests for DateHelpers in TogglMacTests/Utilities/DateHelpersTests.swift — test dayStart/dayEnd, weekStart/weekEnd (Monday start), date range queries

### Implementation

- [x] T011 [P] Implement TimeEntry @Model in TogglMac/Models/TimeEntry.swift — id, taskDescription, startTime, endTime, duration (computed), createdAt, updatedAt, optional Project relationship
- [x] T012 [P] Implement Project @Model in TogglMac/Models/Project.swift — id, name, colorHex, createdAt, inverse relationship to TimeEntry (nullify on delete)
- [x] T013 [P] Implement TimerState @Model in TogglMac/Models/TimerState.swift — id, startTime, taskDescription, createdAt, optional Project relationship, toTimeEntry() conversion method
- [x] T014 Implement DateHelpers in TogglMac/Utilities/DateHelpers.swift — dayStart/dayEnd, weekStart/weekEnd (Monday), dateRange for query predicates
- [x] T015 Verify all foundational tests pass (T007-T010)

**Checkpoint**: Foundation ready — 3 models + DateHelpers, all tests green

---

## Phase 3: User Story 1 - 타이머 시작과 정지 (Priority: P1) 🎯 MVP

**Goal**: 사용자가 타이머를 시작/정지하여 시간을 기록한다. 메뉴바에 경과 시간이 표시된다.

**Independent Test**: 앱 실행 → 시작 버튼 클릭 → 경과 시간 표시 → 정지 → TimeEntry 저장 확인

### Tests (TDD - Write First, Must Fail)

- [x] T016 [P] [US1] Write unit tests for TimerService in TogglMacTests/Services/TimerServiceTests.swift — test start (creates TimerState), stop (creates TimeEntry, deletes TimerState), isRunning, elapsed time, restart after stop, singleton enforcement
- [x] T017 [P] [US1] Write unit tests for TimerViewModel in TogglMacTests/ViewModels/TimerViewModelTests.swift — test start/stop commands, elapsed time formatting (HH:MM:SS), state binding, timer restore on init

### Implementation

- [x] T018 [US1] Implement TimerService in TogglMac/Services/TimerService.swift — start(), stop(), isRunning, elapsedTime, restoreFromPersistence() using SwiftData ModelContext
- [x] T019 [US1] Implement TimerViewModel in TogglMac/ViewModels/TimerViewModel.swift — @Observable class, start/stop commands, formatted elapsed time, Timer.publish(every: 1.0) for UI refresh
- [x] T020 [US1] Implement TimerBarView in TogglMac/Views/MainWindow/TimerBarView.swift — start/stop button, elapsed time display, task description input field
- [x] T021 [US1] Implement AppDelegate in TogglMac/App/AppDelegate.swift — NSStatusItem setup, menu bar icon, display elapsed time in status item title, click to activate main window (NSApp.activate)
- [x] T022 [US1] Wire AppDelegate into TogglMacApp in TogglMac/App/TogglMacApp.swift — @NSApplicationDelegateAdaptor, Window setup with TimerBarView
- [x] T023 [US1] Implement timer state restore on app launch — check for existing TimerState in SwiftData, resume timer if found
- [x] T024 [P] [US1] Write UI test for timer start/stop flow in TogglMacUITests/TimerFlowTests.swift — launch → click start → verify timer running → click stop → verify entry saved
- [x] T025 [US1] Verify all US1 tests pass (T016-T017, T024)

**Checkpoint**: Timer start/stop works, elapsed time in menu bar, TimeEntry persisted. MVP core functional.

---

## Phase 4: User Story 2 - 업무명 등록 및 수정 (Priority: P2)

**Goal**: 시간 항목에 업무명과 프로젝트를 지정/수정할 수 있다.

**Independent Test**: 업무명 입력 → 타이머 시작 → 정지 → 캘린더에서 항목 클릭 → 업무명 확인 → 수정 → 반영 확인

### Tests (TDD - Write First, Must Fail)

- [x] T026 [P] [US2] Write unit tests for ProjectService in TogglMacTests/Services/ProjectServiceTests.swift — test create, update, delete project, list projects, delete cascading (TimeEntry.project → nil)
- [x] T027 [P] [US2] Write unit tests for TimeEntryService in TogglMacTests/Services/TimeEntryServiceTests.swift — test update taskDescription, assign/change project, fetch by date range
- [x] T028 [P] [US2] Write unit tests for ProjectViewModel in TogglMacTests/ViewModels/ProjectViewModelTests.swift — test create/edit/delete project, project list binding
- [x] T029 [P] [US2] Write unit tests for TimeEntryViewModel in TogglMacTests/ViewModels/TimeEntryViewModelTests.swift — test update description, update project assignment

### Implementation

- [x] T030 [US2] Implement ProjectService in TogglMac/Services/ProjectService.swift — create, update, delete, list (sorted by name)
- [x] T031 [US2] Implement TimeEntryService in TogglMac/Services/TimeEntryService.swift — update taskDescription, assign project, fetchByDateRange, fetchByProject
- [x] T032 [US2] Implement ProjectViewModel in TogglMac/ViewModels/ProjectViewModel.swift — @Observable, project CRUD commands, project list binding
- [x] T033 [US2] Implement TimeEntryViewModel in TogglMac/ViewModels/TimeEntryViewModel.swift — @Observable, update description/project, selected entry binding
- [x] T034 [US2] Update TimerBarView to include task description TextField and project picker dropdown in TogglMac/Views/MainWindow/TimerBarView.swift
- [x] T035 [US2] Implement EntryEditPanel in TogglMac/Views/Entry/EntryEditPanel.swift — edit task description, project selector, start/end time display (read-only for now)
- [x] T036 [P] [US2] Implement ProjectListView in TogglMac/Views/Project/ProjectListView.swift — list projects with color indicators
- [x] T037 [P] [US2] Implement ProjectEditView in TogglMac/Views/Project/ProjectEditView.swift — name input, color picker (predefined palette), save/cancel
- [x] T038 [P] [US2] Write UI test for entry editing flow in TogglMacUITests/EntryEditTests.swift — start with description → stop → click block → verify description → edit → verify change
- [x] T039 [US2] Verify all US2 tests pass (T026-T029, T038)

**Checkpoint**: Tasks have descriptions and projects. Entries editable via click. Projects manageable.

---

## Phase 5: User Story 3 - 캘린더 뷰에서 시간 항목 확인 (Priority: P3)

**Goal**: 일간/주간 캘린더 뷰에서 시간 블록을 시각적으로 확인한다. 사이드바에서 프로젝트를 관리한다.

**Independent Test**: 여러 항목 기록 → 일간 뷰에서 블록 위치 확인 → 주간 전환 → 7일 컬럼 확인 → 날짜 이동 확인

### Tests (TDD - Write First, Must Fail)

- [x] T040 [P] [US3] Write unit tests for CalendarViewModel in TogglMacTests/ViewModels/CalendarViewModelTests.swift — test date navigation (prev/next day/week), current view mode (day/week), entries for date range, week start is Monday, time block position calculation (Y offset, height from start/end time)

### Implementation

- [x] T041 [US3] Implement CalendarViewModel in TogglMac/ViewModels/CalendarViewModel.swift — @Observable, selectedDate, viewMode (day/week), navigate prev/next, entries query, timeToYPosition/heightForDuration helpers
- [x] T042 [US3] Implement DayColumnView in TogglMac/Views/Calendar/DayColumnView.swift — 24h vertical timeline (0:00~24:00), hour labels, time blocks positioned via GeometryReader overlay, current time indicator
- [x] T043 [US3] Implement TimeBlockView in TogglMac/Views/Calendar/TimeBlockView.swift — colored block with task description, project color, duration label, click handler to open EntryEditPanel
- [x] T044 [US3] Implement WeekHeaderView in TogglMac/Views/Calendar/WeekHeaderView.swift — Mon~Sun column headers with dates, daily total time per column, current day highlight
- [x] T045 [US3] Implement CalendarContainerView in TogglMac/Views/Calendar/CalendarContainerView.swift — day/week toggle, prev/next navigation, ScrollView with DayColumnView(s), running timer block real-time expansion
- [x] T046 [US3] Implement SidebarView in TogglMac/Views/MainWindow/SidebarView.swift — project list from ProjectListView, add/edit project buttons
- [x] T047 [US3] Implement ContentView in TogglMac/Views/MainWindow/ContentView.swift — NavigationSplitView with SidebarView (left) + CalendarContainerView (main) + TimerBarView (top)
- [x] T048 [P] [US3] Write UI test for calendar view in TogglMacUITests/CalendarViewTests.swift — verify time blocks visible, day/week switch, date navigation, running timer block expands
- [x] T049 [US3] Verify all US3 tests pass (T040, T048)

**Checkpoint**: Full calendar UI working. Time blocks visible in day/week view. Sidebar with project list. Main window layout complete.

---

## Phase 6: User Story 4 - 수동 시간 입력 (Priority: P4)

**Goal**: 타이머 없이 과거 시간을 수동으로 입력한다. 캘린더 빈 시간대 클릭으로 입력 폼 열기.

**Independent Test**: 캘린더 빈 시간대 클릭 → 수동 입력 폼 → 시작/종료 시간 입력 → 저장 → 캘린더에 블록 표시 확인

### Tests (TDD - Write First, Must Fail)

- [x] T050 [P] [US4] Write unit tests for manual entry creation in TogglMacTests/Services/TimeEntryServiceTests.swift — test createManual (with start/end), validation (start < end), overlap detection and warning

### Implementation

- [x] T051 [US4] Add createManual(start:end:description:project:) and detectOverlaps(start:end:) to TimeEntryService in TogglMac/Services/TimeEntryService.swift
- [x] T052 [US4] Implement ManualEntryForm in TogglMac/Views/Entry/ManualEntryForm.swift — DatePicker for start/end time, task description, project picker, validation error display, overlap warning with continue/cancel option
- [x] T053 [US4] Add click-on-empty-slot handler to DayColumnView — detect click Y position → convert to time → open ManualEntryForm with pre-filled start time in TogglMac/Views/Calendar/DayColumnView.swift
- [x] T054 [US4] Wire ⌘N keyboard shortcut to open ManualEntryForm in TogglMac/Views/MainWindow/ContentView.swift
- [x] T055 [P] [US4] Write UI test for manual entry flow in TogglMacUITests/ManualEntryTests.swift — click empty slot → fill form → save → verify block appears, test validation error for invalid times
- [x] T056 [US4] Verify all US4 tests pass (T050, T055)

**Checkpoint**: Manual time entry fully working. Validation and overlap detection operational.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: 삭제/Undo, 글로벌 단축키, 엣지 케이스 처리

### Tests (TDD)

- [x] T057 [P] Write unit tests for UndoService in TogglMacTests/Services/UndoServiceTests.swift — test delete entry, undo restores entry, undo only for delete (not edit/create), memory cleanup after new action
- [x] T058 [P] Write unit tests for HotkeyService in TogglMacTests/Services/HotkeyServiceTests.swift — test register/unregister hotkey, callback invocation

### Implementation

- [x] T059 Implement UndoService in TogglMac/Services/UndoService.swift — delete with NSUndoManager integration, ⌘Z to restore deleted TimeEntry, scope limited to delete only
- [x] T060 Implement HotkeyService in TogglMac/Services/HotkeyService.swift — Carbon RegisterEventHotKey for global timer toggle, register on app launch, unregister on terminate
- [x] T061 Wire HotkeyService into AppDelegate in TogglMac/App/AppDelegate.swift — register global hotkey, callback toggles TimerService.start/stop
- [x] T062 Wire UndoService into TimeEntryViewModel — ⌘Z shortcut in ContentView, delete action in EntryEditPanel calls UndoService
- [x] T063 Handle edge cases in TimerService: app termination persists TimerState, system sleep/wake preserves accurate elapsed time, midnight crossing (single continuous entry)
- [x] T064 Handle edge case: project deletion cascades to "프로젝트 없음" in TimeEntryService — verify TimeEntry.project becomes nil
- [x] T065 Handle edge case: empty task description defaults to "제목 없음" in TimerService.stop()
- [x] T066 Run full test suite — verify all unit tests (TogglMacTests) and UI tests (TogglMacUITests) pass
- [x] T067 Code cleanup: remove dead code, verify SwiftLint compliance, ensure no warnings

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Phase 2 — core timer functionality
- **US2 (Phase 4)**: Depends on Phase 2 — can run parallel with US1 if models are ready
- **US3 (Phase 5)**: Depends on US1 + US2 — needs timer and entry data to display
- **US4 (Phase 6)**: Depends on US3 — needs calendar view for click-to-create
- **Polish (Phase 7)**: Depends on US1-US4 — cross-cutting concerns

### User Story Dependencies

- **US1 (P1)**: Depends on Foundational only — fully independent
- **US2 (P2)**: Depends on Foundational only — independent from US1 (can parallel)
- **US3 (P3)**: Depends on US1 + US2 — needs TimerBarView and EntryEditPanel
- **US4 (P4)**: Depends on US3 — needs CalendarView for click-on-empty-slot

### Within Each User Story

- Tests MUST be written and FAIL before implementation (TDD)
- Models before services
- Services before ViewModels
- ViewModels before Views
- UI tests after views are implemented

### Parallel Opportunities

```bash
# Phase 2: All model tests in parallel
T007, T008, T009, T010 — all test files independent

# Phase 2: All model implementations in parallel
T011, T012, T013 — all different files

# Phase 3 (US1): Tests in parallel
T016, T017 — independent test files

# Phase 4 (US2): Tests in parallel
T026, T027, T028, T029 — independent test files

# Phase 4 (US2): Independent views in parallel
T036, T037 — ProjectListView and ProjectEditView

# Phase 7: Tests in parallel
T057, T058 — UndoService and HotkeyService tests
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL)
3. Complete Phase 3: US1 — Timer start/stop
4. **STOP and VALIDATE**: Timer works, entries persist, menu bar shows time
5. Deploy/demo if ready — this is a usable MVP

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. US1 → Timer works → **MVP!**
3. US2 → Task descriptions + projects → Enhanced tracking
4. US3 → Calendar visualization → Full UI
5. US4 → Manual entry → Complete feature set
6. Polish → Undo, hotkeys, edge cases → Production quality

---

## Notes

- TDD is NON-NEGOTIABLE (Constitution III) — every implementation task has preceding test tasks
- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story
- Each user story is independently completable and testable
- Commit after each task or logical group (test commit + implementation commit)
- Stop at any checkpoint to validate story independently
