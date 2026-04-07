import XCTest

final class TimerFlowTests: XCTestCase {
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.windows.count > 0)
    }
}
