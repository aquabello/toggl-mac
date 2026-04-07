import XCTest
import SwiftData
@testable import TogglMac

final class TimerStateTests: XCTestCase {

    func testCreation() {
        let timer = TimerState(taskDescription: "Working")

        XCTAssertEqual(timer.taskDescription, "Working")
        XCTAssertNotNil(timer.startTime)
        XCTAssertNil(timer.project)
    }

    func testElapsedTime() {
        let pastDate = Date(timeIntervalSinceNow: -60)
        let timer = TimerState(startTime: pastDate)

        XCTAssertGreaterThanOrEqual(timer.elapsedTime, 59)
        XCTAssertLessThan(timer.elapsedTime, 62)
    }

    func testToTimeEntry_withDescription() {
        let timer = TimerState(taskDescription: "My task")
        let entry = timer.toTimeEntry()

        XCTAssertEqual(entry.taskDescription, "My task")
        XCTAssertEqual(entry.startTime, timer.startTime)
        XCTAssertNotNil(entry.endTime)
        XCTAssertTrue(entry.isValid)
    }

    func testToTimeEntry_emptyDescription_usesDefault() {
        let timer = TimerState(taskDescription: "")
        let entry = timer.toTimeEntry()

        XCTAssertEqual(entry.taskDescription, AppConstants.defaultTaskDescription)
    }

    func testToTimeEntry_withProject() {
        let project = Project(name: "Work", colorHex: "FF0000")
        let timer = TimerState(taskDescription: "Task", project: project)
        let entry = timer.toTimeEntry()

        XCTAssertEqual(entry.project?.name, "Work")
    }
}
