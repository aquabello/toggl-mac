import SwiftData
@testable import TogglMac

func makeTestContainer() throws -> ModelContainer {
    let schema = Schema([TimeEntry.self, Project.self, TimerState.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [config])
}
