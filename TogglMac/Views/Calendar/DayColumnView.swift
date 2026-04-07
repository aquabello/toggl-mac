import SwiftUI

struct DayColumnView: View {
    let date: Date
    let entries: [TimeEntry]
    let activeTimerStart: Date?
    let activeTimerProject: Project?
    let activeTimerDescription: String?
    let onEntryTap: (TimeEntry) -> Void
    let onEntryDelete: ((TimeEntry) -> Void)?
    let onEntryMove: ((TimeEntry, Date) -> Void)?
    let onActiveTimerTap: (() -> Void)?
    let onEmptySlotClick: (Date) -> Void

    @State private var now = Date()

    private let totalHeight = AppConstants.Calendar.totalDayHeight
    private let hourHeight = AppConstants.Calendar.hourHeight
    private let timeLabelWidth: CGFloat = 50

    var body: some View {
        GeometryReader { geometry in
            let safeWidth = max(geometry.size.width, 1)
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    ZStack(alignment: .topLeading) {
                        // Tap gesture for empty slot (behind everything)
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: safeWidth, height: totalHeight)
                            .onTapGesture { location in
                                let tappedDate = yPositionToDate(y: location.y)
                                onEmptySlotClick(tappedDate)
                            }

                        // Background grid + hour labels
                        VStack(spacing: 0) {
                            ForEach(0..<AppConstants.Calendar.hoursInDay, id: \.self) { hour in
                                HStack(alignment: .top, spacing: 0) {
                                    Text(String(format: "%d:00 %@", hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour), hour < 12 ? "AM" : "PM"))
                                        .font(.system(size: 10))
                                        .foregroundStyle(TogglTheme.textTertiary)
                                        .frame(width: timeLabelWidth, alignment: .trailing)
                                        .padding(.trailing, 6)

                                    Rectangle()
                                        .fill(TogglTheme.gridLine)
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                }
                                .frame(height: hourHeight, alignment: .top)
                            }
                        }
                        .frame(width: safeWidth)
                        .allowsHitTesting(false)

                        // Current time indicator (pink dot + line)
                        if DateHelpers.isToday(date) {
                            currentTimeIndicator(width: safeWidth, currentTime: now)
                        }

                        // Time blocks (on top, receive hover + tap) — with overlap layout
                        let layout = computeOverlapLayout(entries: entries)
                        let contentWidth = max(safeWidth - timeLabelWidth - 8, 1)
                        ForEach(entries) { entry in
                            let info = layout[entry.id] ?? (column: 0, totalColumns: 1)
                            let colWidth = contentWidth / CGFloat(info.totalColumns)
                            let leadingPad = timeLabelWidth + 4 + colWidth * CGFloat(info.column)
                            TimeBlockView(
                                entry: entry,
                                totalHeight: totalHeight,
                                onTap: { onEntryTap(entry) },
                                onDelete: { onEntryDelete?(entry) },
                                onMove: { yDelta in
                                    let secondsDelta = (yDelta / totalHeight) * 24 * 60 * 60
                                    let newStart = entry.startTime.addingTimeInterval(secondsDelta)
                                    onEntryMove?(entry, newStart)
                                },
                                columnIndex: info.column,
                                totalColumns: info.totalColumns
                            )
                            .frame(width: colWidth - 2)
                            .padding(.leading, leadingPad)
                            .frame(width: safeWidth, alignment: .leading)
                        }

                        // Active timer block (live, expanding) — full width
                        if let start = activeTimerStart, DateHelpers.isSameDay(start, date) {
                            let yPos = DateHelpers.timeToYPosition(date: start, totalHeight: totalHeight)
                            let duration = now.timeIntervalSince(start)
                            let realHeight = DateHelpers.durationToHeight(duration: duration, totalHeight: totalHeight)
                            let minHeight: CGFloat = 10
                            let height = max(realHeight, minHeight)
                            let color: Color = if let hex = activeTimerProject?.colorHex {
                                Color(hex: hex)
                            } else {
                                TogglTheme.accentGreen
                            }
                            let title = activeTimerDescription?.isEmpty == false ? activeTimerDescription! : "기록 중"
                            let showText = height >= 14 // 텍스트 표시 가능한 최소 높이

                            VStack(alignment: .leading, spacing: 2) {
                                if showText {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 6, height: 6)
                                        Text(title)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                    }
                                    Text(DateHelpers.formattedElapsedTime(duration))
                                        .font(.system(size: 10, weight: .medium).monospacedDigit())
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, showText ? 8 : 4)
                            .padding(.vertical, showText ? 4 : 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: height)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(color.opacity(0.4))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(color.opacity(0.6), lineWidth: 1)
                            )
                            .overlay(
                                Rectangle()
                                    .fill(color)
                                    .frame(width: 3)
                                    .clipShape(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: 6,
                                            bottomLeadingRadius: 6
                                        )
                                    ),
                                alignment: .leading
                            )
                            .offset(y: yPos)
                            .padding(.leading, timeLabelWidth + 4)
                            .padding(.trailing, 4)
                            .frame(width: safeWidth, alignment: .leading)
                            .animation(.linear(duration: 0.5), value: height)
                            .onTapGesture { onActiveTimerTap?() }
                        }
                    }
                    .frame(height: totalHeight)
                    .id("content")
                }
                .onAppear {
                    proxy.scrollTo("content", anchor: currentScrollAnchor())
                }
            }
        }
        .background(TogglTheme.backgroundSecondary)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            now = Date()
        }
    }

    private func currentTimeIndicator(width: CGFloat, currentTime: Date) -> some View {
        let yPos = DateHelpers.timeToYPosition(date: currentTime, totalHeight: totalHeight)
        return ZStack(alignment: .leading) {
            // Pink line
            Rectangle()
                .fill(TogglTheme.currentTimeIndicator)
                .frame(height: 2)
                .frame(width: max(width - timeLabelWidth, 1))
                .padding(.leading, timeLabelWidth)
                .shadow(color: TogglTheme.currentTimeIndicator.opacity(0.5), radius: 3, y: 0)

            // Pink dot
            Circle()
                .fill(TogglTheme.currentTimeIndicator)
                .frame(width: 10, height: 10)
                .shadow(color: TogglTheme.currentTimeIndicator.opacity(0.6), radius: 4)
                .offset(x: timeLabelWidth - 5)
        }
        .offset(y: yPos)
    }

    private func yPositionToDate(y: CGFloat) -> Date {
        let fraction = y / totalHeight
        let totalMinutes = fraction * 24 * 60
        let hours = Int(totalMinutes / 60)
        let minutes = Int(totalMinutes.truncatingRemainder(dividingBy: 60))
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = min(hours, 23)
        components.minute = minutes
        return Calendar.current.date(from: components) ?? date
    }

    private func currentScrollAnchor() -> UnitPoint {
        // 현재 시간을 뷰포트 상단 약 20% 지점에 배치
        let components = Foundation.Calendar.current.dateComponents([.hour, .minute], from: Date())
        let currentMinutes = CGFloat(components.hour ?? 0) * 60 + CGFloat(components.minute ?? 0)
        let totalMinutes: CGFloat = 24 * 60
        // anchor.y는 content 내 비율 위치 → 뷰포트의 같은 비율에 매핑됨
        // 현재 시간보다 약 1시간 앞을 top에 놓기
        let targetMinutes = max(0, currentMinutes - 60)
        let fraction = targetMinutes / totalMinutes
        return UnitPoint(x: 0, y: fraction)
    }

    /// Compute column assignments for overlapping time entries.
    /// Returns [entryID: (column, totalColumns)] for layout.
    private func computeOverlapLayout(entries: [TimeEntry]) -> [UUID: (column: Int, totalColumns: Int)] {
        guard !entries.isEmpty else { return [:] }

        let sorted = entries.sorted { $0.startTime < $1.startTime }

        // Build overlap groups: entries that transitively overlap
        var groups: [[TimeEntry]] = []
        var currentGroup: [TimeEntry] = []
        var groupEnd: Date = .distantPast

        for entry in sorted {
            if entry.startTime < groupEnd {
                // Overlaps with current group
                currentGroup.append(entry)
                groupEnd = max(groupEnd, entry.endTime)
            } else {
                if !currentGroup.isEmpty {
                    groups.append(currentGroup)
                }
                currentGroup = [entry]
                groupEnd = entry.endTime
            }
        }
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }

        // Assign columns within each group
        var result: [UUID: (column: Int, totalColumns: Int)] = [:]

        for group in groups {
            if group.count == 1 {
                result[group[0].id] = (column: 0, totalColumns: 1)
                continue
            }

            // Greedy column assignment
            var columns: [[TimeEntry]] = []
            for entry in group {
                var placed = false
                for colIdx in columns.indices {
                    let lastInCol = columns[colIdx].last!
                    if entry.startTime >= lastInCol.endTime {
                        columns[colIdx].append(entry)
                        result[entry.id] = (column: colIdx, totalColumns: 0) // totalColumns filled later
                        placed = true
                        break
                    }
                }
                if !placed {
                    result[entry.id] = (column: columns.count, totalColumns: 0)
                    columns.append([entry])
                }
            }

            let totalCols = columns.count
            for entry in group {
                if var info = result[entry.id] {
                    info.totalColumns = totalCols
                    result[entry.id] = info
                }
            }
        }

        return result
    }
}
