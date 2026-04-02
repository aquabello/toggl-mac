# Data Model: Calendar Timer

**Phase 1 Output** | **Date**: 2026-04-02

## Entities

### Project

업무 분류 단위. TimeEntry의 그룹화에 사용된다.

| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| name | String | 필수, 비어있을 수 없음 |
| colorHex | String | 필수, 6자리 hex (예: "FF6B6B") |
| createdAt | Date | auto-set on creation |

**Relationships**:
- Project → TimeEntry: 1:N (optional, cascade delete 시 TimeEntry의 project를 nil로 설정)

### TimeEntry

하나의 시간 기록. 완료된 작업의 시간을 영속 저장한다.

| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| taskDescription | String | 기본값 "제목 없음" |
| startTime | Date | 필수 |
| endTime | Date | 필수 (TimerState와 달리 완료된 항목만 저장) |
| duration | TimeInterval | computed (endTime - startTime) |
| createdAt | Date | auto-set on creation |
| updatedAt | Date | auto-set on modification |

**Relationships**:
- TimeEntry → Project: N:1 (optional, nullify on project delete)

**Validation Rules**:
- startTime < endTime (필수)
- duration > 0
- startTime과 endTime은 같은 날이 아닐 수 있음 (자정 경과 허용)

### TimerState

현재 실행 중인 타이머 상태. 앱 전체에서 0~1개만 존재한다.

| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| startTime | Date | 필수 |
| taskDescription | String | 기본값 "" (빈 문자열) |
| createdAt | Date | auto-set on creation |

**Relationships**:
- TimerState → Project: N:1 (optional)

**Lifecycle**:
1. **생성**: 타이머 시작 시 TimerState 인스턴스 생성
2. **수정**: 실행 중 업무명/프로젝트 변경 가능
3. **변환**: 타이머 정지 시 → TimerState 데이터로 TimeEntry 생성 (endTime = 현재 시간)
4. **삭제**: TimeEntry 생성 후 TimerState 삭제
5. **복원**: 앱 재시작 시 TimerState가 존재하면 타이머 실행 중으로 복원

**Singleton Constraint**: 새 TimerState 생성 전 기존 TimerState 존재 여부 확인. 존재 시 기존 것을 먼저 TimeEntry로 변환 후 삭제.

## State Transitions

```text
[No Timer] ---(시작 클릭)--→ [TimerState 생성, 실행 중]
                                    |
                              (업무명/프로젝트 수정)
                                    |
[TimerState 삭제] ←--(정지 클릭)--- [TimerState → TimeEntry 변환]
      |
      v
[TimeEntry 저장됨] ---(편집)--→ [TimeEntry 수정됨]
      |
      +---(삭제)--→ [메모리 보관] ---(⌘Z)--→ [TimeEntry 복원]
                         |
                    (새 작업 시)
                         v
                   [영구 삭제]
```

## Indexes (Performance)

- TimeEntry.startTime: 캘린더 뷰에서 날짜 범위 쿼리 (일간/주간)
- TimeEntry.project: 프로젝트별 필터링
- Project.name: 프로젝트 목록 정렬

## Query Patterns

| 용도 | 쿼리 |
|------|------|
| 일간 뷰 | TimeEntry where startTime >= dayStart AND startTime < dayEnd |
| 주간 뷰 | TimeEntry where startTime >= weekStart AND startTime < weekEnd |
| 프로젝트 필터 | TimeEntry where project == selectedProject |
| 실행 중 타이머 | TimerState (0~1개 존재) |
| 일별 합계 | SUM(duration) GROUP BY date(startTime) |
