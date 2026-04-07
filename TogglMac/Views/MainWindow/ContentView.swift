import SwiftUI

struct ContentView: View {
    var timerViewModel: TimerViewModel
    var projectViewModel: ProjectViewModel
    var calendarViewModel: CalendarViewModel
    var timeEntryViewModel: TimeEntryViewModel

    @State private var isShowingManualEntry = false
    @State private var manualEntryStartTime: Date? = nil
    @State private var sidebarWidth: CGFloat = 200
    @State private var isEditingActiveTimer = false

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
            .frame(width: sidebarWidth)

            Rectangle()
                .fill(TogglTheme.divider)
                .frame(width: 3)
                .contentShape(Rectangle().size(width: 9, height: .infinity))
                .onHover { hovering in
                    if hovering {
                        NSCursor.resizeLeftRight.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged { value in
                            let newWidth = sidebarWidth + value.translation.width
                            sidebarWidth = min(max(newWidth, 140), 360)
                        }
                )

            // Main content
            VStack(spacing: 0) {
                TimerBarView(viewModel: timerViewModel)
                CalendarContainerView(
                    calendarViewModel: calendarViewModel,
                    activeTimerStart: timerViewModel.isRunning ? timerViewModel.currentStartTime : nil,
                    activeTimerProject: timerViewModel.isRunning ? timerViewModel.selectedProject : nil,
                    activeTimerDescription: timerViewModel.isRunning ? timerViewModel.taskDescription : nil,
                    onEntryTap: { entry in
                        timeEntryViewModel.selectEntry(entry)
                    },
                    onEntryDelete: { entry in
                        timeEntryViewModel.deleteEntry(entry)
                    },
                    onEntryMove: { entry, newStart in
                        timeEntryViewModel.moveEntry(entry, newStartTime: newStart)
                    },
                    onActiveTimerTap: {
                        isEditingActiveTimer = true
                    },
                    onEmptySlotClick: { date in
                        manualEntryStartTime = date
                        isShowingManualEntry = true
                    }
                )
            }
            .onAppear {
                updateTodayTotal()
            }
            .onChange(of: calendarViewModel.currentEntries.count) {
                updateTodayTotal()
            }

            // Right panel (Goals & Favorites)
            Rectangle()
                .fill(TogglTheme.divider)
                .frame(width: 1)

            rightPanel
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(TogglTheme.backgroundSecondary)
        .overlay {
            if timeEntryViewModel.isEditingEntry, let entry = timeEntryViewModel.selectedEntry {
                // 배경 딤 처리 + 탭으로 닫기
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        timeEntryViewModel.dismissEdit()
                    }

                EntryEditPopover(
                    entry: entry,
                    isActiveTimer: false,
                    onUpdateDescription: { desc in
                        timeEntryViewModel.updateDescription(desc)
                    },
                    onUpdateTime: { start, end in
                        timeEntryViewModel.updateTime(entry, startTime: start, endTime: end)
                    },
                    onStop: { },
                    onDelete: {
                        timeEntryViewModel.deleteEntry(entry)
                    },
                    onDismiss: {
                        timeEntryViewModel.dismissEdit()
                    }
                )
                .id(entry.id)
            }
        }
        .overlay {
            if isEditingActiveTimer, timerViewModel.isRunning, let startTime = timerViewModel.currentStartTime {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isEditingActiveTimer = false
                    }

                // 진행 중 타이머용 임시 TimeEntry
                let tempEntry = TimeEntry(
                    taskDescription: timerViewModel.taskDescription,
                    startTime: startTime,
                    endTime: Date(),
                    project: timerViewModel.selectedProject
                )

                EntryEditPopover(
                    entry: tempEntry,
                    isActiveTimer: true,
                    onUpdateDescription: { desc in
                        timerViewModel.taskDescription = desc
                    },
                    onUpdateTime: { newStart, _ in
                        timerViewModel.updateStartTime(newStart)
                    },
                    onStop: {
                        timerViewModel.toggle()
                        isEditingActiveTimer = false
                    },
                    onDelete: nil,
                    onDismiss: {
                        isEditingActiveTimer = false
                    }
                )
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

    // MARK: - Today Total

    private func updateTodayTotal() {
        let todayEntries = calendarViewModel.entriesForDay(Date())
        timerViewModel.todayCompletedTime = todayEntries.reduce(0) { $0 + $1.duration }
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
