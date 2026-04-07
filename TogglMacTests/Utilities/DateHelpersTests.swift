import XCTest
@testable import TogglMac

final class DateHelpersTests: XCTestCase {

    func testDayStart() {
        let date = Date()
        let start = DateHelpers.dayStart(for: date)
        let components = Foundation.Calendar.current.dateComponents([.hour, .minute, .second], from: start)

        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testDayEnd_isNextDayStart() {
        let date = Date()
        let start = DateHelpers.dayStart(for: date)
        let end = DateHelpers.dayEnd(for: date)
        let diff = end.timeIntervalSince(start)

        XCTAssertEqual(diff, 86400, accuracy: 1)
    }

    func testWeekStart_isMonday() {
        let date = Date()
        let weekStart = DateHelpers.weekStart(for: date)
        var cal = Foundation.Calendar.current
        cal.firstWeekday = 2
        let weekday = cal.component(.weekday, from: weekStart)

        XCTAssertEqual(weekday, 2, "Week should start on Monday")
    }

    func testWeekEnd_is7DaysAfterStart() {
        let date = Date()
        let start = DateHelpers.weekStart(for: date)
        let end = DateHelpers.weekEnd(for: date)
        let diff = end.timeIntervalSince(start)

        XCTAssertEqual(diff, 7 * 86400, accuracy: 1)
    }

    func testFormattedElapsedTime() {
        XCTAssertEqual(DateHelpers.formattedElapsedTime(0), "0:00:00")
        XCTAssertEqual(DateHelpers.formattedElapsedTime(61), "0:01:01")
        XCTAssertEqual(DateHelpers.formattedElapsedTime(3661), "1:01:01")
        XCTAssertEqual(DateHelpers.formattedElapsedTime(36000), "10:00:00")
    }

    func testTimeToYPosition() {
        let totalHeight: CGFloat = 1440

        // Midnight = top (0)
        var components = Foundation.Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 0
        components.minute = 0
        let midnight = Foundation.Calendar.current.date(from: components)!
        XCTAssertEqual(DateHelpers.timeToYPosition(date: midnight, totalHeight: totalHeight), 0, accuracy: 1)

        // Noon = middle
        components.hour = 12
        components.minute = 0
        let noon = Foundation.Calendar.current.date(from: components)!
        XCTAssertEqual(DateHelpers.timeToYPosition(date: noon, totalHeight: totalHeight), 720, accuracy: 1)
    }

    func testDurationToHeight() {
        let totalHeight: CGFloat = 1440
        let oneHour: TimeInterval = 3600
        let expectedHeight: CGFloat = 60

        XCTAssertEqual(DateHelpers.durationToHeight(duration: oneHour, totalHeight: totalHeight), expectedHeight, accuracy: 0.1)
    }

    func testDaysInWeek_returns7Days() {
        let weekStart = DateHelpers.weekStart(for: Date())
        let days = DateHelpers.daysInWeek(from: weekStart)

        XCTAssertEqual(days.count, 7)
    }

    func testIsToday() {
        XCTAssertTrue(DateHelpers.isToday(Date()))

        let yesterday = Foundation.Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertFalse(DateHelpers.isToday(yesterday))
    }
}
