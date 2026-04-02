import SwiftUI

struct ContentView: View {
    var timerViewModel: TimerViewModel
    var projectViewModel: ProjectViewModel
    var calendarViewModel: CalendarViewModel
    var timeEntryViewModel: TimeEntryViewModel

    @State private var isShowingManualEntry = false
    @State private var manualEntryStartTime: Date? = nil

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            SidebarView(
                projectViewModel: projectViewModel,
                timerViewModel: timerViewModel,
                onSelectProject: { project in
                    projectViewModel.selectedProject = project
                }
            )

            Rectangle()
                .fill(TogglTheme.divider)
                .frame(width: 1)

            // Main content
            VStack(spacing: 0) {
                TimerBarView(viewModel: timerViewModel)
                CalendarContainerView(
                    calendarViewModel: calendarViewModel,
                    activeTimerStart: timerViewModel.isRunning ? timerViewModel.currentStartTime : nil,
                    activeTimerProject: timerViewModel.isRunning ? timerViewModel.selectedProject : nil,
                    onEntryTap: { entry in
                        timeEntryViewModel.selectEntry(entry)
                    },
                    onEmptySlotClick: { date in
                        manualEntryStartTime = date
                        isShowingManualEntry = true
                    }
                )
            }

            // Right panel (Goals & Favorites)
            Rectangle()
                .fill(TogglTheme.divider)
                .frame(width: 1)

            rightPanel
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(TogglTheme.backgroundSecondary)
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
                .shadow(color: Color.black.opacity(0.4), radius: 12)
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

    // MARK: - Right Panel (Goals & Favorites)

    private var rightPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Goals section
            HStack {
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(TogglTheme.textTertiary)
                Text("Goals")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(TogglTheme.textPrimary)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 11))
                        .foregroundStyle(TogglTheme.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 11))
                        .foregroundStyle(TogglTheme.accentPink)
                    Text("CREATE A GOAL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(TogglTheme.accentPink)
                        .tracking(0.5)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            Rectangle()
                .fill(TogglTheme.divider)
                .frame(height: 1)
                .padding(.horizontal, 12)

            // Favorites section
            HStack {
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(TogglTheme.textTertiary)
                Text("Favorites")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(TogglTheme.textPrimary)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 11))
                        .foregroundStyle(TogglTheme.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 11))
                        .foregroundStyle(TogglTheme.accentPink)
                    Text("ADD FAVORITE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(TogglTheme.accentPink)
                        .tracking(0.5)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)

            Spacer()
        }
        .frame(width: 200)
        .background(TogglTheme.backgroundSecondary)
    }
}
