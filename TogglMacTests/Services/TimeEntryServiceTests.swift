import XCTest
import SwiftData
@testable import TogglMac

@MainActor
final class TimeEntryServiceTests: XCTestCase {

    var container: ModelContainer!
    var service: TimeEntryService!
    var projectService: ProjectService!

    override func setUpWithError() throws {
        container = try makeTestContainer()
        service = TimeEntryService(modelContext: container.mainContext)
        projectService = ProjectService(modelContext: container.mainContext)
    }

    override func tearDownWithError() throws {
        container = nil
        service = nil
        projectService = nil
    }

    private func makeEntry(description: String = "Task", offset: TimeInterval = 0, project: Project? = nil) -> TimeEntry {
        let start = Date().addingTimeInterval(offset)
        let end = start.addingTimeInterval(3600)
        let entry = TimeEntry(taskDescription: description, startTime: start, endTime: end, project: project)
        container.mainContext.insert(entry)
        try? container.mainContext.save()
        return entry
    }

    func testUpdateTaskDescription() throws {
        let entry = makeEntry(description: "Original")
        service.updateDescription(entry, description: "Updated")
        XCTAssertEqual(entry.taskDescription, "Updated")
    }

    func testAssignProjectToEntry() throws {
        let entry = makeEntry()
        let project = projectService.create(name: "Work", colorHex: "FF6B6B")
        service.assignProject(entry, project: project)
        XCTAssertEqual(entry.project?.id, project.id)
    }

    func testChangeProjectOnEntry() throws {
        let project1 = projectService.create(name: "Work", colorHex: "FF6B6B")
        let project2 = projectService.create(name: "Personal", colorHex: "4ECDC4")
        let entry = makeEntry(project: project1)

        service.assignProject(entry, project: project2)
        XCTAssertEqual(entry.project?.id, project2.id)
    }

    func testRemoveProjectFromEntry() throws {
        let project = projectService.create(name: "Work", colorHex: "FF6B6B")
        let entry = makeEntry(project: project)
        XCTAssertNotNil(entry.project)

        service.assignProject(entry, project: nil)
        XCTAssertNil(entry.project)
    }

    func testFetchByDateRangeReturnsCorrectEntries() throws {
        let base = Date()
        let start = base.addingTimeInterval(-7200) // 2h ago
        let end = base.addingTimeInterval(7200)    // 2h from now

        let inRange = makeEntry(description: "In Range", offset: -3600) // 1h ago
        _ = makeEntry(description: "Out Range", offset: -10800)          // 3h ago

        let results = service.fetchByDateRange(start: start, end: end)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].id, inRange.id)
    }

    func testFetchByDateRangeExcludesOutOfRangeEntries() throws {
        let base = Date()
        let start = base.addingTimeInterval(-3600)
        let end = base

        _ = makeEntry(description: "Before Range", offset: -7200)
        _ = makeEntry(description: "After Range", offset: 3600)

        let results = service.fetchByDateRange(start: start, end: end)
        XCTAssertEqual(results.count, 0)
    }

    func testCreateManualWithValidTimesCreatesEntry() throws {
        let start = Date()
        let end = start.addingTimeInterval(3600)
        let entry = service.createManual(startTime: start, endTime: end, taskDescription: "Manual Task", project: nil)
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.taskDescription, "Manual Task")
        XCTAssertEqual(entry?.startTime, start)
        XCTAssertEqual(entry?.endTime, end)
    }

    func testCreateManualWithInvalidTimesReturnsNil() throws {
        let start = Date()
        let end = start.addingTimeInterval(-1) // end before start
        let entry = service.createManual(startTime: start, endTime: end, taskDescription: "Bad Entry", project: nil)
        XCTAssertNil(entry)
    }

    func testCreateManualWithEqualTimesReturnsNil() throws {
        let start = Date()
        let entry = service.createManual(startTime: start, endTime: start, taskDescription: "Same Time", project: nil)
        XCTAssertNil(entry)
    }

    func testDetectOverlapsFindsOverlappingEntries() throws {
        let base = Date()
        let entryStart = base
        let entryEnd = base.addingTimeInterval(3600)
        let existing = TimeEntry(taskDescription: "Existing", startTime: entryStart, endTime: entryEnd)
        container.mainContext.insert(existing)
        try container.mainContext.save()

        // Query overlaps a window inside the existing entry
        let overlaps = service.detectOverlaps(start: base.addingTimeInterval(900), end: base.addingTimeInterval(1800))
        XCTAssertEqual(overlaps.count, 1)
        XCTAssertEqual(overlaps[0].id, existing.id)
    }

    func testDetectOverlapsReturnsEmptyWhenNoOverlaps() throws {
        let base = Date()
        let existing = TimeEntry(taskDescription: "Existing", startTime: base, endTime: base.addingTimeInterval(3600))
        container.mainContext.insert(existing)
        try container.mainContext.save()

        // Query window after existing entry
        let overlaps = service.detectOverlaps(start: base.addingTimeInterval(7200), end: base.addingTimeInterval(10800))
        XCTAssertEqual(overlaps.count, 0)
    }
}
