import Foundation
import SwiftData

class TimeEntryService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func updateDescription(_ entry: TimeEntry, description: String) {
        entry.taskDescription = description
        entry.updatedAt = Date()
        try? modelContext.save()
    }

    func assignProject(_ entry: TimeEntry, project: Project?) {
        entry.project = project
        entry.updatedAt = Date()
        try? modelContext.save()
    }

    func fetchByDateRange(start: Date, end: Date) -> [TimeEntry] {
        let descriptor = FetchDescriptor<TimeEntry>(
            predicate: #Predicate<TimeEntry> { entry in
                entry.startTime >= start && entry.startTime < end
            },
            sortBy: [SortDescriptor(\.startTime)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchByProject(_ project: Project) -> [TimeEntry] {
        let projectId = project.id
        let descriptor = FetchDescriptor<TimeEntry>(
            predicate: #Predicate<TimeEntry> { entry in
                entry.project?.id == projectId
            },
            sortBy: [SortDescriptor(\.startTime)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func delete(_ entry: TimeEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }

    func createManual(startTime: Date, endTime: Date, taskDescription: String, project: Project?) -> TimeEntry? {
        guard startTime < endTime else { return nil }
        let description = taskDescription.isEmpty ? AppConstants.defaultTaskDescription : taskDescription
        let entry = TimeEntry(
            taskDescription: description,
            startTime: startTime,
            endTime: endTime,
            project: project
        )
        modelContext.insert(entry)
        try? modelContext.save()
        return entry
    }

    func updateTime(_ entry: TimeEntry, startTime: Date, endTime: Date) {
        entry.startTime = startTime
        entry.endTime = endTime
        entry.updatedAt = Date()
        try? modelContext.save()
    }

    func moveEntry(_ entry: TimeEntry, newStartTime: Date) {
        let duration = entry.endTime.timeIntervalSince(entry.startTime)
        entry.startTime = newStartTime
        entry.endTime = newStartTime.addingTimeInterval(duration)
        entry.updatedAt = Date()
        try? modelContext.save()
    }

    func detectOverlaps(start: Date, end: Date) -> [TimeEntry] {
        let descriptor = FetchDescriptor<TimeEntry>(
            predicate: #Predicate<TimeEntry> { entry in
                entry.startTime < end && entry.endTime > start
            }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
