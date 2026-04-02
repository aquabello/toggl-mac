import SwiftUI

struct CalendarContainerView: View {
    var calendarViewModel: CalendarViewModel
    let onEntryTap: (TimeEntry) -> Void
    let onEmptySlotClick: (Date) -> Void

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()

            switch calendarViewModel.viewMode {
            case .week:
                weekView
            case .day:
                dayView
            }
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: 12) {
            // Day/Week toggle
            Picker("", selection: Binding(
                get: { calendarViewModel.viewMode },
                set: { newMode in
                    if newMode == .day {
                        calendarViewModel.switchToDay()
                    } else {
                        calendarViewModel.switchToWeek()
                    }
                }
            )) {
                Text("일").tag(CalendarViewMode.day)
                Text("주").tag(CalendarViewMode.week)
            }
            .pickerStyle(.segmented)
            .frame(width: 100)

            // Today button
            Button("오늘") {
                calendarViewModel.goToToday()
            }

            // Navigation
            HStack(spacing: 4) {
                Button(action: { calendarViewModel.navigateBack() }) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)

                Button(action: { calendarViewModel.navigateForward() }) {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
            }

            // Date range display
            Text(dateRangeText)
                .font(.headline)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Week View

    private var weekView: some View {
        let days = calendarViewModel.weekDays
        let dailyTotals = computeDailyTotals(for: days)

        return VStack(spacing: 0) {
            WeekHeaderView(days: days, dailyTotals: dailyTotals)
            Divider()
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    DayColumnView(
                        date: day,
                        entries: calendarViewModel.entriesForDay(day),
                        onEntryTap: onEntryTap,
                        onEmptySlotClick: onEmptySlotClick
                    )
                    if day != days.last {
                        Divider()
                    }
                }
            }
        }
    }

    // MARK: - Day View

    private var dayView: some View {
        DayColumnView(
            date: calendarViewModel.selectedDate,
            entries: calendarViewModel.currentEntries,
            onEntryTap: onEntryTap,
            onEmptySlotClick: onEmptySlotClick
        )
    }

    // MARK: - Helpers

    private var dateRangeText: String {
        let formatter = DateFormatter()
        switch calendarViewModel.viewMode {
        case .day:
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter.string(from: calendarViewModel.selectedDate)
        case .week:
            let range = calendarViewModel.currentDateRange
            formatter.dateFormat = "M/d"
            let startStr = formatter.string(from: range.start)
            let endDate = Calendar.current.date(byAdding: .day, value: -1, to: range.end) ?? range.end
            let endStr = formatter.string(from: endDate)
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            return "\(yearFormatter.string(from: range.start)) \(startStr) - \(endStr)"
        }
    }

    private func computeDailyTotals(for days: [Date]) -> [Date: TimeInterval] {
        var totals: [Date: TimeInterval] = [:]
        for day in days {
            let dayStart = DateHelpers.dayStart(for: day)
            let entries = calendarViewModel.entriesForDay(day)
            totals[dayStart] = entries.reduce(0) { $0 + $1.duration }
        }
        return totals
    }
}
