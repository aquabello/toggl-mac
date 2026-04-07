import Foundation
import SwiftData

@Model
final class TimeEntry {
    var id: UUID
    var taskDescription: String
    var startTime: Date
    var endTime: Date
    var createdAt: Date
    var updatedAt: Date

    @Relationship(inverse: \Project.timeEntries)
    var project: Project?

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    init(
        taskDescription: String = AppConstants.defaultTaskDescription,
        startTime: Date,
        endTime: Date,
        project: Project? = nil
    ) {
        self.id = UUID()
        self.taskDescription = taskDescription
        self.startTime = startTime
        self.endTime = endTime
        self.project = project
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var isValid: Bool {
        startTime < endTime
    }
}
