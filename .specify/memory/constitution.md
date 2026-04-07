<!--
  Sync Impact Report
  ==================
  Version change: N/A → 1.0.0 (initial ratification)
  
  Added principles:
    - I. Native SwiftUI
    - II. Local-First
    - III. Test-Driven Development (NON-NEGOTIABLE)
    - IV. Minimal MVP
  
  Added sections:
    - Technology Stack
    - Development Workflow
    - Governance
  
  Templates requiring updates:
    - .specify/templates/plan-template.md ✅ compatible (Constitution Check section exists)
    - .specify/templates/spec-template.md ✅ compatible (user stories + acceptance criteria align)
    - .specify/templates/tasks-template.md ✅ compatible (TDD test-first flow supported)
  
  Follow-up TODOs: None
-->

# Toggl Mac Constitution

## Core Principles

### I. Native SwiftUI

모든 UI는 macOS 네이티브 SwiftUI로 구현한다.

- 앱은 macOS 14(Sonoma) 이상을 타겟으로 한다
- 메뉴바(NSStatusItem) 통합을 통해 상시 접근 가능한 타이머를 제공해야 한다
- 글로벌 키보드 단축키를 지원하여 앱이 포커스되지 않아도 타이머를 제어할 수 있어야 한다
- AppKit 브릿징은 SwiftUI로 불가능한 기능(메뉴바, 글로벌 단축키)에 한해 허용한다
- 서드파티 UI 라이브러리 사용을 금지한다

### II. Local-First

모든 데이터는 사용자 기기에 로컬로 저장한다.

- SwiftData를 기본 영속성 레이어로 사용한다
- 외부 서버, 클라우드 동기화, 네트워크 호출이 없어야 한다
- 사용자 데이터는 앱 샌드박스 내에서만 관리한다
- 데이터 내보내기(CSV/JSON)를 통해 사용자가 자신의 데이터를 소유할 수 있어야 한다
- 앱은 네트워크 연결 없이 완전하게 동작해야 한다

### III. Test-Driven Development (NON-NEGOTIABLE)

TDD는 모든 기능 구현에 필수이다.

- Red-Green-Refactor 사이클을 엄격히 준수한다
- 테스트를 먼저 작성하고, 실패를 확인한 뒤, 구현한다
- XCTest를 테스트 프레임워크로 사용한다
- 비즈니스 로직(모델, 서비스)은 반드시 단위 테스트를 가져야 한다
- UI 테스트는 핵심 사용자 플로우에 대해 작성한다
- 테스트 없는 기능 코드의 머지를 금지한다

### IV. Minimal MVP

MVP 범위를 엄격히 제한하여 핵심 가치를 빠르게 전달한다.

- MVP 범위: 타이머(시작/정지/수동 시간 입력) + 프로젝트 분류
- 리포트, 통계, 차트는 MVP 이후 단계로 명시적으로 제외한다
- 새 기능 추가 전 기존 기능의 안정성을 우선한다
- YAGNI 원칙을 따른다: 현재 필요하지 않은 기능을 미리 구현하지 않는다
- 기능 요청 시 MVP 범위 내인지 먼저 검증한다

## Technology Stack

- **언어**: Swift 5.9+
- **UI 프레임워크**: SwiftUI (macOS 14+)
- **영속성**: SwiftData
- **테스트**: XCTest
- **빌드**: Xcode / Swift Package Manager
- **최소 지원**: macOS 14 Sonoma
- **아키텍처**: MVVM (Model-View-ViewModel)

## Development Workflow

- 모든 변경은 feature 브랜치에서 작업한다
- TDD 사이클: 테스트 작성 → 실패 확인 → 구현 → 리팩터
- 커밋은 논리적 단위로 분리한다 (테스트 커밋과 구현 커밋 분리 권장)
- 코드 리뷰 시 테스트 존재 여부를 필수 확인 항목으로 한다
- SwiftLint를 사용하여 코드 스타일 일관성을 유지한다

## Governance

- 이 Constitution은 프로젝트의 모든 설계 및 구현 결정에 우선한다
- 원칙 수정 시: 변경 사유 문서화 → 버전 업데이트 → 영향받는 템플릿 동기화
- 버전 관리: MAJOR.MINOR.PATCH (SemVer)
  - MAJOR: 원칙 제거 또는 호환되지 않는 재정의
  - MINOR: 새 원칙/섹션 추가 또는 기존 내용의 실질적 확장
  - PATCH: 표현 수정, 오타, 의미 변경 없는 개선
- 모든 PR은 Constitution 준수 여부를 검증해야 한다
- MVP 범위 외 기능 추가는 Constitution 수정(MINOR bump)을 선행해야 한다

**Version**: 1.0.0 | **Ratified**: 2026-04-02 | **Last Amended**: 2026-04-02
