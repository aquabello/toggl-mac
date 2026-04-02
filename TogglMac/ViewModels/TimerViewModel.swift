import SwiftUI
import SwiftData
import Combine

@Observable
class TimerViewModel {
    var isRunning: Bool = false
    var elapsedTime: TimeInterval = 0
    var taskDescription: String = ""
    var selectedProject: Project?

    private var timerService: TimerService
    private var displayTimer: AnyCancellable?

    var formattedElapsedTime: String {
        DateHelpers.formattedElapsedTime(elapsedTime)
    }

    var currentStartTime: Date? {
        timerService.currentTimer?.startTime
    }

    init(modelContext: ModelContext) {
        self.timerService = TimerService(modelContext: modelContext)
        restore()
    }

    func start() {
        timerService.start(taskDescription: taskDescription, project: selectedProject)
        isRunning = true
        startDisplayTimer()
    }

    func stop() {
        _ = timerService.stop()
        isRunning = false
        elapsedTime = 0
        taskDescription = ""
        selectedProject = nil
        stopDisplayTimer()
    }

    func toggle() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }

    private func restore() {
        if let timer = timerService.currentTimer {
            isRunning = true
            taskDescription = timer.taskDescription
            selectedProject = timer.project
            elapsedTime = timer.elapsedTime
            startDisplayTimer()
        }
    }

    private func startDisplayTimer() {
        displayTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let timer = self.timerService.currentTimer else { return }
                self.elapsedTime = timer.elapsedTime
            }
    }

    private func stopDisplayTimer() {
        displayTimer?.cancel()
        displayTimer = nil
    }
}
