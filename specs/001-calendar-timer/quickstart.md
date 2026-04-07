# Quickstart: Calendar Timer

## Prerequisites

- macOS 14 Sonoma 이상
- Xcode 15.0 이상
- Swift 5.9 이상

## Setup

```bash
# 1. 리포지토리 클론
git clone <repo-url>
cd toggl-mac

# 2. Xcode에서 프로젝트 열기
open TogglMac.xcodeproj
# 또는 SPM 사용 시
# open Package.swift

# 3. 빌드 및 실행
# Xcode에서 ⌘R 또는:
xcodebuild -scheme TogglMac -configuration Debug build

# 4. 테스트 실행
xcodebuild -scheme TogglMac -configuration Debug test
```

## 첫 실행

1. 앱 실행 → 메인 윈도우와 메뉴바 아이콘이 나타남
2. 상단 타이머 바에서 업무명 입력 → 시작 버튼 클릭
3. 메뉴바에 경과 시간이 표시됨
4. 정지 버튼 클릭 → 캘린더 뷰에 시간 블록이 나타남

## 프로젝트 구조 요약

```
TogglMac/
├── App/           # 앱 진입점, AppDelegate
├── Models/        # SwiftData @Model (TimeEntry, Project, TimerState)
├── ViewModels/    # MVVM ViewModel 레이어
├── Views/         # SwiftUI 뷰
├── Services/      # 비즈니스 로직 서비스
└── Utilities/     # 헬퍼, 상수

TogglMacTests/     # 단위 테스트 (XCTest)
TogglMacUITests/   # UI 테스트
```

## 핵심 아키텍처

- **MVVM**: View → ViewModel → Service → SwiftData
- **Timer 별도 엔티티**: TimerState(실행 중) → 정지 시 TimeEntry로 변환
- **메뉴바**: AppKit NSStatusItem으로 아이콘 + 경과 시간 표시
- **글로벌 단축키**: Carbon RegisterEventHotKey로 타이머 토글

## TDD 워크플로우

```
1. 테스트 작성 (Red)    → TogglMacTests/에 테스트 추가
2. 실패 확인            → xcodebuild test
3. 구현 (Green)         → 최소한의 코드로 테스트 통과
4. 리팩터 (Refactor)    → 코드 정리, 테스트 여전히 통과 확인
```
