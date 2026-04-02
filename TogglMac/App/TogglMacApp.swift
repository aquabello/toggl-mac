import SwiftUI
import SwiftData

@main
struct TogglMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let modelContainer: ModelContainer
    let timerViewModel: TimerViewModel
    let projectViewModel: ProjectViewModel
    let calendarViewModel: CalendarViewModel
    let timeEntryViewModel: TimeEntryViewModel

    init() {
        do {
            let schema = Schema([
                TimeEntry.self,
                Project.self,
                TimerState.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            modelContainer = container
            let context = ModelContext(container)
            timerViewModel = TimerViewModel(modelContext: ModelContext(container))
            projectViewModel = ProjectViewModel(modelContext: context)
            calendarViewModel = CalendarViewModel(modelContext: ModelContext(container))
            timeEntryViewModel = TimeEntryViewModel(modelContext: ModelContext(container))
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                timerViewModel: timerViewModel,
                projectViewModel: projectViewModel,
                calendarViewModel: calendarViewModel,
                timeEntryViewModel: timeEntryViewModel
            )
            .onAppear {
                appDelegate.timerViewModel = timerViewModel
            }
        }
        .modelContainer(modelContainer)
    }
}
