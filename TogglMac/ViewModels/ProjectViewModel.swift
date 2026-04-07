import SwiftUI
import SwiftData

@Observable
class ProjectViewModel {
    var projects: [Project] = []
    var selectedProject: Project?

    private let projectService: ProjectService

    init(modelContext: ModelContext) {
        self.projectService = ProjectService(modelContext: modelContext)
        refresh()
    }

    func createProject(name: String, colorHex: String) {
        _ = projectService.create(name: name, colorHex: colorHex)
        refresh()
    }

    func updateProject(_ project: Project, name: String? = nil, colorHex: String? = nil) {
        projectService.update(project, name: name, colorHex: colorHex)
        refresh()
    }

    func deleteProject(_ project: Project) {
        if selectedProject?.id == project.id {
            selectedProject = nil
        }
        projectService.delete(project)
        refresh()
    }

    func refresh() {
        projects = projectService.fetchAll()
    }
}
