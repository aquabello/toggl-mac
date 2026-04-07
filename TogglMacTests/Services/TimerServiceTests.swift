import XCTest
import SwiftData
@testable import TogglMac

final class TimerServiceTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var service: TimerService!

    override func setUpWithError() throws {
        container = try makeTestContainer()
        context = ModelContext(container)
        service = TimerService(modelContext: context)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
        service = nil
    }

    func testStartCreatesTimerState() throws {
        XCTAssertFalse(service.isRunning)
        service.start(taskDescription: "Test task")
        XCTAssertTrue(service.isRunning)
        XCTAssertNotNil(service.currentTimer)
        XCTAssertEqual(service.currentTimer?.taskDescription, "Test task")
    }

    func testStopCreatesTimeEntryAndDeletesTimerState() throws {
        service.start(taskDescription: "Task to stop")
        XCTAssertTrue(service.isRunning)

        let entry = service.stop()

        XCTAssertNotNil(entry)
        XCTAssertFalse(service.isRunning)
        XCTAssertNil(service.currentTimer)

        let descriptor = FetchDescriptor<TimeEntry>()
        let entries = try context.fetch(descriptor)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.taskDescription, "Task to stop")
    }

    func testIsRunningReturnsTrueWhenTimerStateExists() throws {
        XCTAssertFalse(service.isRunning)
        service.start()
        XCTAssertTrue(service.isRunning)
    }

    func testIsRunningReturnsFalseWhenNoTimerState() throws {
        XCTAssertFalse(service.isRunning)
    }

    func testElapsedTimeReturnTimeSinceStart() throws {
        service.start()
        // elapsedTime should be very small (just started)
        XCTAssertGreaterThanOrEqual(service.elapsedTime, 0)
        XCTAssertLessThan(service.elapsedTime, 2.0)
    }

    func testStartWhenAlreadyRunningStopsCurrentTimerFirst() throws {
        service.start(taskDescription: "First task")
        XCTAssertEqual(service.currentTimer?.taskDescription, "First task")

        service.start(taskDescription: "Second task")
        XCTAssertTrue(service.isRunning)
        XCTAssertEqual(service.currentTimer?.taskDescription, "Second task")

        // First task should have been saved as TimeEntry
        let descriptor = FetchDescriptor<TimeEntry>()
        let entries = try context.fetch(descriptor)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.taskDescription, "First task")
    }

    func testStopWhenNotRunningDoesNothing() throws {
        XCTAssertFalse(service.isRunning)
        let entry = service.stop()
        XCTAssertNil(entry)
        XCTAssertFalse(service.isRunning)
    }
}
