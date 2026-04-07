import XCTest
import SwiftData
@testable import TogglMac

final class TimerViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var viewModel: TimerViewModel!

    override func setUpWithError() throws {
        container = try makeTestContainer()
        context = ModelContext(container)
        viewModel = TimerViewModel(modelContext: context)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
        viewModel = nil
    }

    func testInitialStateIsNotRunning() {
        XCTAssertFalse(viewModel.isRunning)
    }

    func testStartSetsIsRunningToTrue() {
        viewModel.start()
        XCTAssertTrue(viewModel.isRunning)
    }

    func testStopSetsIsRunningToFalse() {
        viewModel.start()
        viewModel.stop()
        XCTAssertFalse(viewModel.isRunning)
    }

    func testFormattedElapsedTimeReturnsZeroInitially() {
        XCTAssertEqual(viewModel.formattedElapsedTime, "0:00:00")
    }

    func testTaskDescriptionBindingWorks() {
        viewModel.taskDescription = "My task"
        XCTAssertEqual(viewModel.taskDescription, "My task")
    }
}
