# Research: Calendar Timer

**Phase 0 Output** | **Date**: 2026-04-02

## R1: SwiftUI 메뉴바 통합 (NSStatusItem)

**Decision**: AppKit의 NSStatusItem을 AppDelegate에서 설정하고, SwiftUI 메인 윈도우와 연동한다.

**Rationale**: SwiftUI에는 네이티브 메뉴바 아이콘 API가 없다. MenuBarExtra(macOS 13+)는 팝오버 전용이며 "앱 열기" 동작에는 부적합하다. NSStatusItem은 클릭 시 NSApp.activate()로 메인 윈도우를 활성화하는 패턴이 확립되어 있다.

**Alternatives considered**:
- MenuBarExtra: 팝오버만 지원, 메인 윈도우 활성화 불가 → 부적합
- 순수 SwiftUI (메뉴바 없음): Constitution에서 메뉴바 통합 요구 → 부적합

## R2: SwiftData 영속성 설계

**Decision**: SwiftData @Model을 사용하여 TimeEntry, Project, TimerState를 정의한다. ModelContainer는 앱 시작 시 한 번 생성하고 Environment로 주입한다.

**Rationale**: Constitution에서 SwiftData를 영속성 레이어로 지정했다. macOS 14+에서 SwiftData는 안정적이며 SwiftUI와 @Query 매크로로 원활하게 통합된다. CoreData 대비 보일러플레이트가 적다.

**Alternatives considered**:
- CoreData: 기능적으로 충분하지만 Constitution에서 SwiftData 명시 → 미채택
- SQLite 직접 사용: 불필요한 복잡도 → 미채택
- UserDefaults: 복잡한 관계형 데이터에 부적합 → 미채택

## R3: 글로벌 키보드 단축키 구현

**Decision**: Carbon API의 `RegisterEventHotKey`를 사용하여 글로벌 핫키를 등록한다.

**Rationale**: macOS에서 앱 비활성 상태에서도 동작하는 글로벌 단축키는 Carbon `RegisterEventHotKey` 또는 CGEvent tap이 유일한 방법이다. Carbon API가 더 안정적이고 구현이 간단하다. 서드파티 라이브러리(MASShortcut, HotKey 등)는 Constitution에서 금지한다.

**Alternatives considered**:
- MASShortcut / HotKey SPM 패키지: 서드파티 UI 라이브러리 금지 → 미채택
- CGEvent tap: Accessibility 권한 필요, Carbon보다 복잡 → 미채택
- NSEvent.addGlobalMonitorForEvents: 키 이벤트는 가로채지만 다른 앱에 전달도 됨, 핫키 용도에 부적합 → 미채택

## R4: 캘린더 뷰 렌더링 전략

**Decision**: SwiftUI의 ScrollView + LazyVStack/GeometryReader 조합으로 24시간 타임라인을 구현한다. 시간 블록은 절대 위치(offset)로 배치한다.

**Rationale**: 24시간 세로축 위에 시간 블록을 배치하려면 각 블록의 Y 좌표와 높이를 시작/종료 시간으로 계산해야 한다. GeometryReader로 전체 높이를 확보하고 overlay로 블록을 배치하는 패턴이 macOS 캘린더 앱과 유사하다. LazyVStack은 보이는 영역만 렌더링하여 50개+ 항목에서도 60fps를 유지한다.

**Alternatives considered**:
- NSCollectionView (AppKit): SwiftUI 원칙 위반 → 미채택
- List 기반 렌더링: 시간 블록의 자유 배치 불가 → 미채택

## R5: Timer 별도 엔티티 설계

**Decision**: TimerState를 별도 SwiftData @Model로 정의한다. 앱 전체에서 0~1개만 존재하며, 타이머 정지 시 TimerState 데이터로 TimeEntry를 생성하고 TimerState를 삭제한다.

**Rationale**: 사용자가 Timer를 별도 엔티티로 결정했다. TimerState를 분리하면 앱 종료/재시작 시 타이머 상태 복원이 명확하다(TimerState가 존재하면 실행 중). TimeEntry의 endTime null 체크보다 의도가 명확하다.

**Alternatives considered**:
- TimeEntry.endTime == nil로 실행 중 판별: 사용자가 별도 엔티티 선택 → 미채택

## R6: Undo 삭제 구현

**Decision**: UndoService에서 삭제된 TimeEntry를 메모리에 임시 보관하고 ⌘Z 시 복원한다. macOS 네이티브 UndoManager와 통합한다.

**Rationale**: NSUndoManager는 macOS의 표준 Undo 메커니즘이다. SwiftUI의 Environment에서 undoManager에 접근할 수 있다. 삭제만 Undo 대상이므로 구현이 단순하다 — 삭제 시 엔티티를 soft-delete(또는 메모리 보관)하고 Undo 시 복원한다.

**Alternatives considered**:
- 커스텀 Undo 스택: NSUndoManager가 이미 존재하므로 불필요 → 미채택
- Soft delete 플래그: 쿼리 복잡도 증가, 불필요한 필터링 필요 → 미채택

## R7: 실시간 타이머 UI 갱신

**Decision**: Swift의 `Timer.publish(every: 1.0)`로 1초마다 UI를 갱신한다. 메뉴바 아이콘 타이틀과 메인 윈도우 타이머 표시 모두 동일 타이머 소스를 사용한다.

**Rationale**: 1초 간격 갱신은 시간 추적 앱에서 표준이다. Combine의 Timer.publish는 SwiftUI와 자연스럽게 통합되며 메인 스레드에서 실행된다. 메뉴바 아이콘 타이틀은 NSStatusItem.button?.title로 직접 업데이트한다.

**Alternatives considered**:
- DispatchSourceTimer: Combine보다 저수준, SwiftUI 바인딩에 추가 작업 필요 → 미채택
- TimelineView: macOS 14에서 사용 가능하나 1초 정밀도에 과도 → 미채택
