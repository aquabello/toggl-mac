# Implementation Plan: Calendar Timer

**Branch**: `001-calendar-timer` | **Date**: 2026-04-02 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-calendar-timer/spec.md`

## Summary

macOS 14+ 네이티브 시간 추적 앱을 SwiftUI + SwiftData로 구현한다. 메인 윈도우에 캘린더 형태(일간/주간)의 시간 블록 뷰를 제공하고, 메뉴바 아이콘으로 앱을 활성화한다. Timer는 별도 엔티티로 관리하며 정지 시 TimeEntry로 변환한다. 타이머 시작/정지를 위한 글로벌 키보드 단축키를 지원한다. MVVM 아키텍처를 사용하며, TDD로 개발한다.

## Technical Context

**Language/Version**: Swift 5.9+
**Primary Dependencies**: SwiftUI, AppKit (NSStatusItem, 글로벌 단축키), SwiftData, Carbon (글로벌 핫키)
**Storage**: SwiftData (SQLite 기반, 앱 샌드박스 내)
**Testing**: XCTest (단위 테스트 + UI 테스트)
**Target Platform**: macOS 14 Sonoma+
**Project Type**: desktop-app (macOS 네이티브)
**Performance Goals**: 60fps 캘린더 스크롤, 1초 이내 타이머 UI 갱신, 3초 이내 앱 시작
**Constraints**: 오프라인 전용, 네트워크 없음, 서드파티 UI 라이브러리 금지
**Scale/Scope**: 단일 사용자, 6개월+ 데이터(~1,800개 TimeEntry), 4개 화면(타이머 바, 캘린더 뷰, 사이드바, 편집 패널)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Native SwiftUI | 모든 UI는 SwiftUI, AppKit은 메뉴바/글로벌 단축키에만 사용 | ✅ PASS |
| II. Local-First | SwiftData 로컬 저장, 네트워크 호출 없음 | ✅ PASS |
| III. TDD (NON-NEGOTIABLE) | XCTest로 모델/서비스 단위 테스트 + UI 테스트 | ✅ PASS |
| IV. Minimal MVP | 타이머 + 프로젝트 + 캘린더 뷰만, 리포트/통계 제외 | ✅ PASS |
| 서드파티 금지 | 글로벌 단축키를 Carbon API로 직접 구현 (MASShortcut 등 미사용) | ✅ PASS |

## Project Structure

### Documentation (this feature)

```text
specs/001-calendar-timer/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
TogglMac/
├── App/
│   ├── TogglMacApp.swift          # @main, MenuBar + Window setup
│   └── AppDelegate.swift          # NSStatusItem, 글로벌 단축키 등록
├── Models/
│   ├── TimeEntry.swift            # @Model SwiftData 엔티티
│   ├── Project.swift              # @Model SwiftData 엔티티
│   └── TimerState.swift           # @Model SwiftData 엔티티 (별도 Timer)
├── ViewModels/
│   ├── TimerViewModel.swift       # 타이머 시작/정지/상태 관리
│   ├── CalendarViewModel.swift    # 캘린더 뷰 데이터, 날짜 이동
│   ├── ProjectViewModel.swift     # 프로젝트 CRUD
│   └── TimeEntryViewModel.swift   # 시간 항목 편집/삭제/Undo
├── Views/
│   ├── MainWindow/
│   │   ├── ContentView.swift      # 메인 레이아웃 (사이드바 + 캘린더)
│   │   ├── TimerBarView.swift     # 상단 타이머 컨트롤
│   │   └── SidebarView.swift      # 좌측 프로젝트 사이드바
│   ├── Calendar/
│   │   ├── CalendarContainerView.swift  # 일간/주간 전환 컨테이너
│   │   ├── DayColumnView.swift    # 단일 일간 컬럼 (24h 세로축)
│   │   ├── TimeBlockView.swift    # 개별 시간 블록 렌더링
│   │   └── WeekHeaderView.swift   # 주간 뷰 헤더 (월~일, 일별 합계)
│   ├── Entry/
│   │   ├── EntryEditPanel.swift   # 시간 항목 편집 패널
│   │   └── ManualEntryForm.swift  # 수동 시간 입력 폼
│   └── Project/
│       ├── ProjectListView.swift  # 프로젝트 목록
│       └── ProjectEditView.swift  # 프로젝트 생성/편집
├── Services/
│   ├── TimerService.swift         # 타이머 비즈니스 로직
│   ├── TimeEntryService.swift     # TimeEntry CRUD + 유효성 검증
│   ├── ProjectService.swift       # Project CRUD
│   ├── UndoService.swift          # 삭제 Undo 관리
│   └── HotkeyService.swift        # 글로벌 키보드 단축키 (Carbon API)
└── Utilities/
    ├── DateHelpers.swift          # 날짜/시간 유틸리티
    └── Constants.swift            # 앱 상수 (단축키 코드 등)

TogglMacTests/
├── Models/
│   ├── TimeEntryTests.swift
│   ├── ProjectTests.swift
│   └── TimerStateTests.swift
├── ViewModels/
│   ├── TimerViewModelTests.swift
│   ├── CalendarViewModelTests.swift
│   ├── ProjectViewModelTests.swift
│   └── TimeEntryViewModelTests.swift
├── Services/
│   ├── TimerServiceTests.swift
│   ├── TimeEntryServiceTests.swift
│   ├── ProjectServiceTests.swift
│   └── UndoServiceTests.swift
└── Utilities/
    └── DateHelpersTests.swift

TogglMacUITests/
├── TimerFlowTests.swift           # P1: 타이머 시작/정지 플로우
├── EntryEditTests.swift           # P2: 업무명/프로젝트 편집
├── CalendarViewTests.swift        # P3: 캘린더 뷰 표시
└── ManualEntryTests.swift         # P4: 수동 시간 입력
```

**Structure Decision**: macOS 네이티브 데스크톱 앱으로, Xcode 프로젝트 구조를 따른다. MVVM 패턴에 맞춰 Models/ViewModels/Views/Services로 분리한다. 테스트는 단위 테스트(TogglMacTests)와 UI 테스트(TogglMacUITests)로 구분한다.

## Complexity Tracking

> Constitution Check 위반 없음. 모든 gate 통과.

| 항목 | 판단 | 근거 |
|------|------|------|
| AppKit 사용 | 허용 | NSStatusItem, 글로벌 단축키는 SwiftUI로 불가능 — Constitution I에서 명시 허용 |
| Carbon API | 허용 | 글로벌 핫키 등록에 필요, 서드파티 라이브러리 대안(MASShortcut) 사용 금지 |
