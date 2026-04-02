import XCTest

final class EntryEditTests: XCTestCase {
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.windows.count > 0)
    }
}
