import Foundation
import SwiftData

class ProjectService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(name: String, colorHex: String) -> Project {
        let project = Project(name: name, colorHex: colorHex)
        modelContext.insert(project)
        try? modelContext.save()
        return project
    }

    func update(_ project: Project, name: String? = nil, colorHex: String? = nil) {
        if let name { project.name = name }
        if let colorHex { project.colorHex = colorHex }
        try? modelContext.save()
    }

    func delete(_ project: Project) {
        modelContext.delete(project)
        try? modelContext.save()
    }

    func fetchAll() -> [Project] {
        let descriptor = FetchDescriptor<Project>(
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
