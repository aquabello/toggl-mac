import Foundation
import SwiftData

class UndoService {
    private let modelContext: ModelContext
    private var lastDeletedData: (taskDescription: String, startTime: Date, endTime: Date, projectId: UUID?)?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func deleteEntry(_ entry: TimeEntry) {
        // Store data for undo before deleting
        lastDeletedData = (
            taskDescription: entry.taskDescription,
            startTime: entry.startTime,
            endTime: entry.endTime,
            projectId: entry.project?.id
        )
        modelContext.delete(entry)
        try? modelContext.save()
    }

    @discardableResult
    func undo() -> TimeEntry? {
        guard let data = lastDeletedData else { return nil }

        // Find the project if it still exists
        var project: Project?
        if let projectId = data.projectId {
            let descriptor = FetchDescriptor<Project>(
                predicate: #Predicate<Project> { p in p.id == projectId }
            )
            project = try? modelContext.fetch(descriptor).first
        }

        let restored = TimeEntry(
            taskDescription: data.taskDescription,
            startTime: data.startTime,
            endTime: data.endTime,
            project: project
        )
        modelContext.insert(restored)
        try? modelContext.save()
        lastDeletedData = nil
        return restored
    }

    var canUndo: Bool {
        lastDeletedData != nil
    }
}
