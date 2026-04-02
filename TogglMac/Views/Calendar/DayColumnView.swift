import SwiftUI

struct DayColumnView: View {
    let date: Date
    let entries: [TimeEntry]
    let onEntryTap: (TimeEntry) -> Void
    let onEmptySlotClick: (Date) -> Void

    private let totalHeight = AppConstants.Calendar.totalDayHeight
    private let hourHeight = AppConstants.Calendar.hourHeight
    private let timeLabelWidth: CGFloat = 50

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    ZStack(alignment: .topLeading) {
                        // Background grid + hour labels
                        VStack(spacing: 0) {
                            ForEach(0..<AppConstants.Calendar.hoursInDay, id: \.self) { hour in
                                HStack(alignment: .top, spacing: 0) {
                                    Text(String(format: "%02d:00", hour))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .frame(width: timeLabelWidth, alignment: .trailing)
                                        .padding(.trailing, 4)

                                    Rectangle()
                                        .fill(Color.gray.opacity(0.15))
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 8)
                                }
                                .frame(height: hourHeight)
                            }
                        }
                        .frame(width: geometry.size.width)

                        // Current time indicator
                        if DateHelpers.isToday(date) {
                            currentTimeIndicator(width: geometry.size.width)
                        }

                        // Time blocks
                        ForEach(entries) { entry in
                            TimeBlockView(
                                entry: entry,
                                totalHeight: totalHeight,
                                onTap: { onEntryTap(entry) }
                            )
                            .padding(.leading, timeLabelWidth)
                            .padding(.trailing, 2)
                            .frame(width: geometry.size.width - timeLabelWidth - 2, alignment: .leading)
                        }

                        // Tap gesture for empty slot
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: geometry.size.width, height: totalHeight)
                            .onTapGesture { location in
                                let tappedDate = yPositionToDate(y: location.y)
                                onEmptySlotClick(tappedDate)
                            }
                    }
                    .frame(height: totalHeight)
                    .id("content")
                }
                .onAppear {
                    // Scroll to current hour on appear
                    proxy.scrollTo("content", anchor: currentScrollAnchor())
                }
            }
        }
    }

    private func currentTimeIndicator(width: CGFloat) -> some View {
        let yPos = DateHelpers.timeToYPosition(date: Date(), totalHeight: totalHeight)
        return Rectangle()
            .fill(Color.red)
            .frame(height: 2)
            .frame(width: width - timeLabelWidth)
            .padding(.leading, timeLabelWidth)
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
