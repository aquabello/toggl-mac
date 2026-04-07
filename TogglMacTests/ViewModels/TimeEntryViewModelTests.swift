import XCTest
import SwiftData
@testable import TogglMac

@MainActor
final class TimeEntryViewModelTests: XCTestCase {

    var container: ModelContainer!
    var viewModel: TimeEntryViewModel!
    var projectService: ProjectService!

    override func setUpWithError() throws {
        container = try makeTestContainer()
        viewModel = TimeEntryViewModel(modelContext: container.mainContext)
        projectService = ProjectService(modelContext: container.mainContext)
    }

    override func tearDownWithError() throws {
        container = nil
        viewModel = nil
        projectService = nil
    }

    private func makeEntry(description: String = "Task", project: Project? = nil) -> TimeEntry {
        let now = Date()
        let entry = TimeEntry(
            taskDescription: description,
            startTime: now,
            endTime: now.addingTimeInterval(3600),
            project: project
        )
        container.mainContext.insert(entry)
        try? container.mainContext.save()
        return entry
    }

    func testUpdateDescription() throws {
        let entry = makeEntry(description: "Original")
        viewModel.selectEntry(entry)

        viewModel.updateDescription("Updated")
        XCTAssertEqual(entry.taskDescription, "Updated")
    }

    func testUpdateProjectAssignment() throws {
        let entry = makeEntry()
        let project = projectService.create(name: "Work", colorHex: "FF6B6B")

        viewModel.selectEntry(entry)
        viewModel.updateProject(project)

        XCTAssertEqual(entry.project?.id, project.id)
    }

    func testSelectedEntryBinding() throws {
        XCTAssertNil(viewModel.selectedEntry)
        XCTAssertFalse(viewModel.isEditingEntry)

        let entry = makeEntry()
        viewModel.selectEntry(entry)

        XCTAssertEqual(viewModel.selectedEntry?.id, entry.id)
        XCTAssertTrue(viewModel.isEditingEntry)
    }

    func testDismissEditClearsSelection() throws {
        let entry = makeEntry()
        viewModel.selectEntry(entry)
        XCTAssertNotNil(viewModel.selectedEntry)

        viewModel.dismissEdit()
        XCTAssertNil(viewModel.selectedEntry)
        XCTAssertFalse(viewModel.isEditingEntry)
    }

    func testUpdateDescriptionWithNoSelectedEntryDoesNothing() throws {
        XCTAssertNil(viewModel.selectedEntry)
        // Should not crash
        viewModel.updateDescription("Test")
    }

    func testUpdateProjectWithNoSelectedEntryDoesNothing() throws {
        XCTAssertNil(viewModel.selectedEntry)
        let project = projectService.create(name: "Work", colorHex: "FF6B6B")
        // Should not crash
        viewModel.updateProject(project)
    }
}
