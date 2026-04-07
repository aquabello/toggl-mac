import SwiftUI

struct CalendarContainerView: View {
    var calendarViewModel: CalendarViewModel
    var activeTimerStart: Date?
    var activeTimerProject: Project?
    var activeTimerDescription: String?
    let onEntryTap: (TimeEntry) -> Void
    let onEntryDelete: ((TimeEntry) -> Void)?
    let onEntryMove: ((TimeEntry, Date) -> Void)?
    let onActiveTimerTap: (() -> Void)?
    let onEmptySlotClick: (Date) -> Void

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Rectangle()
                .fill(TogglTheme.divider)
                .frame(height: 1)

            switch calendarViewModel.viewMode {
            case .week:
                weekView
            case .day:
                dayView
            }
        }
        .background(TogglTheme.backgroundSecondary)
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: 0) {
            // Left side: navigation
            HStack(spacing: 8) {
                // Navigation arrows
                Button(action: { calendarViewModel.navigateBack() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(TogglTheme.textSecondary)
                }
                .buttonStyle(.plain)

                // Week label
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundStyle(TogglTheme.textTertiary)
                    Text(weekLabel)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(TogglTheme.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(TogglTheme.surfaceCard)
                .cornerRadius(6)

                Button(action: { calendarViewModel.navigateForward() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(TogglTheme.textSecondary)
                }
                .buttonStyle(.plain)

                // Week total
                HStack(spacing: 4) {
                    Text("WEEK TOTAL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(TogglTheme.textTertiary)
                        .tracking(0.5)
                    Text(weekTotalText)
                        .font(.system(size: 13, weight: .semibold).monospacedDigit())
                        .foregroundStyle(TogglTheme.textPrimary)
                }
                .padding(.leading, 12)
            }

            Spacer()

            // Right side: view mode + settings
            HStack(spacing: 8) {
                // View mode picker
                HStack(spacing: 4) {
                    Text("Week view")
                        .font(.system(size: 12))
                        .foregroundStyle(TogglTheme.textSecondary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9))
                        .foregroundStyle(TogglTheme.textTertiary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(TogglTheme.surfaceCard)
                .cornerRadius(6)

                // View tabs
                HStack(spacing: 0) {
                    viewTab("Calendar", isActive: true)
                    viewTab("List view", isActive: false)
                    viewTab("Timesheet", isActive: false)
                }
                .background(TogglTheme.surfaceCard)
                .cornerRadius(6)

                // Settings icon
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                        .foregroundStyle(TogglTheme.textTertiary)
                }
                .buttonStyle(.plain)

                // Compact/expand toggle
                Button(action: {}) {
                    Image(systemName: "rectangle.split.2x1")
                        .font(.system(size: 12))
                        .foregroundStyle(TogglTheme.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(TogglTheme.calendarHeaderBg)
    }

    private func viewTab(_ title: String, isActive: Bool) -> some View {
        Text(title)
            .font(.system(size: 12, weight: isActive ? .semibold : .regular))
            .foregroundStyle(isActive ? TogglTheme.textPrimary : TogglTheme.textTertiary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? TogglTheme.accentPink.opacity(0.2) : Color.clear)
            .cornerRadius(5)
    }

    // MARK: - Week View

    private var weekView: some View {
        let days = calendarViewModel.weekDays
        let dailyTotals = computeDailyTotals(for: days)

        return VStack(spacing: 0) {
            // Project label bar
            HStack {
                Text("(NO PROJECT)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(TogglTheme.textTertiary)
                    .tracking(0.5)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(TogglTheme.backgroundPrimary.opacity(0.5))

            WeekHeaderView(days: days, dailyTotals: dailyTotals)
            Rectangle()
                .fill(TogglTheme.divider)
                .frame(height: 1)

            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    DayColumnView(
                        date: day,
                        entries: calendarViewModel.entriesForDay(day),
                        activeTimerStart: activeTimerStart,
                        activeTimerProject: activeTimerProject,
                        activeTimerDescription: activeTimerDescription,
                        onEntryTap: onEntryTap,
                        onEntryDelete: onEntryDelete,
                        onEntryMove: onEntryMove,
                        onActiveTimerTap: onActiveTimerTap,
                        onEmptySlotClick: onEmptySlotClick
                    )
                    if day != days.last {
                        Rectangle()
                            .fill(TogglTheme.gridLine)
                            .frame(width: 1)
                    }
                }
            }
        }
    }

    // MARK: - Day View

    private var dayView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("(NO PROJECT)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(TogglTheme.textTertiary)
                    .tracking(0.5)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(TogglTheme.backgroundPrimary.opacity(0.5))

            DayColumnView(
                date: calendarViewModel.selectedDate,
                entries: calendarViewModel.currentEntries,
                activeTimerStart: activeTimerStart,
                activeTimerProject: activeTimerProject,
                activeTimerDescription: activeTimerDescription,
                onEntryTap: onEntryTap,
                onEntryDelete: onEntryDelete,
                onEntryMove: onEntryMove,
                onActiveTimerTap: onActiveTimerTap,
                onEmptySlotClick: onEmptySlotClick
            )
        }
    }

    // MARK: - Helpers

    private var weekLabel: String {
        let range = calendarViewModel.currentDateRange
        let calendar = Calendar.current
        let weekNum = calendar.component(.weekOfYear, from: range.start)
        return "This week \u{00B7} W\(weekNum)"
    }

    private var weekTotalText: String {
        let days = calendarViewModel.weekDays
        let total = days.reduce(0.0) { sum, day in
            sum + calendarViewModel.entriesForDay(day).reduce(0) { $0 + $1.duration }
        }
        return DateHelpers.formattedElapsedTime(total)
    }

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
