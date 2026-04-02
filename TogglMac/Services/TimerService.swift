import Foundation
import SwiftData

class TimerService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var isRunning: Bool {
        currentTimer != nil
    }

    var currentTimer: TimerState? {
        let descriptor = FetchDescriptor<TimerState>()
        let results = try? modelContext.fetch(descriptor)
        return results?.first
    }

    var elapsedTime: TimeInterval {
        currentTimer?.elapsedTime ?? 0
    }

    func start(taskDescription: String = "", project: Project? = nil) {
        // Stop existing timer first (singleton enforcement)
        if isRunning {
            _ = stop()
        }
        let timerState = TimerState(
            startTime: Date(),
            taskDescription: taskDescription,
            project: project
        )
        modelContext.insert(timerState)
        try? modelContext.save()
    }

    @discardableResult
    func stop() -> TimeEntry? {
        guard let timer = currentTimer else { return nil }
        let entry = timer.toTimeEntry()
        modelContext.insert(entry)
        modelContext.delete(timer)
        try? modelContext.save()
        return entry
    }

    func restoreFromPersistence() {
        // TimerState persists across launches; currentTimer will return it automatically
        _ = isRunning
    }
}
