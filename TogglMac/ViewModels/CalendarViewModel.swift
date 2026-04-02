import SwiftUI
import SwiftData

enum CalendarViewMode {
    case day
    case week
}

@Observable
class CalendarViewModel {
    var selectedDate: Date = Date()
    var viewMode: CalendarViewMode = .week

    private let timeEntryService: TimeEntryService

    init(modelContext: ModelContext) {
        self.timeEntryService = TimeEntryService(modelContext: modelContext)
    }

    var currentDateRange: (start: Date, end: Date) {
        switch viewMode {
        case .day:
            return (DateHelpers.dayStart(for: selectedDate), DateHelpers.dayEnd(for: selectedDate))
        case .week:
            return (DateHelpers.weekStart(for: selectedDate), DateHelpers.weekEnd(for: selectedDate))
        }
    }

    var currentEntries: [TimeEntry] {
        let range = currentDateRange
        return timeEntryService.fetchByDateRange(start: range.start, end: range.end)
    }

    var weekDays: [Date] {
        DateHelpers.daysInWeek(from: DateHelpers.weekStart(for: selectedDate))
    }

    func entriesForDay(_ date: Date) -> [TimeEntry] {
        let start = DateHelpers.dayStart(for: date)
        let end = DateHelpers.dayEnd(for: date)
        return timeEntryService.fetchByDateRange(start: start, end: end)
    }

    func navigateForward() {
        switch viewMode {
        case .day:
            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        case .week:
            selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate) ?? selectedDate
        }
    }

    func navigateBack() {
        switch viewMode {
        case .day:
            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        case .week:
            selectedDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate) ?? selectedDate
        }
    }

    func goToToday() {
        selectedDate = Date()
    }

    func switchToDay() {
        viewMode = .day
    }

    func switchToWeek() {
        viewMode = .week
    }
}
