import XCTest
import SwiftData
@testable import TogglMac

@MainActor
final class ProjectServiceTests: XCTestCase {

    var container: ModelContainer!
    var service: ProjectService!

    override func setUpWithError() throws {
        container = try makeTestContainer()
        service = ProjectService(modelContext: container.mainContext)
    }

    override func tearDownWithError() throws {
        container = nil
        service = nil
    }

    func testCreateProject() throws {
        let project = service.create(name: "Work", colorHex: "FF6B6B")
        XCTAssertEqual(project.name, "Work")
        XCTAssertEqual(project.colorHex, "FF6B6B")
        XCTAssertNotNil(project.id)
    }

    func testUpdateProjectName() throws {
        let project = service.create(name: "Work", colorHex: "FF6B6B")
        service.update(project, name: "Personal")
        XCTAssertEqual(project.name, "Personal")
        XCTAssertEqual(project.colorHex, "FF6B6B")
    }

    func testUpdateProjectColor() throws {
        let project = service.create(name: "Work", colorHex: "FF6B6B")
        service.update(project, colorHex: "4ECDC4")
        XCTAssertEqual(project.name, "Work")
        XCTAssertEqual(project.colorHex, "4ECDC4")
    }

    func testDeleteProject() throws {
        let project = service.create(name: "Work", colorHex: "FF6B6B")
        let allBefore = service.fetchAll()
        XCTAssertEqual(allBefore.count, 1)

        service.delete(project)
        let allAfter = service.fetchAll()
        XCTAssertEqual(allAfter.count, 0)
    }

    func testListProjectsSortedByName() throws {
        _ = service.create(name: "Zebra", colorHex: "FF6B6B")
        _ = service.create(name: "Alpha", colorHex: "4ECDC4")
        _ = service.create(name: "Middle", colorHex: "45B7D1")

        let projects = service.fetchAll()
        XCTAssertEqual(projects.count, 3)
        XCTAssertEqual(projects[0].name, "Alpha")
        XCTAssertEqual(projects[1].name, "Middle")
        XCTAssertEqual(projects[2].name, "Zebra")
    }

    func testDeleteProjectCascadingNullifiesEntryProject() throws {
        let project = service.create(name: "Work", colorHex: "FF6B6B")
        let now = Date()
        let entry = TimeEntry(
            taskDescription: "Task",
            startTime: now,
            endTime: now.addingTimeInterval(3600),
            project: project
        )
        container.mainContext.insert(entry)
        try container.mainContext.save()

        XCTAssertNotNil(entry.project)

        service.delete(project)

        XCTAssertNil(entry.project)
    }
}
