import Foundation
import SwiftData

@Model
final class TimerState {
    var id: UUID
    var startTime: Date
    var taskDescription: String
    var createdAt: Date

    @Relationship
    var project: Project?

    var elapsedTime: TimeInterval {
        Date().timeIntervalSince(startTime)
    }

    init(
        startTime: Date = Date(),
        taskDescription: String = "",
        project: Project? = nil
    ) {
        self.id = UUID()
        self.startTime = startTime
        self.taskDescription = taskDescription
        self.project = project
        self.createdAt = Date()
    }

    func toTimeEntry() -> TimeEntry {
        let description = taskDescription.isEmpty
            ? AppConstants.defaultTaskDescription
            : taskDescription
        return TimeEntry(
            taskDescription: description,
            startTime: startTime,
            endTime: Date(),
            project: project
        )
    }
}
