import XCTest
import SwiftData
@testable import TogglMac

final class TimeEntryTests: XCTestCase {

    func testCreation() {
        let start = Date()
        let end = Date(timeIntervalSinceNow: 3600)
        let entry = TimeEntry(
            taskDescription: "Test task",
            startTime: start,
            endTime: end
        )

        XCTAssertEqual(entry.taskDescription, "Test task")
        XCTAssertEqual(entry.startTime, start)
        XCTAssertEqual(entry.endTime, end)
        XCTAssertNil(entry.project)
        XCTAssertNotNil(entry.id)
    }

    func testDefaultDescription() {
        let entry = TimeEntry(
            startTime: Date(),
            endTime: Date(timeIntervalSinceNow: 60)
        )
        XCTAssertEqual(entry.taskDescription, AppConstants.defaultTaskDescription)
    }

    func testDurationComputed() {
        let start = Date()
        let end = Date(timeInterval: 3600, since: start)
        let entry = TimeEntry(startTime: start, endTime: end)

        XCTAssertEqual(entry.duration, 3600, accuracy: 0.1)
    }

    func testValidation_validEntry() {
        let entry = TimeEntry(
            startTime: Date(),
            endTime: Date(timeIntervalSinceNow: 60)
        )
        XCTAssertTrue(entry.isValid)
    }

    func testValidation_invalidEntry_startAfterEnd() {
        let entry = TimeEntry(
            startTime: Date(timeIntervalSinceNow: 3600),
            endTime: Date()
        )
        XCTAssertFalse(entry.isValid)
    }

    func testValidation_invalidEntry_sameStartAndEnd() {
        let now = Date()
        let entry = TimeEntry(startTime: now, endTime: now)
        XCTAssertFalse(entry.isValid)
    }
}
