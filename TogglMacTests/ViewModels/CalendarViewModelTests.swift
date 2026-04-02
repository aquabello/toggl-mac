import XCTest
import SwiftData
@testable import TogglMac

@MainActor
final class CalendarViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var viewModel: CalendarViewModel!

    override func setUpWithError() throws {
        container = try makeTestContainer()
        context = ModelContext(container)
        viewModel = CalendarViewModel(modelContext: context)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        context = nil
        container = nil
    }

    func testInitialSelectedDateIsToday() {
        let today = Calendar.current.startOfDay(for: Date())
        let vmDay = Calendar.current.startOfDay(for: viewModel.selectedDate)
        XCTAssertEqual(today, vmDay)
    }

    func testInitialViewModeIsWeek() {
        XCTAssertEqual(viewModel.viewMode, .week)
    }

    func testNavigateForwardInDayModeAdvancesOneDay() {
        viewModel.switchToDay()
        let before = viewModel.selectedDate
        viewModel.navigateForward()
        let after = viewModel.selectedDate
        let diff = Calendar.current.dateComponents([.day], from: before, to: after).day ?? 0
        XCTAssertEqual(diff, 1)
    }

    func testNavigateBackInDayModeGoesBackOneDay() {
        viewModel.switchToDay()
        let before = viewModel.selectedDate
        viewModel.navigateBack()
        let after = viewModel.selectedDate
        let diff = Calendar.current.dateComponents([.day], from: after, to: before).day ?? 0
        XCTAssertEqual(diff, 1)
    }

    func testNavigateForwardInWeekModeAdvancesSevenDays() {
        viewModel.switchToWeek()
        let before = viewModel.selectedDate
        viewModel.navigateForward()
        let after = viewModel.selectedDate
        let diff = Calendar.current.dateComponents([.day], from: before, to: after).day ?? 0
        XCTAssertEqual(diff, 7)
    }

    func testNavigateBackInWeekModeGoesBackSevenDays() {
        viewModel.switchToWeek()
        let before = viewModel.selectedDate
        viewModel.navigateBack()
        let after = viewModel.selectedDate
        let diff = Calendar.current.dateComponents([.day], from: after, to: before).day ?? 0
        XCTAssertEqual(diff, 7)
    }

    func testGoToTodayResetsSelectedDate() {
        viewModel.navigateForward()
        viewModel.navigateForward()
        viewModel.goToToday()
        let today = Calendar.current.startOfDay(for: Date())
        let vmDay = Calendar.current.startOfDay(for: viewModel.selectedDate)
        XCTAssertEqual(today, vmDay)
    }

    func testSwitchToDayChangesViewMode() {
        viewModel.switchToDay()
        XCTAssertEqual(viewModel.viewMode, .day)
    }

    func testSwitchToWeekChangesViewMode() {
        viewModel.switchToDay()
        viewModel.switchToWeek()
        XCTAssertEqual(viewModel.viewMode, .week)
    }

    func testEntriesForDateRangeReturnsCorrectEntries() throws {
        let today = Date()

        // Entry within today
        let entryInRange = TimeEntry(
            taskDescription: "In range",
            startTime: today,
            endTime: today.addingTimeInterval(3600)
        )
        context.insert(entryInRange)

        // Entry outside today (yesterday)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let entryOutOfRange = TimeEntry(
            taskDescription: "Out of range",
            startTime: yesterday,
            endTime: yesterday.addingTimeInterval(3600)
        )
        context.insert(entryOutOfRange)
        try context.save()

        viewModel.switchToDay()
        viewModel.selectedDate = today
        let entries = viewModel.currentEntries
        XCTAssertTrue(entries.contains(where: { $0.taskDescription == "In range" }))
        XCTAssertFalse(entries.contains(where: { $0.taskDescription == "Out of range" }))
    }
}
