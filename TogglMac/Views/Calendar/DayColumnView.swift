import SwiftUI

struct DayColumnView: View {
    let date: Date
    let entries: [TimeEntry]
    let activeTimerStart: Date?
    let activeTimerProject: Project?
    let onEntryTap: (TimeEntry) -> Void
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
                                        .padding(.top, 8)
                                }
                                .frame(height: hourHeight)
                            }
                        }
                        .frame(width: safeWidth)

                        // Current time indicator (pink dot + line)
                        if DateHelpers.isToday(date) {
                            currentTimeIndicator(width: safeWidth)
                        }

                        // Time blocks
                        ForEach(entries) { entry in
                            TimeBlockView(
                                entry: entry,
                                totalHeight: totalHeight,
                                onTap: { onEntryTap(entry) }
                            )
                            .padding(.leading, timeLabelWidth + 4)
                            .padding(.trailing, 4)
                            .frame(width: max(safeWidth - timeLabelWidth - 4, 1), alignment: .leading)
                        }

                        // Active timer block (live, expanding)
                        if let start = activeTimerStart, DateHelpers.isSameDay(start, date) {
                            let yPos = DateHelpers.timeToYPosition(date: start, totalHeight: totalHeight)
                            let duration = now.timeIntervalSince(start)
                            let height = max(DateHelpers.durationToHeight(duration: duration, totalHeight: totalHeight),
                                            AppConstants.UI.timeBlockMinHeight)
                            let color: Color = if let hex = activeTimerProject?.colorHex {
                                Color(hex: hex)
                            } else {
                                .green
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("● 기록 중")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                if height > 30 {
                                    Text(DateHelpers.formattedElapsedTime(duration))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: height)
                            .background(color.opacity(0.3))
                            .overlay(
                                Rectangle()
                                    .fill(color)
                                    .frame(width: 3),
                                alignment: .leading
                            )
                            .cornerRadius(4)
                            .offset(y: yPos)
                            .padding(.leading, timeLabelWidth)
                            .padding(.trailing, 2)
                            .frame(width: max(safeWidth - timeLabelWidth - 2, 1), alignment: .leading)
                            .animation(.linear(duration: 0.5), value: height)
                        }

                        // Tap gesture for empty slot
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: safeWidth, height: totalHeight)
                            .onTapGesture { location in
                                let tappedDate = yPositionToDate(y: location.y)
                                onEmptySlotClick(tappedDate)
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

    private func currentTimeIndicator(width: CGFloat) -> some View {
        let yPos = DateHelpers.timeToYPosition(date: Date(), totalHeight: totalHeight)
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
        let yPos = DateHelpers.timeToYPosition(date: Date(), totalHeight: totalHeight)
        let fraction = yPos / totalHeight
        return UnitPoint(x: 0, y: max(0, fraction - 0.2))
    }
}
