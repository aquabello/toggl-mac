import XCTest
import SwiftData
@testable import TogglMac

@MainActor
final class UndoServiceTests: XCTestCase {

    var container: ModelContainer!
    var service: UndoService!

    override func setUpWithError() throws {
        container = try makeTestContainer()
        service = UndoService(modelContext: container.mainContext)
    }

    override func tearDownWithError() throws {
        container = nil
        service = nil
    }

    private func makeEntry(description: String = "Task") -> TimeEntry {
        let start = Date()
        let end = start.addingTimeInterval(3600)
        let entry = TimeEntry(taskDescription: description, startTime: start, endTime: end)
        container.mainContext.insert(entry)
        try? container.mainContext.save()
        return entry
    }

    func testDeleteStoresEntryForUndo() throws {
        let entry = makeEntry(description: "To Delete")
        XCTAssertFalse(service.canUndo)

        service.deleteEntry(entry)

        XCTAssertTrue(service.canUndo)
    }

    func testUndoRestoresDeletedEntry() throws {
        let entry = makeEntry(description: "Restore Me")
        let startTime = entry.startTime
        let endTime = entry.endTime

        service.deleteEntry(entry)
        XCTAssertTrue(service.canUndo)

        let restored = service.undo()

        XCTAssertNotNil(restored)
        XCTAssertEqual(restored?.taskDescription, "Restore Me")
        XCTAssertEqual(restored?.startTime, startTime)
        XCTAssertEqual(restored?.endTime, endTime)
        XCTAssertFalse(service.canUndo)
    }

    func testUndoWhenNothingToUndoDoesNothing() throws {
        XCTAssertFalse(service.canUndo)
        let result = service.undo()
        XCTAssertNil(result)
    }
}
