import XCTest
import SwiftData
@testable import TogglMac

@MainActor
final class ProjectViewModelTests: XCTestCase {

    var container: ModelContainer!
    var viewModel: ProjectViewModel!

    override func setUpWithError() throws {
        container = try makeTestContainer()
        viewModel = ProjectViewModel(modelContext: container.mainContext)
    }

    override func tearDownWithError() throws {
        container = nil
        viewModel = nil
    }

    func testCreateProject() throws {
        viewModel.createProject(name: "Work", colorHex: "FF6B6B")
        XCTAssertEqual(viewModel.projects.count, 1)
        XCTAssertEqual(viewModel.projects[0].name, "Work")
        XCTAssertEqual(viewModel.projects[0].colorHex, "FF6B6B")
    }

    func testEditProjectName() throws {
        viewModel.createProject(name: "Work", colorHex: "FF6B6B")
        let project = viewModel.projects[0]

        viewModel.updateProject(project, name: "Personal")
        XCTAssertEqual(viewModel.projects[0].name, "Personal")
    }

    func testEditProjectColor() throws {
        viewModel.createProject(name: "Work", colorHex: "FF6B6B")
        let project = viewModel.projects[0]

        viewModel.updateProject(project, colorHex: "4ECDC4")
        XCTAssertEqual(viewModel.projects[0].colorHex, "4ECDC4")
    }

    func testDeleteProject() throws {
        viewModel.createProject(name: "Work", colorHex: "FF6B6B")
        XCTAssertEqual(viewModel.projects.count, 1)

        let project = viewModel.projects[0]
        viewModel.deleteProject(project)
        XCTAssertEqual(viewModel.projects.count, 0)
    }

    func testProjectsListBinding() throws {
        XCTAssertEqual(viewModel.projects.count, 0)

        viewModel.createProject(name: "Alpha", colorHex: "FF6B6B")
        viewModel.createProject(name: "Beta", colorHex: "4ECDC4")

        XCTAssertEqual(viewModel.projects.count, 2)
        XCTAssertEqual(viewModel.projects[0].name, "Alpha")
        XCTAssertEqual(viewModel.projects[1].name, "Beta")
    }

    func testDeleteProjectClearsSelectedProject() throws {
        viewModel.createProject(name: "Work", colorHex: "FF6B6B")
        let project = viewModel.projects[0]
        viewModel.selectedProject = project

        viewModel.deleteProject(project)
        XCTAssertNil(viewModel.selectedProject)
    }
}
