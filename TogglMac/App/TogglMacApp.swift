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
            // 모든 ViewModel이 동일한 ModelContext를 공유해야
            // 삭제/추가 시 캘린더 등 다른 뷰에 즉시 반영됨
            let sharedContext = ModelContext(container)
            timerViewModel = TimerViewModel(modelContext: sharedContext)
            projectViewModel = ProjectViewModel(modelContext: sharedContext)
            calendarViewModel = CalendarViewModel(modelContext: sharedContext)
            timeEntryViewModel = TimeEntryViewModel(modelContext: sharedContext)
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
