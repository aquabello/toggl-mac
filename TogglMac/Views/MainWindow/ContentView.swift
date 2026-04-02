import SwiftUI

struct ContentView: View {
    var timerViewModel: TimerViewModel
    var projectViewModel: ProjectViewModel
    var calendarViewModel: CalendarViewModel
    var timeEntryViewModel: TimeEntryViewModel

    @State private var isShowingManualEntry = false
    @State private var manualEntryStartTime: Date? = nil

    var body: some View {
        HSplitView {
            SidebarView(
                projectViewModel: projectViewModel,
                onSelectProject: { project in
                    projectViewModel.selectedProject = project
                }
            )

            VStack(spacing: 0) {
                TimerBarView(viewModel: timerViewModel)
                Divider()
                CalendarContainerView(
                    calendarViewModel: calendarViewModel,
                    onEntryTap: { entry in
                        timeEntryViewModel.selectEntry(entry)
                    },
                    onEmptySlotClick: { date in
                        manualEntryStartTime = date
                        isShowingManualEntry = true
                    }
                )
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .overlay(alignment: .trailing) {
            if timeEntryViewModel.isEditingEntry, let entry = timeEntryViewModel.selectedEntry {
                EntryEditPanel(
                    entry: entry,
                    projects: projectViewModel.projects,
                    onUpdateDescription: { desc in
                        timeEntryViewModel.updateDescription(desc)
                    },
                    onUpdateProject: { project in
                        timeEntryViewModel.updateProject(project)
                    },
                    onDelete: {
                        timeEntryViewModel.deleteEntry(entry)
                    },
                    onDismiss: {
                        timeEntryViewModel.dismissEdit()
                    }
                )
                .background(.background)
                .shadow(radius: 8)
                .padding(.top, AppConstants.UI.timerBarHeight)
            }
        }
        .sheet(isPresented: $isShowingManualEntry) {
            ManualEntryForm(
                projects: projectViewModel.projects,
                onSave: { start, end, description, project in
                    timeEntryViewModel.createManualEntry(
                        startTime: start,
                        endTime: end,
                        taskDescription: description,
                        project: project
                    )
                    isShowingManualEntry = false
                },
                onCancel: {
                    isShowingManualEntry = false
                },
                onDetectOverlaps: { start, end in
                    timeEntryViewModel.detectOverlaps(start: start, end: end)
                }
            )
        }
        .background(
            Button("") {
                isShowingManualEntry = true
            }
            .keyboardShortcut("n", modifiers: .command)
            .hidden()
        )
        .background(
            Button("") {
                if timeEntryViewModel.canUndo {
                    timeEntryViewModel.undoDelete()
                }
            }
            .keyboardShortcut("z", modifiers: .command)
            .hidden()
        )
    }
}
