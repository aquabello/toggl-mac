import SwiftUI
import SwiftData

@Observable
class TimeEntryViewModel {
    var selectedEntry: TimeEntry?
    var isEditingEntry: Bool = false

    private let timeEntryService: TimeEntryService
    private let undoService: UndoService

    init(modelContext: ModelContext) {
        self.timeEntryService = TimeEntryService(modelContext: modelContext)
        self.undoService = UndoService(modelContext: modelContext)
    }

    func updateDescription(_ description: String) {
        guard let entry = selectedEntry else { return }
        timeEntryService.updateDescription(entry, description: description)
    }

    func updateProject(_ project: Project?) {
        guard let entry = selectedEntry else { return }
        timeEntryService.assignProject(entry, project: project)
    }

    func selectEntry(_ entry: TimeEntry) {
        selectedEntry = entry
        isEditingEntry = true
    }

    func dismissEdit() {
        isEditingEntry = false
        selectedEntry = nil
    }

    func deleteEntry(_ entry: TimeEntry) {
        undoService.deleteEntry(entry)
        if selectedEntry?.id == entry.id {
            dismissEdit()
        }
    }

    func undoDelete() {
        _ = undoService.undo()
    }

    var canUndo: Bool {
        undoService.canUndo
    }

    func createManualEntry(startTime: Date, endTime: Date, taskDescription: String, project: Project?) {
        _ = timeEntryService.createManual(
            startTime: startTime,
            endTime: endTime,
            taskDescription: taskDescription,
            project: project
        )
    }

    func detectOverlaps(start: Date, end: Date) -> [TimeEntry] {
        timeEntryService.detectOverlaps(start: start, end: end)
    }

    func fetchEntries(start: Date, end: Date) -> [TimeEntry] {
        timeEntryService.fetchByDateRange(start: start, end: end)
    }
}
